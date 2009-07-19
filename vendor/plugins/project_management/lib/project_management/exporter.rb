module ProjectExport
  # The Processor class does the heavy-lifting of the export functionalities
  # provided by the ProjectManagement plugin.
  # The different Actions defined in this module will in turn call methods in
  # the Processor class to implement the requested operations
  class Processor
    private
    public
    def self.db_only()
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

      return out
    end
  end
end
