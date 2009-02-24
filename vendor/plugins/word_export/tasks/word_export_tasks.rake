require 'rexml/document'
require 'rexml/xpath'

# Instead of dealing with each field differently, with this method we can have
# a generic way of adding a paragraph to the document. See Brian Jones 'Intro
# to Word XML at: 
# http://blogs.msdn.com/brian_jones/archive/2005/07/26/intro-to-word-xml-part-3-using-your-own-schema.aspx
def word_paragraph_for(text, props={})
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


namespace :export do
  desc "Export the contents of the dradis repository to a Word document"
  task :word => :environment do
    # This needs some tweaking, but the idea is that maybe you don't want to
    # report on all of your notes, so you flag the ones you want to report
    # by adding them to a specific category (7). Feel free to adjust.
    puts "There are #{Note.find(:all, :conditions => {:category_id => 7}).count} notes in the reporting category (7)."

    begin
      print "Loading template... "
      doc = REXML::Document.new(File.new('./vendor/plugins/word_export/template.xml','r'))
      puts "done."
    rescue REXML::ParseException => e # re-raise exception
      raise Exception.new(e)
    end

    findings_container = REXML::XPath.first(doc, "//[@id='findings']")
    # TODO: finding the container is easy, but how do we find the template? is
    # it the first child? the third?
    vuln_template = REXML::Document.new( doc.root.clone.to_s )
    vuln_template.root.add findings_container.children[3]

    Note.find(:all, :conditions => {:category_id => 7}).each do |n|
      v = REXML::Document.new(vuln_template.to_s)

      puts "processing Note #{n.id}"
      fields = n.text.split(/.+?:\n.*?/).collect do |field| field.strip end

      #title
      title = REXML::XPath.first(v, "//w:t[@id='vulntitle']") 
      title.delete_attribute('id')
      title.text = fields[1]

      #date
      created_at = REXML::XPath.first(v, "//w:t[@id='vulncreated']") 
      created_at.delete_attribute('id')
      created_at.text = n.created_at.strftime("%Y-%m-%d %T %Z")

      #description
      description = REXML::XPath.first(v, "//wx:sub-section[@id='vulndesc']")
      description.delete_attribute('id')
      fields[2].split("\n\n").each do |paragraph|

        par = REXML::Element.new('w:t')
        par.text = paragraph
        r = REXML::Element.new('w:r')
        r.elements << par
        chunk = REXML::Element.new('w:p')
        chunk.attributes['wsp:rsidR']="00C27C1C" 
        chunk.attributes['wsp:rsidRDefault']="00C27C1C"
        chunk.attributes['wsp:rsidP']="00C27C1C"
        chunk.elements << r
        description.elements << chunk 
      end

      #recommendation
      recommendation = REXML::XPath.first(v, "//wx:sub-section[@id='vulnrec']")
      recommendation.delete_attribute('id')
      fields[3].split("\n\n").each do |paragraph|
        par = REXML::Element.new('w:t')
        par.text = paragraph
        r = REXML::Element.new('w:r')
        r.elements << par

        chunk = REXML::Element.new('w:p')
        chunk.attributes['wsp:rsidR']="00C27C1C" 
        chunk.attributes['wsp:rsidRDefault']="00C27C1C"
        chunk.attributes['wsp:rsidP']="00C27C1C"
        chunk.elements << r
        recommendation.elements << chunk
      end

      #additional information
      if (fields.size > 4)
        additional = REXML::XPath.first(v, "//wx:sub-section[@id='vulnextra']")
        additional.delete_attribute('id')
        fields[4].split("\n\n").each do |paragraph|
          par = REXML::Element.new('w:t')
          par.text = paragraph
          r = REXML::Element.new('w:r')
          r.elements << par

          chunk = REXML::Element.new('w:p')
          chunk.attributes['wsp:rsidR']="00C27C1C" 
          chunk.attributes['wsp:rsidRDefault']="00C27C1C"
          chunk.attributes['wsp:rsidP']="00C27C1C"
          chunk.elements << r
          additional.elements << chunk
        end
      else
        v.elements.delete("//wx:sub-section[@id='vulnextra']")
      end

      # TODO: this w:sectPr is speciffic of this template, try to avoid
      findings_container.insert_before('//w:sectPr', v.root.children[0])  
    end

    doc.write(File.new('report.xml','w'), -1, true)
  end
end

