module RetinaUpload  
  private
  @@logger=nil

  public
  
  # This method will be called by the framework when the user selects your 
  # plugin from the drop down list of the 'Import from file' dialog
  def self.import(params={})
    #require 'ruby-debug19'
    @plugin_author_name = Configuration.author

    @category = Category.find_or_create_by_name(Configuration.category)

    @retina_node = Node.create(:label => Configuration.node_label)

    @@logger = params.fetch(:logger, Rails.logger)
    @@logger.info('Started Upload')


    file_content = File.read( params[:file] )

    doc = Nokogiri::XML(file_content)

    hosts = parse_retina_xml(doc)

    hosts.each do |host|
      @@logger.info("Starting creating notes for host #{host['address']}")
      host_node = Node.create(:label => host['address'], :parent_id => @retina_node.id)
      
      Note.create(
        :node => host_node,
        :author => @plugin_author_name,
        :category => @category,
        :text => '#[Host Information]#' + "\n\n*DNS Name* - #{host['dnsName']} \n*NetBIOS Name* - #{host['netBIOSName']}"
      )



      host['vulns'].each do |vuln_id, vuln|
        
        Note.create(
            :node => host_node,
            :author => @plugin_author_name,
            :category => @category,
            :text => '#[Title]#' + "\n#{vuln['title']}\n\n" + '#[Description]#' + "\n\n#{vuln['description']}\n\n" + '#[Recommendation]#' + "\n\n#{vuln['recommendation']}\n\n" + '#[CVSS]#' + "\n\n#{vuln['cvss']}\n\n" + '#[CVE]#' + "\n\n#{vuln['cve']}\n\n"
        )
      end

    end


  end

  def self.parse_retina_xml(doc)
    results = doc.xpath('//hosts/host')

    hosts = Array.new

    results.each do |host|
      current_host = Hash.new
      current_host['address'] = host.xpath('ip').text
      current_host['netBIOSName'] = host.xpath('netBIOSName').text
      current_host['dnsName'] = host.xpath('dnsName').text
      current_host['vulns'] = Hash.new
      host.xpath('audit').each do |vuln|
        vuln_id = vuln.xpath('rthID').text
        current_host['vulns'][vuln_id] = Hash.new
        current_host['vulns'][vuln_id]['cve'] = vuln.xpath('cve').text
        current_host['vulns'][vuln_id]['title'] = vuln.xpath('name').text
        current_host['vulns'][vuln_id]['description'] = vuln.xpath('description').text
        current_host['vulns'][vuln_id]['recommendation'] = vuln.xpath('fixInformation').text
        current_host['vulns'][vuln_id]['cvss'] = vuln.xpath('cvssScore').text
      end
    hosts << current_host
    end
    hosts
  end

end
