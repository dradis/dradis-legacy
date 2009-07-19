# ProjectExport module of the plugin defines two actions:
#
#  = as_template: downloads a copy of the internal database for storage, it 
#    dumps the contents of the DB into an XML file.
#  = full_project: exports the database (see as_template) and attachments for 
#    each node. These are presented to the user as 'dradis_YYYY-MM-dd.zip'.
#
# This plugin theoretically supports any database backend supported by Active
# Record. It is most efficient when utilising an SQLite database.
module ProjectExport
  module Actions
    def full_project 
    end
    def as_template
      nodes = Node.find(:all).to_xml(:include => :notes)
      categories = Category.find(:all).to_xml

      template = REXML::Document.new
      template.add( REXML::Element.new('dradis-template') )
      xml_nodes = REXML::Document.new( nodes )
      xml_categories = REXML::Document.new( categories )

      template.root.add_element( xml_nodes.root )
      template.root.add_element( xml_categories.root )

      template << REXML::XMLDecl.new( '1.0', 'UTF-8')
      template.write( out='', 4 )
      send_data( out , :filename => 'dradis-template.xml',  :type => :xml )
    end
  end
end
