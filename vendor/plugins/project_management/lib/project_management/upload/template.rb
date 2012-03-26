module ProjectTemplateUpload

  # The import method is invoked by the framework to process a template file
  # that has just been uploaded using the 'Import from file...' dialog.
  # 
  # This module will take the XMl export file created with the ProjectExport
  # module and dump the contents into the current database.
  #
  # Since we cannot ensure that the original node and category IDs as specified
  # in the XML are free in this database, we need to keep a few lookup tables 
  # to maintain the original structure of Nodes and the Notes pointing to the
  # right nodes and categories.
  # 
  # This method also returns the Node lookup table so callers can understand 
  # what changes to the original IDs have been applied. This is mainly for the
  # benefit of the ProjectPackageUpload module that would use the translation
  # table to re-associate the attachments in the project archive with the new
  # node IDs in the current project.
  def self.import(params={})
    logger = params.fetch(:logger, Rails.logger)
 
    # load the template
    logger.info{ "Loading template file from: #{params[:file]}" }
    template = REXML::Document.new( File.read( params[:file] ) )

    # we need this to be able to convert from old category_id to the new
    # category_id once the categories are added to the DB (the ID may have 
    # changed)
    category_lookup = {}
    # the same applies to Nodes (think parent_id)
    node_lookup = {}
    # all children nodes, we will need to find the new ID of their parents
    orphan_nodes = []

    # go through the categories, keep a translation table between the old 
    # category id and the new ones so we know to which category we should
    # assign our notes
    template.elements.each('dradis-template/categories/category') do |xml_category|
      old_id = xml_category.elements['id'].text.strip
      name = xml_category.elements['name'].text.strip
      category = nil

      # Prevent creating duplicate categories
      logger.info{ "Looking for category: #{name}" }
      if (category = Category.find_by_name(name)).nil?
        category = Category.create :name => name
      end

      category_lookup[old_id] = category.id
    end

    # Re generate the Node tree structure
    template.elements.each('dradis-template/nodes/node') do |xml_node|
      element = xml_node.elements['type-id']
      type_id     = element.text.nil? ? nil : element.text.strip
      
      label       = xml_node.elements['label'].text.strip

      element = xml_node.elements['parent-id']
      parent_id   = element.text.nil? ? nil : element.text.strip

      # Node positions
      element = xml_node.elements['position']
      position   = (element && !element.text.nil?) ? element.text.strip : nil
      created_at  = xml_node.elements['created-at'].text.strip
      updated_at  = xml_node.elements['updated-at'].text.strip

      logger.info{ "New node detected: #{label}, parent_id: #{parent_id}, type_id: #{type_id}" }

      # There is one exception to the rule, the Configuration.uploadsNode node,
      # it does not make sense to have more than one of this nodes, in any 
      # given tree
      node = nil  
      if ( label == Configuration.uploadsNode )
        node = Node.find_or_create_by_label( label, {
                                                      :type_id => type_id,
                                                      :parent_id => parent_id
                                                    })

        node.update_attribute(:created_at, created_at) if created_at
        node.update_attribute(:updated_at, updated_at) if updated_at
      else
        node = Node.create  :type_id     => type_id,
                            :label       => label,
                            :parent_id   => parent_id,
                            :position    => position

        node.update_attribute(:created_at, created_at) if created_at
        node.update_attribute(:updated_at, updated_at) if updated_at
      end

      xml_node.elements.each('notes/note') do |xml_note|
        if xml_note.elements['author'] != nil
          old_id = xml_note.elements['category-id'].text.strip
          new_id = category_lookup[old_id]

          logger.info{ "Note category rewrite, used to be #{old_id}, now is #{new_id}" }
          note = Note.create :author      => xml_note.elements['author'].text.strip,
                              :node_id     => node.id,
                              :category_id => new_id,
                              :text        => xml_note.elements['text'].text.strip,
                              :created_at  => xml_note.elements['created-at'].text.strip,
                              :updated_at  => xml_note.elements['updated-at'].text.strip
        end
      end
      
      # keep track of reassigned ids
      node_lookup[xml_node.elements['id'].text.strip] = node.id

      if node.parent_id != nil
        # keep track of orphaned nodes
        orphan_nodes << node
      end
    end
    
    # look for the parent_id of each orphaned node in the node_lookup table
    orphan_nodes.each do |node|
      logger.info{ "Finding parent for orphaned node: #{node.label}. Former parent was #{node.parent_id}" }
      node.parent_id = node_lookup[node.parent_id.to_s]
      node.save
    end

    return node_lookup
  end
end
