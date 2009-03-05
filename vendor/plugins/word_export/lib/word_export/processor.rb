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
      reporting_notes_num = Note.find(:all, :conditions => {:category_id => reporting_cat}).count
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
        fields = Hash[ *n.text.scan(/#\[(.+?)\]#\n(.*?)(?=#\[|\z)/m).flatten.collect do |str| str.strip end ]


        #title
        title = REXML::XPath.first(v, "//w:t[@id='vulntitle']") 
        title.delete_attribute('id')
        title.text = fields['Title']
  
        #date
        created_at = REXML::XPath.first(v, "//w:t[@id='vulncreated']") 
        created_at.delete_attribute('id')
        created_at.text = n.created_at.strftime("%Y-%m-%d %T %Z")

        #description
        description = REXML::XPath.first(v, "//wx:sub-section[@id='vulndesc']")
        description.delete_attribute('id')
        fields['Description'].split("\n").each do |paragraph|
          description.add( word_paragraph_for(paragraph) )
        end   
        description.add( word_paragraph_for('') )

        #recommendation
        recommendation = REXML::XPath.first(v, "//wx:sub-section[@id='vulnrec']")
        recommendation.delete_attribute('id')
        fields['Recommendation'].split("\n").each do |paragraph|
          recommendation.add( word_paragraph_for(paragraph) )
        end   
        recommendation.add( word_paragraph_for('') )

        #additional information
        if (fields.key?('Additional Information'))
          additional = REXML::XPath.first(v, "//wx:sub-section[@id='vulnextra']")
          additional.delete_attribute('id')
          fields['Additional Information'].split("\n").each do |paragraph|
            additional.add( word_paragraph_for(paragraph) )
          end   
          additional.add( word_paragraph_for('') )
        else
          v.elements.delete("//wx:sub-section[@id='vulnextra']")
        end

        findings_container.add(v.root.children[0])  
      end

      #doc.write(File.new('report.xml','w'), -1, true)
      return doc
    end
  end
end
