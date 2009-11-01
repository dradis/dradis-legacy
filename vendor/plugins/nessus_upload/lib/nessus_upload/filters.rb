module NessusUpload  


      CONF_FILE 	= File.join(RAILS_ROOT, 'config', 'nessus_upload.yml')
      CONFIG 	= YAML::load( File.read CONF_FILE )

# HelperClasses
class NessusScannedHost
	attr_reader	:host_name, :os_name, :report_items, :start_time, :stop_time, :netbios_name, :dns_name, :mac_address, :open_ports
	attr_writer	:host_name, :os_name, :report_items, :start_time, :stop_time, :netbios_name, :dns_name, :mac_address, :open_ports
end


class NessusReportItem
	attr_reader 	:port, :plugin_name, :plugin_id, :severity, :plugin_data
	attr_writer 	:port, :plugin_name, :plugin_id, :severity, :plugin_data
end

private
def self.parse_xml_output(content)
	# initiate some variables to be used
	hosts = []
	xml = REXML::Document.new(content.to_s)
      
	# loop through all hosts
	REXML::XPath.match(xml,"/NessusClientData/Report/ReportHost").each do |host|
		
		current_host = NessusScannedHost.new()
		current_host.host_name	= host.elements['HostName'].text
		current_host.os_name  	= host.elements['os_name'].text
		current_host.start_time	= host.elements['startTime'].text
		current_host.stop_time	= host.elements['stopTime'].text
		current_host.dns_name	= host.elements['dns_name'].text
		current_host.open_ports	= host.elements['num_ports'].text
		current_host.mac_address = host.elements['mac_addr'].text
		current_host.netbios_name = host.elements['netbios_name'].text
		
		current_host.report_items = {}
	
		
		# Step through each report item for this host
		REXML::XPath.each(host, "#{host.xpath}//ReportItem") do |report_node| # TODO: Improve me...
			
			report_item = NessusReportItem.new()
			
			report_item.port 		= report_node.elements['port'].text
			report_item.severity		= report_node.elements['severity'].text
			report_item.plugin_name	= report_node.elements['pluginName'].text
			report_item.plugin_id	= report_node.elements['pluginID'].text
			report_item.plugin_data	= report_node.elements['data'].text.gsub(/\\n/, "\n").strip
			
			
			# Check if the report_items hash already contains a array on the selected port
			# if not, create one...
			current_host.report_items[report_item.port] = Array.new() if current_host.report_items[report_item.port].nil?
			current_host.report_items[report_item.port] << report_item if report_item.plugin_id != "0"
		end
		
		# Append the host to the "big hosts" list
		hosts << current_host

	end
	
	return hosts

end

  public
  
  # The framework will call this function if the user selects this plugin from
  # the dropdown list and uploads a file.
  # @returns true if the operation was successful, false otherwise
  def self.import(params={})
	file_content = File.read( params[:file].fullpath )
	results = parse_xml_output(file_content)

	# get the "nessus output" category instance or create it if it does not exist
	category = Category.find_by_name('Nessus output') 
	if (category.nil?)
		category = Category.new( :name => 'Nessus output')
		category.save
	end

	results.each do |host|
		host_node = Node.new( :label => host.host_name)
		host_node.save

		# Depending on the configuration file, we add a note which contains additional 
		# information about the host...
		if CONFIG['add_host_details'] then
			
			
			node_content = ""
			if CONFIG['parse_host_details'] then
				node_content << "\n#[Start]#\n #{host.start_time}\n"
				node_content << "\n#[Finish]#\n #{host.stop_time}\n"
				node_content << "\n#[Host name]#\n #{host.host_name}\n"
				node_content << "\n#[DNS name]#\n #{host.dns_name}\n"
				node_content << "\n#[Netbios name]#\n #{host.netbios_name}\n"
				node_content << "\n#[OS]#\n #{host.os_name}\n"
				node_content << "\n#[MAC Address]#\n #{host.mac_address}\n"
				node_content << "\n#[Open Ports]#\n #{host.open_ports}\n"
			else
				node_content << "Start: #{host.start_time}\n"
				node_content << "Finish: #{host.stop_time}\n"
				node_content << "Host name: #{host.host_name}\n"
				node_content << "DNS name: #{host.dns_name}\n"
				node_content << "Netbios name: #{host.netbios_name}\n"
				node_content << "OS: #{host.os_name}\n"
				node_content << "MAC Address: #{host.mac_address}\n"
				node_content << "Open Ports: #{host.open_ports}\n"
			end
			
			Note.new(
				:node_id => host_node.id,
				:author => 'Nessus Import',
				:category_id => category.id,
				:text => node_content
			).save	
			
		end

		# step through each report_item and create a new port_node
		host.report_items.each do |port, report_items|
			# Add a node for the port
			port_node = Node.new(:parent_id => host_node.id, :label => port)
			port_node.save
			
			

			
			report_items.each do |report_item|
				node_content = ""
				
				# Create the node text, this is ugly code, maybe we can find something 
				# which works better...
				
				if CONFIG['add_title'] then 
					node_content = "#[Title]#\n"
					node_content << report_item.plugin_name
				end
				
				if CONFIG['add_data'] and CONFIG['parse_data'] == false
					node_content << "\n\n#[Data]#\n"
					node_content << report_item.plugin_data
				end
				
				if CONFIG['add_data'] and CONFIG['parse_data'] 
					report_item.plugin_data.gsub!(/Synopsis :\n/, "\n\n#[Synopsis]#")
					report_item.plugin_data.gsub!(/Description :\n/, "#[Description]#")
					report_item.plugin_data.gsub!(/Risk factor :\n/, "#[RiskFactor]#")
					report_item.plugin_data.gsub!(/Plugin output :\n/, "#[PluginOutput]#")
					report_item.plugin_data.gsub!(/Solution :\n/, "#[Solution]#")
					
					
					# Some nessus plugins, for example "traceroute" don't start with Synopsis, Description or Solution. In this
					# case we add "#[Description]#" by ourself
					report_item.plugin_data.insert(0, "#\n\n#[Description]#\n") if report_item.plugin_data[0,4] != "\n\n#["

					node_content << report_item.plugin_data
				end
				
				if CONFIG['add_severity'] then
					node_content << "\n\n#[Severity]#\n"
					node_content << report_item.severity
				end
				
				if CONFIG['add_pluginID'] then
					node_content << "\n\n#[PluginID]#\n"
					node_content << report_item.plugin_id
				end
				
				#add the nessus output for the host as notes to the node
				Note.new(
					:node_id => port_node.id,
					:author => 'Nessus Import',
					:category_id => category.id,
					:text => node_content
				).save	
			end
			
		end

	end
    
    return true
  end
end
