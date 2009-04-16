require 'rexml/document'
require 'rexml/xpath'

module WordExport
  # The Processor class will walk the repository and extract the information 
  # and generate a Word XML file using a template.
  class Processor
    private

    # Given a root node title and a set of WordXML properties, this method 
    # creates the right XML structure to represent them
    def self.word_properties(element, props={})
      # add properties to the run
      properties = REXML::Element.new(element)
    
      props.each do |prop|
        root = prop[:root]
        attributes = prop.fetch( :attributes, [])
        p = REXML::Element.new(prop[:root])
        if ( !attributes.size.zero? )
          p.add_attributes( attributes )
        end
        properties.add( p )
      end
      return properties
    end

    # Instead of dealing with each field differently, with this method we can have
    # a generic way of adding a paragraph to the document. See Brian Jones 'Intro
    # to Word XML at: 
    # http://blogs.msdn.com/brian_jones/archive/2005/07/26/intro-to-word-xml-part-3-using-your-own-schema.aspx
    def self.word_paragraph_for(text, props={})
      txt = REXML::Element.new('w:t')
      txt.text = text 
        
      run = REXML::Element.new('w:r')

      # if there are any properties for the "run", add them
      if (props.key?(:rprops) && !(props[:rprops].size.zero?))
        run.add( word_properties( 'w:rPr', props[:rprops] ))
      end

      run.add( txt )

      paragraph = REXML::Element.new('w:p')

      # if there are any properties for the "paragraph", add them
      if (props.key?(:pprops) && !(props[:pprops].size.zero?))
        paragraph.add( word_properties('w:pPr', props[:pprops]) )
      end

      paragraph.add( run )
      return paragraph
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
      logger = params.fetch(:logger, RAILS_DEFAULT_LOGGER)
      logger.info{ 'Generating Word report' } 

      # This needs some tweaking, but the idea is that maybe you don't want to
      # report on all of your notes, so you flag the ones you want to report
      # by adding them to a specific category (7). Feel free to adjust.
      reporting_cat = Category.find_by_name(REPORTING_CATEGORY_NAME)
      reporting_notes_num = Note.count(:all, :conditions => {:category_id => reporting_cat})
      logger.info{ "There are #{reporting_notes_num} notes in the #{REPORTING_CATEGORY_NAME} category." }

      begin
        logger.info{ 'Loading template... '}
        doc = REXML::Document.new(File.new('./vendor/plugins/word_export/template.xml','r'))
        logger.info{ 'done.' }
      rescue REXML::ParseException => e # re-raise exception
        logger.fatal{ e }
        raise Exception.new(e)
      end

      findings_container = REXML::XPath.first(doc, "//[@id='findings']")
      # TODO: finding the container is easy, but how do we find the template? is
      # it the first child? the third?
      vuln_template = REXML::Document.new( doc.root.clone.to_s )
      vuln_template.root.add findings_container.children[5]
  
      Note.find(:all, :conditions => {:category_id => reporting_cat}).each do |n|
        v = REXML::Document.new(vuln_template.to_s)

        logger.debug('WordExport'){ "processing Note #{n.id}" }
        # Get the fields from the Note's text (see app/models/note.rb)
        fields = n.fields 

        # If the note doesn't define Title, Description and Recommendation 
        # notify the user that the format of the text is not adecuate
        required_fields = ['Title', 'Description', 'Recommendation']
        if ((fields.keys & required_fields).size != 3)
          logger.debug('WordExport'){ "\tInvalid format detected" }
          fields['Title'] = "Note \##{n.id}: Invalid format detected"
          fields['Description']= "The WordExport plugin expects the text of " +
                                  "your notes to be in a specific format.\n" +
                                  "Please refer to the Export -> WordExport -> Usage instructions menu" +
                                  " to find out more about using this plugin.\n" +
                                  "Excerpt of the note that caused this problem:\n"+
                                  n.text[0..50]
                                  
        end

        # We can add extra fields, for instance author, date, etc:
        fields['created'] = n.created_at.strftime("%Y-%m-%d %T %Z")

        # We will try to locate every field in the template. To do so, we will
        # look for XML entities with an id="vuln<field>", if we find them, then
        # we populate the entity with the value of the field.
        fields.each do |field, value|
          logger.debug('WordExport'){ "\tParsing field: #{field}... " }
          domtag = REXML::XPath.first(v, "//[@id='vuln#{field.downcase.gsub(/\s/,'')}']") 
          if (domtag.nil?)
            logger.debug('WordExport'){ "\tnot found in the template" }
            next
          end
          domtag.delete_attribute('id')

          # Initialise the "run" properties (in WordXML text is split in runs) 
          rprops = [] 

          # In specific field we can add extra text attributes
          if ( ["created"].include?(field) )
            # The "created at" text will be:
            #   - in italics
            #   - and Arial 8 (numbers are x2)
            rprops << { :root => 'w:i' }
            rprops << {
                        :root => 'w:rFonts', 
                        :attributes => { 
                          'w:ascii' => 'Arial', 
                          'w:h-ansi' => 'Arial', 
                          'w:cs' => 'Arial' 
                        }
                      }
            rprops  << { :root => 'wx:font', :attributes => { 'wx:val' => 'Arial' } }
            rprops  << { :root => 'w:sz', :attributes => { 'w:val' => '16' } }
            rprops  << { :root => 'w:sz-cs', :attributes => { 'w:val' => '16' } }
          end

          # Initialise the "paragraph" properties
          pprops = [] 
          # Additional properties for some special paragraphs 
          if ( ["created"].include?(field) )
            # The "created at" paragraph will be:
            #   - right aligned
            pprops << {:root => 'w:jc', :attributes => {'w:val' => 'right'} }
          end

          if ( ["Title"].include?(field) )
            # Apply the "Heading1" style to the Vulnerability Title
            pprops << {:root => 'w:pStyle', :attributes => {'w:val' => 'Heading1'} }
          end

          # The value of each field is broken in paragraphs which are added as
          # XML children of the +domtag+
          value.split("\n").each do |paragraph|
            domtag.add( word_paragraph_for(paragraph, :rprops => rprops, :pprops => pprops) )
          end   
          domtag.add( word_paragraph_for('') )
          logger.debug('WordExport'){ "\tdone." }
        end

        findings_container.add(v.root.children[0])  
      end

      return doc
    end
  end
end
