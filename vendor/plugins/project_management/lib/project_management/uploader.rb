module ProjectTemplateUpload
  def self.import(params={})
    logger = params.fetch(:logger, RAILS_DEFAULT_LOGGER)
 
    # load the template
    logger.debug{ "Loading template file from: #{params[:file].fullpath}" }
    template = REXML::Document.new( File.read( params[:file].fullpath ) )

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
      logger.debug{ "Looking for category: #{name}" }
      if (category = Category.find_by_name(name)).nil?
        category = Category.create :name => name
      end

      category_lookup[old_id] = category.id
    end

    # Re generate the Node tree structure
    template.elements.each('dradis-template/nodes/node') do |xml_node|
      type_id     = xml_node.elements['type-id'].text
      label       = xml_node.elements['label'].text.strip
      parent_id   = xml_node.elements['parent-id'].text
      created_at  = xml_node.elements['created-at'].text.strip
      updated_at  = xml_node.elements['updated-at'].text.strip

      logger.debug{ 'New node detected: ' }
      logger.debug{ "label: #{label}, parent_id: #{parent_id}, type_id: #{type_id}" }

      node = Node.create  :type_id     => type_id.nil? ? nil : type_id.strip,
                          :label       => label,
                          :parent_id   => parent_id.nil? nil : parent_id.strip,
                          :created_at  => created_at,
                          :updated_at  => updated_at

      xml_node.elements.each('notes/note') do |xml_note|
        if xml_note.elements['author'] != nil
          old_id = xml_note.elements['category-id'].text.strip
          # FIXME: use logger
          $stderr.puts "rewriting category #{old_id} to #{category_lookup[old_id]}"
          note = Note.create :author      => xml_note.elements['author'].text.strip,
                              :node_id     => node.id,
                              :category_id => category_lookup[old_id],
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
      # FIXME use logger
      $stderr.puts " - node #{node.label} orphaned from #{node.parent_id}"
      $stderr.puts "   assigning to #{node_lookup[node.parent_id.to_s]}"
      node.parent_id = node_lookup[node.parent_id.to_s]
      node.save
    end

  end
end
