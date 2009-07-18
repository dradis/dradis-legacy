=begin
**
** word_xml.rb
** 26 June 2009
**
** Desc:
** This class represents a WordXML document.
**
** License:
**   See dradis.rb or LICENSE.txt for copyright and licensing information.
**
=end

require 'rexml/document'
require 'rexml/xpath'

module WordExport
  # This class represents a WordXML document and provides helper functions to 
  # add paragraphs, sections, properties, etc.
  class WordXML < REXML::Document
    attr :doc

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


    # This method will create a new paragraph for the text as the previous 
    # method. The difference is that this one will inspect the template 
    # paragraph and if it contains a <w:pPr> element, that element will be
    # cloned and included in the new paragraph
    def self.clone_paragraph_with(template, text)
      paragraph = word_paragraph_for(text)

      if (template.elements[1].name == 'pPr')
        paragraph.insert_before( paragraph.elements[1], template.elements[1].dup )
      end

      return paragraph
    end

    public
    # Generate a WordXML instance from a template
    def initialize(params={})
      if (params.key?(:template))
        template = params[:template]
     
        begin
          super(File.new(template, 'r'))
        rescue REXML::ParseException => e # re-raise exception
          raise Exception.new(e)
        end
      else
        raise Exception.new('No :template was provided!')
      end
    end
  end
end
