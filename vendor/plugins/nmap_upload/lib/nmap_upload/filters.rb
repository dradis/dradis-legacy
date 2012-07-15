require 'nmap/xml'

class Nmap::Port
  def service_node
    @service_node ||= if (service = @node.at('service'))
                        service
                      end
  end
end

module NmapUpload

  private
  @@logger=nil

  public
  
  # The framework will call this function if the user selects this plugin from
  # the dropdown list and uploads a file.
  # @returns true if the operation was successful, false otherwise
  def self.import(params={})
    file_path = params[:file]
    file_content = File.read( params[:file] ) 
    @@logger = params.fetch(:logger, Rails.logger)

    # get the "nmap output" category instance or create it if it does not exist
    category = Category.find_or_create_by_name( Configuration.category )
    # every note we create will be assigned to this author
    author = Configuration.author
    # create the parent early so we can use it to provide feedback on errors
    parent = Node.find_or_create_by_label( Configuration.parent_node)

    # TODO: figure out if this can be done with Nokogiri
    #   http://nmap.org/svn/docs/nmap.dtd
    @@logger.info{ 'Validating Nmap upload...' }
    errors = Validator.validate(file_content)
    if errors.any?
      errors.each do |error|
        error << "\n#[File name]#\n#{File.basename( params[:file] )}\n\n"
        parent.notes.create(
          :author => author,
          :category_id => category.id,
          :text => error)
      end
      return false
    end

    @@logger.info{ 'Parsing Nmap output...' }
    doc = Nmap::XML::new(file_path)
    @@logger.info{ 'Done.' }

    # TODO: do something with the Nmap::Parser::Session information
    port_notes_to_add = {}


    doc.each_host do |host|
      host_label = host.ip
      host_label += " (#{host.hostnames.uniq.join(', ')})" if host.hostnames.any?
      host_node = parent.children.find_or_create_by_label_and_type_id( host_label, Node::Types::HOST )

      # add the nmap output for the host as notes to the node
      host_info = "#{host.ip}:\n"
      host_info << "\tHostnames: #{host.hostnames}\n"
      host_info << "\tPort info:\n\n"

      port_hash = {}
      host.each_port do |port|
        port_info = ''
        port_info << "\t\tPort ##{port.number}/#{port.protocol} is #{port.state} (#{port.reason})\n"
        if (srv = port.service_node)
          port_info << "\t\t\tService: #{srv['name']}\n" if srv['name']
          port_info << "\t\t\tProduct: #{srv['product']}\n" if srv['product']
          port_info << "\t\t\tVersion: #{srv['version'] }\n" if srv['version']
          port_info << "\n"
        end
        port_hash["#{port.number}/#{port.protocol}"] = port_info
        host_info << port_info
      end

      Note.new(
        :node_id => host_node.id,
        :author => author,
        :category_id => category.id,
        :text => host_info
      ).save

      port_hash.each do |port_name, info|
        # Add a node for the port
        port_node = host_node.children.find_or_create_by_label( port_name )

        # add a note with the port information
        Note.new(
          :node_id => port_node.id,
          :author => author,
          :category_id => category.id,
          :text => info
        ).save
      end
    end

    return true
  end
end
