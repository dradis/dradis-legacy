module NexposeUpload  
  private
  @@logger=nil

  public
  
  # This method will be called by the framework when the user selects your 
  # plugin from the drop down list of the 'Import from file' dialog
  def self.import(params={})
    @plugin_author_name = Configuration.author

    @category = Category.find_or_create_by_name(Configuration.category)

    #Create a parent node for the NeXpose output
    @nexpose_node = Node.create(:label => Configuration.node_label)

    @@logger = params.fetch(:logger, Rails.logger)
    @@logger.info('started debugging')

    file_content = File.read( params[:file] )

    doc = Nokogiri::XML(file_content)

    if doc.root.name == 'NeXposeSimpleXML'
      hosts = parse_nexpose_simple_xml(doc)
    else
      error_note = Note.new(
          :node => @nexpose_node,
          :author => @plugin_author_name,
          :category => @category,
          :text => "Document doesn't seem to be a NeXpose simple report. this plugin doesn't do other NeXpose XML types as yet"
      ).save
      return
    end

    hosts.each do |host|
      host_node = Node.create(:label => host['address'], :parent_id => @nexpose_node.id)

      Note.create(
          :node => host_node,
          :author => @plugin_author_name,
          :category => @category,
          :text => "Host Description : #{host['description']} \nScanner Fingerprint certainty : #{host['fingerprint']}"
      )

      generic_findings_node = Node.create(:label => "Generic Findings", :parent_id => host_node.id )

      host['generic_vulns'].each do |id, finding|
        Note.create(
            :node => generic_findings_node,
            :author => @plugin_author_name,
            :category => @category,
            :text => "Finding ID :  #{id} \n \n Finding Refs :\n-------\n #{finding}"
        )
      end

      host['ports'].each do |port_label, findings|
        port_node = Node.create(:label => port_label, :parent_id => host_node.id)

        findings.each do |id, finding|
          Note.create(
              :node => port_node,
              :author => @plugin_author_name,
              :category => @category,
              :text => "Finding ID :  #{id} \n \n Finding Refs :\n-------\n #{finding}"
          )
        end

      end


    end



  end


  def self.parse_nexpose_simple_xml(doc)
    results = doc.search('device')
    hosts = Array.new

    results.each do |host|
      current_host = Hash.new
      current_host['address'] = host['address']
      current_host['fingerprint'] = host.search('fingerprint')[0].nil? ? "N/A" : host.search('fingerprint')[0]['certainty']
      current_host['description'] = host.search('description')[0].nil? ? "N/A" : host.search('description')[0].text


      #So there's two sets of vulns in a NeXpose simple XML report for each host
      #Theres some generic ones at the top of the report
      #And some service specific ones further down the report.
      #So we need to get the generic ones before moving on
      current_host['generic_vulns'] = Hash.new
      host.xpath('vulnerabilities/vulnerability').each do |vuln|
        current_host['generic_vulns'][vuln['id']] = ''


        vuln.xpath('id').each do |id|
          current_host['generic_vulns'][vuln['id']] << id['type'] + " : " + id.text + "\n"
        end

      end


      current_host['ports'] = Hash.new
      host.xpath('services/service').each do |service|
        protocol = service['protocol']
        portid = service['port']

        port_label = protocol + '-' + portid

        current_host['ports'][port_label] = Hash.new

        service.xpath('vulnerabilities/vulnerability').each do |vuln|
          current_host['ports'][port_label][vuln['id']] = ''
          vuln.xpath('id').each do |id|
            current_host['ports'][port_label][vuln['id']] << id['type'] + " : " + id.text + "\n"
          end
        end

      end

      hosts << current_host
    end
    return hosts
  end

end
