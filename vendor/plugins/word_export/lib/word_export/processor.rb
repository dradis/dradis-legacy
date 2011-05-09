require 'rexml/document'
require 'rexml/xpath'

module WordExport
  # The Processor class will walk the repository and extract the information 
  # and generate a Word XML file using a template.
  class Processor
    private

    OPTIONS = {
      :logger_name => 'WordExport',
      # TODO: can we do better than this? i.e. __FILE__ ?
      :template => './vendor/plugins/word_export/template.xml',
      #FIXME:category_name => REPORTING_CATEGORY_NAME,
      :required_fields => ['Title', 'Description', 'Recommendation'],
    }
    @@logger = nil
    @@logger_name = nil

    # For every field in the note, we have to find the placeholder, nest some
    # children, apply some WordXML properties
    def self.process_field(note_chunk, field)
      name, value = field
      
      domtag = REXML::XPath.first(note_chunk, "//w:fldSimple[contains(@w:instr,'#{name}')]")
      if (domtag.nil?)
        # If the current field is not found in the template, move on
        @@logger.debug(@@logger_name){ "\tno custom field for [#{name}] found in the template" }
        return
      end
      # Ensure that the custom property field is empty
      parent_node = domtag.parent.dup
      empty = REXML::Element.new('dradisplaceholder')
      domtag.parent.replace_with( empty )

      # The value of each field is broken in paragraphs which are added as
      # XML children of the +domtag+
      value.split("\n").each do |paragraph|
        empty.add( WordXML.clone_paragraph_with(parent_node, paragraph) )
      end   

    end

    # For every Note in the repository we need to go through it's fields and 
    # try to fill in the placeholders in the template.
    def self.process_note(vuln_template, note, required_fields)
      note_chunk = REXML::Document.new(vuln_template.to_s)

      @@logger.debug(@@logger_name){ "processing Note #{note.id}" }
      # Get the fields from the Note's text (see app/models/note.rb)
      fields = note.fields 

      # If the note doesn't define Title, Description and Recommendation 
      # notify the user that the format of the text is not adecuate
      if (
           fields.size.zero? ||
           ( (fields.keys & required_fields).size != required_fields.size )
        )
        # TODO: customise error message to the required_fields set
        # TODO: how do we notify of an error if the field names are unknown?
        @@logger.debug(@@logger_name){ "\tInvalid format detected" }
        fields['Title'] = "Note \##{note.id}: Invalid format detected"
        fields['Description']= "The WordExport plugin expects the text of " +
                                "your notes to be in a specific format.\n" +
                                "Please refer to the Export -> WordExport -> Usage instructions menu" +
                                " to find out more about using this plugin.\n" +
                                "Excerpt of the note that caused this problem:\n"+
                                note.text[0..50]
                                
      end

      # TODO: add all the Note attributes, this will help when the user can define their
      #  attribute structure, so we won't need to change too much code
      # This has to be done before the required_fields comparison

      # We can add extra fields, for instance author, date, etc:
      fields['created'] = note.created_at.strftime("%Y-%m-%d %T %Z")
 
      # We will try to locate every field in the template. To do so, we will
      # look for XML entities with an id="vuln<field>", if we find them, then
      # we populate the entity with the value of the field.
      fields.each do |field|
        @@logger.debug(@@logger_name){ "\tParsing field: #{field[0]}... " }
        process_field(note_chunk, field) 
        @@logger.debug(@@logger_name){ "\tdone." }
      end

      return note_chunk
    end


    public
    # This method generates a Word report from a set of dradis Notes. This notes 
    # have to be asigned to a specific category and have to have the following
    # format:
    #
    # #[<field #1 name>]# 
    # <field contents #1>
    #
    # #[<field #2 name>]
    # <field contents #2>
    # ...
    #
    # For example:
    # 
    # #[Title]#
    # Insecure Cookie Configuration
    #
    # #[Description]
    # Several flags that add an extra layer of security to HTTP cookies were 
    # found not to be in use by the application. 
    # 
    # The Secure flag was not set. 
    #
    # The HTTPOnly flag was not set. 
    #
    # The method will split the note text in fields and values, and then will 
    # locate the corresponding placeholders in the XML template. These 
    # placeholders are located using XPath. For instance if the field name is
    # "Title" we will try to locate a tag with id="vulntitle", if it is 
    # "Description" we will try to locate a tag with id="vulndescription", etc.
    #
    # Once the placeholder is found, the field value is splited in lines and a 
    # new Word XML paragraph is attached to the placeholder for each line 
    def self.generate(params={})
      # ------------------------------------------------------- init properties
      @@logger = params.fetch(:logger, Rails.logger)

      # This needs some tweaking, but the idea is that maybe you don't want to
      # report on all of your notes, so you flag the ones you want to report
      # by adding them to a specific category (7). Feel free to adjust.
      category_name = params.fetch(:category_name, REPORTING_CATEGORY_NAME)
      reporting_cat = Category.find_by_name(category_name)
      reporting_notes_num = Note.count(:all, :conditions => {:category_id => reporting_cat})
      @@logger.info{ "There are #{reporting_notes_num} notes in the '#{category_name}' category." }

      # Merge our own default options with the parameters passed to the 
      # function
      options = OPTIONS.merge(params)

      @@logger_name = options[:logger_name]
      template = options[:template]
      required_fields = options[:required_fields]

      # ------------------------------------------------------ /init properties
      @@logger.info{ 'Generating Word report' } 

      begin
        @@logger.info{ 'Loading template... '}
        doc = WordXML.new({:template => template})
        @@logger.info{ 'done.' }
      rescue Exception => e # re-raise exception
        @@logger.fatal{ e }
        raise Exception.new(e)
      end

      # For each section of the document (id="section"), we go through 
      # all the notes and duplicate de structure we find there
      REXML::XPath.each(doc, "//[local-name()='dradis-section']") do |section|

        # for each section we find the note template, we will duplicate it, 
        # fill it with the values of the current note and attach the result to
        # the main document.
        note_template = REXML::XPath.first(section, "#{section.xpath}//[local-name()='dradis-template']")

        vuln_template = REXML::Document.new( doc.root.clone.to_s )
        vuln_template.root.add_element note_template.dup

  
        Note.find(:all, :conditions => {:category_id => reporting_cat}).each do |note|

          # Use the Note template to create a new set of XML elements, fill the 
          # the placeholders with the values in the fields of the current node
          note_chunk = process_note( 
                        vuln_template, 
                        note,
                        required_fields)

          # Insert the new Note chunk in the main note tree
          section.insert_after note_template.xpath, note_chunk.root.children[0]
        end # /Note.find.each
        note_template.remove
      end # /XPath.each id="section"

      return doc
    end
  end
end
