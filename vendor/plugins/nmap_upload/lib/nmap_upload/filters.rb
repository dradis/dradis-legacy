module NmapUpload  

  private
  def self.parse_xml_output(content)
    # initiate some variables to be used
    hosts = {}
    xml = REXML::Document.new(content.to_s)
      
    # loop through all hosts
    REXML::XPath.match(xml[6],"//host").each do |host|
      hostnodename = host.elements['address'].attributes['addr']
      if (!host.elements['hostnames'].elements.empty?)
       hostnodename << '('
       hostnodename << host.elements['hostnames'].elements.to_a.collect do |hostname|
         hostname.attributes['name']
       end.join(",")
       hostnodename << ')'
      end

      hosts[hostnodename] = {:notes => host.to_s}
      hosts[hostnodename][:ports] = {}

      REXML::XPath.match(host.elements['ports'], "port").each do |port|
        hosts[hostnodename][:ports][port.attributes['portid']] = {
          :protocol => port.attributes['protocol'],
          :state => port.elements['state'].attributes['state'],
          :service => port.elements['service'].attributes['name']
        }
      end
    end
    
    return hosts
  end

  public
  
  # The framework will call this function if the user selects this plugin from
  # the dropdown list and uploads a file.
  # @returns true if the operation was successful, false otherwise
  def self.import(params={})
    file_content = File.read( params[:file].fullpath )
    hosts = parse_xml_output(file_content)

    # get the "nmap output" category instance or create it if it does not exist
    category = Category.find_by_name('Nmap output') 
    if (category.nil?)
      category = Category.new( :name => 'Nmap output')
      category.save
    end

    port_notes_to_add = {}
    hosts.each do |host, host_details|
      host_node = Node.new( :label => host)
      host_node.save

      # add the nmap output for the host as notes to the node
      Note.new(
        :node_id => host_node.id,
        :author => 'Nmap',
        :category_id => category.id,
        :text => host_details[:notes]
      ).save

      host_details[:ports].each do |port, port_details|
        # Add a node for the port
        port_node = Node.new( :parent_id => host_node.id, :label => "#{port}/#{port_details[:protocol]}" )
        port_node.save

        # add a note with the port information
        Note.new(
          :node_id => port_node.id,
          :author => 'Nmap',
          :category_id => category.id,
          :text => "State: #{port_details[:state]}, Service: #{port_details[:service]}"
        ).save
      end
    end

    return true
  end
end
