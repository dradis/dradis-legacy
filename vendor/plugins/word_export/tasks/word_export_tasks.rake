require 'rexml/document'
require 'rexml/xpath'


namespace :export do
  desc "Export the contents of the dradis repository to a Word document"
  task :word => :environment do
    puts "There are #{Note.count} notes in the dradis database."

    begin
      doc = REXML::Document.new(File.new('./vendor/plugins/word_export/template.xml','r'))
    rescue REXML::ParseException => e # re-raise exception
      raise Exception.new(e)
    end

    vulns = []
    body = REXML::XPath.first(doc, '//w:body')
    vuln_template = REXML::Document.new( doc.root.clone.to_s )
    vuln_template.root.add body.children[3]

    Note.find(:all).each do |n|
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

      vulns << v
    end

    vulns.each do |v|
      body.insert_before('//w:sectPr', v.root.children[0])  
    end
    puts
    doc.write(File.new('report.xml','w'), -1, true)
  end
end

