require 'rexml/document'
require 'rexml/xpath'

module WordExport
  # The Processor class will walk the repository and extract the information 
  # and generate a Word XML file using a template.
  class Processor
    private
    # Instead of dealing with each field differently, with this method we can have
    # a generic way of adding a paragraph to the document. See Brian Jones 'Intro
    # to Word XML at: 
    # http://blogs.msdn.com/brian_jones/archive/2005/07/26/intro-to-word-xml-part-3-using-your-own-schema.aspx
    def self.word_paragraph_for(text, props={})
      txt = REXML::Element.new('w:t')
      txt.text = text 
        
      run = REXML::Element.new('w:r')

      if (props.key?(:rprops) && !(props[:rprops].size.zero?))
        # add properties to the run
        run_props = REXML::Element.new('w:rPr')
    
        props[:rprops].each do |prop|
          run_props.add( REXML::Element.new(prop) )
        end
        run.add( run_props )
      end

      run.add( txt )

      paragraph = REXML::Element.new('w:p')
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

        logger.debug{ "processing Note #{n.id}" }
        # Get the fields from the Note's text (see app/models/note.rb)
        fields = n.fields 

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
          # We make some fields (i.e. the creation date) to have italics font
          rprops << 'w:i' if ( ["created"].include?(field) )

          # The value of each field is broken in paragraphs which are added as
          # XML children of the +domtag+
          value.split("\n").each do |paragraph|
            domtag.add( word_paragraph_for(paragraph, :rprops => rprops) )
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
