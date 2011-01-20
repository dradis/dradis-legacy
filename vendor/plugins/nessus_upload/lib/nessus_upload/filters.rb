 require 'nessus/parser'

module NessusUpload  

    CONF_FILE       = Rails.root.join('config', 'nessus_upload.yml')
    CONFIG          = YAML::load( File.read CONF_FILE )
    @@logger        = nil

    public
  
    # The framework will call this function if the user selects this plugin from
    # the dropdown list and uploads a file.
    # @returns true if the operation was successful, false otherwise
    def self.import(params={})
	    file_content    = File.read(params[:file].fullpath)
        @@logger        = params.fetch(:logger, RAILS_DEFAULT_LOGGER)

        @@logger.debug{'Parsing nessus output file'}
	    parser = Nessus::Parser.parse_string(file_content)
        @@logger.debug{'Parsing done'}

        # Read the template file which are needed to create the note elements
        report_item_template = File.read(Rails.root.join('vendor', 'plugins', 'nessus_upload', 'item_template.txt'))
        host_item_template   = File.read(Rails.root.join('vendor', 'plugins', 'nessus_upload', 'host_template.txt'))


	    # get the "Nessus Output" category instance or create it if it does not exist
	    category = Category.find_or_create_by_name('Nessus output') 
        parent   = Node.create(:label => "#{File.basename(params[:file].fullpath)} - Nessus scan")

		parser.reports.each do |report|
            report_label = report.name
            report_node  = Node.new(:label => report_label, :parent_id => parent.id)
            report_node.save

            report.hosts.each do |host|
                host_label = host.name
                host_label = "#{host_label} (#{host.fqdn})" if host.fqdn
                host_node = Node.new(:label => host_label, :parent_id => report_node.id)

                host_node.save
                    
                    
                note_template   = ERB.new(host_item_template,0,'>')
                node_text       = note_template.result(binding)
                Note.new(
                     :node_id     => host_node.id,
                     :author      => "Nessus",
                     :category_id => category.id,
                     :text        => node_text
                ).save


                host.report_items.each do |report_item|
                    next if report_item.plugin_id == "0"
                    item_label = "#{report_item.port}/#{report_item.protocol}"
                    item_node  = Node.find_or_create_by_label(item_label, {:parent_id => host_node.id})

                    note_template   = ERB.new(report_item_template,0,'>')
                    node_text       = note_template.result(binding)
                    Note.new(
                        :node_id     => item_node.id,
                        :author      => "Nessus", 
                        :category_id => category.id,
                        :text        => node_text 
                    ).save
    

                end


            end

        end	
    
        return true
    end
end
