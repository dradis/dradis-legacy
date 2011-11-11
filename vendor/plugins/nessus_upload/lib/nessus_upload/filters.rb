require 'nessus/host'
require 'nessus/report_item'

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
    doc = Nokogiri::XML( file_content )
    @@logger.info{'Parsing done'}

    # Read the template file which are needed to create the note elements
    report_item_template = File.read(Rails.root.join('vendor', 'plugins', 'nessus_upload', 'item_template.txt'))
    host_item_template   = File.read(Rails.root.join('vendor', 'plugins', 'nessus_upload', 'host_template.txt'))

    # get the "Nessus Output" category instance or create it if it does not exist
    category = Category.find_or_create_by_name( NessusUpload::Configuration.category )
    # every note we create will be assigned to this author
    author = Configuration.author
    # create the parent early so we can use it to provide feedback on errors
    parent = Node.find_or_create_by_label( Configuration.parent_node)

    if doc.xpath('/NessusClientData_v2/Report').empty?
      error = "No reports were detected in the uploaded file (/NessusClientData_v2/Report). Ensure you uploaded a Nessus XML v2 (.nessus) report."
      @@logger.fatal{ error }
      parent.notes.create(
        :author => Configuration.author,
        :category_id => category.id,
        :text => error)
      return false
    end

    doc.xpath('/NessusClientData_v2/Report').each do |xml_report|
      report_label = xml_report.attributes['name'].value
      @@logger.info{ "Processing report: #{report_label}" }
      report_node = parent.children.find_or_create_by_label(report_label)
      
      xml_report.xpath('./ReportHost').each do |xml_host|
        host_label = xml_host.attributes['name'].value
        host_label += " (#{xml_host.attributes['fqdn'].value})" if xml_host.attributes['fqdn']

        host_node = report_node.children.find_or_create_by_label_and_type_id(host_label, Node::Types::HOST)
        @@logger.info{ "\tHost: #{host_label}" }

        # Nessus::Hosts translates complex XML format into a simple Ruby object
        # that can be used inside ERB
        host = Nessus::Host.new(xml_host)
        note_template   = ERB.new(host_item_template,0,'>')
        node_text       = note_template.result(binding)
        Note.create(
          :node_id     => host_node.id,
          :author      => author,
          :category_id => category.id,
          :text        => node_text
        )
      
        xml_host.xpath('./ReportItem').each do |xml_report_item|
          next if xml_report_item.attributes['pluginID'].value == "0"

          item_label = xml_report_item.attributes['port'].value
          item_label += "/"
          item_label += xml_report_item.attributes['protocol'].value
          item_node  = host_node.children.find_or_create_by_label(item_label)

          # Nessus::ReportItem translate complex XML format into a simple Ruby
          # object that can be used inside ERB
          report_item = Nessus::ReportItem.new(xml_report_item)
          note_template   = ERB.new(report_item_template,0,'>')
          node_text       = note_template.result(binding)
          Note.create(
            :node_id     => item_node.id,
            :author      => author,
            :category_id => category.id,
            :text        => node_text 
          )
        end #/ReportItem

      end #/ReportHost
      @@logger.info{ "Report processed." }

    end	#/Report
    
    return true
  end
end
