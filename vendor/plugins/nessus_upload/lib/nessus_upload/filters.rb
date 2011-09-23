require 'nessus/parser'

module NessusUpload  
  @@logger = nil

  public

  # The framework will call this function if the user selects this plugin from
  # the dropdown list and uploads a file.
  # @returns true if the operation was successful, false otherwise
  def self.import(params={})
    file_content    = File.read( params[:file] )
    @@logger        = params.fetch(:logger, Rails.logger)

    @@logger.info{'Parsing nessus output file...'}
    parser = Nessus::Parser.parse_string(file_content)
    @@logger.info{'Parsing done'}

    # Read the template file which are needed to create the note elements
    report_item_template = File.read(Rails.root.join('vendor', 'plugins', 'nessus_upload', 'item_template.txt'))
    host_item_template   = File.read(Rails.root.join('vendor', 'plugins', 'nessus_upload', 'host_template.txt'))

    # get the "Nessus Output" category instance or create it if it does not exist
    category = Category.find_or_create_by_name( NessusUpload::Configuration.category )
    # create the parent early so we can use it to provide feedback on errors
    parent = Node.find_or_create_by_label( Configuration.parent_node)

    if parser.reports.empty?
      error = "No reports were detected in the uploaded file (//NessusClientData_v2/Report). Ensure you uploaded a Nessus XML v2 (.nessus) report."
      @@logger.fatal{ error }
      parent.notes.create(
        :author => Configuration.author,
        :category_id => category.id,
        :text => error)
      return false
    end

    parser.reports.each do |report|
      @@logger.info{ "Processing report: #{report.name}" }
      report_label = report.name
      report_node = parent.children.find_or_create_by_label(report_label)
      
      report.hosts.each do |host|
        host_label = host.name
        host_label = "#{host_label} (#{host.fqdn})" if host.fqdn
        host_node = report_node.children.find_or_create_by_label_and_type_id(host_label, Node::Types::HOST)
        @@logger.info{ "\tHost: #{host_label}" }
          
        note_template   = ERB.new(host_item_template,0,'>')
        node_text       = note_template.result(binding)
        Note.create(
          :node_id     => host_node.id,
          :author      => Configuration.author,
          :category_id => category.id,
          :text        => node_text
        )
      
        host.report_items.each do |report_item|
          next if report_item.plugin_id == "0"
          item_label = "#{report_item.port}/#{report_item.protocol}"
          item_node  = host_node.children.find_or_create_by_label(item_label)
      
          note_template   = ERB.new(report_item_template,0,'>')
          node_text       = note_template.result(binding)
          Note.create(
            :node_id     => item_node.id,
            :author      => Configuration.author, 
            :category_id => category.id,
            :text        => node_text 
          )
        end

      end #/report
      @@logger.info{ "Report processed." }

    end	#/parser
    
    return true
  end
end
