require 'rexml/document'
require 'zip/zip'

module ProjectExport
  # The Processor class does the heavy-lifting of the export functionalities
  # provided by the ProjectManagement plugin.
  # The different Actions defined in this module will in turn call methods in
  # the Processor class to implement the requested operations
  class Processor
    private
    public
    # This method returns an XML representation of current repository which
    # includes Categories, Nodes and Notes
    def self.db_only(params={})
      nodes = Node.find(:all).to_xml(:include => :notes)
      categories = Category.find(:all).to_xml

      template = REXML::Document.new
      template.add( REXML::Element.new('dradis-template') )
      xml_nodes = REXML::Document.new( nodes )
      xml_categories = REXML::Document.new( categories )

      template.root.add_element( xml_nodes.root )
      template.root.add_element( xml_categories.root )

      template << REXML::XMLDecl.new( '1.0', 'UTF-8')
      template.write(out='')
      #template.write( out='', 2 )

      return out
    end

    # Create a new project export bundle. It will include an XML file with the
    # contents of the repository (see db_only) and all the attachments that 
    # have been uploaded into the system.
    def self.full_project(params={})
      raise ":filename not provided" unless params.key?(:filename)
      
      filename = params[:filename]
      logger = params.fetch(:logger, Rails.logger)

      File.delete(filename) if File.exists?(filename)

      logger.debug{ "Creating a new Zip file in #{filename}..." }
      Zip::ZipFile.open(filename, Zip::ZipFile::CREATE) { |zipfile|
        Node.find(:all).each do |node|
          node_path = File.join('attachments', "#{node.id}")

          Dir["#{node_path}/**/**"].each do |file|
            logger.debug{ "\tAdding attachment for '#{node.label}': #{file}" }
            zipfile.add(file.sub('attachments/', ''), file)
          end
        end
        
        logger.debug{ "\tAdding XML repository dump" }
        zipfile.get_output_stream('dradis-repository.xml') { |out|
          out << db_only()
        }
      }
      logger.debug{ 'Done.' }
    end
  end
end
