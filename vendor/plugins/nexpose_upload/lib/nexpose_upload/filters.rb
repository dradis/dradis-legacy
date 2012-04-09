module NexposeUpload  
  private
  @@logger=nil

  public

  # This method will be called by the framework when the user selects your
  # plugin from the drop down list of the 'Import from file' dialog
  def self.import(params={})
    file_content = File.read( params[:file] )
    @@logger = params.fetch(:logger, Rails.logger)
    @@logger.info('started debugging')

    # get the "NeXpose Scanner output" category instance or create it if it does not exist
    @category = Category.find_or_create_by_name(Configuration.category)
    # every note we create will be assigned to this author
    @author = Configuration.author
    # create the parent early so we can use it to provide feedback and errors
    @parent = Node.find_or_create_by_label(Configuration.parent_node)


    @@logger.info{'Parsing NeXpose output file...'}
    doc = Nokogiri::XML( file_content )
    @@logger.info{'Parsing done'}

    if doc.root.name == 'NeXposeSimpleXML'
      @@logger.info{'NeXpose-Simple format detected'}
      hosts = parse_nexpose_simple_xml(doc)
      notes_simple(hosts)
    elsif doc.root.name == 'NexposeReport'
      @@logger.info{'NeXpose-Full format detected'}
      hosts = parse_nexpose_full_xml(doc)
      notes_full(hosts)
    else
      error_note = Note.new(
          :node => @parent,
          :author => @author,
          :category => @category,
          :text => "Document doesn't seem to be in either a NeXpose-Simple or NeXpose-Full XML format."
      ).save
      return
    end
  end
  
  
  def self.notes_simple(hosts)
    return if hosts.nil?
    hosts.each do |host|
      host_node = @parent.children.find_or_create_by_label_and_type_id(host['address'], Node::Types::HOST)
      Note.create(
          :node => host_node,
          :author => @author,
          :category => @category,
          :text => "Host Description : #{host['description']} \nScanner Fingerprint certainty : #{host['fingerprint']}"
      )

      generic_findings_node = Node.create(:label => "Generic Findings", :parent_id => host_node.id )

      host['generic_vulns'].each do |id, finding|
        Note.create(
            :node => generic_findings_node,
            :author => @author,
            :category => @category,
            :text => "Finding ID :  #{id} \n \n Finding Refs :\n-------\n #{finding}"
        )
      end

      host['ports'].each do |port_label, findings|
        port_node = Node.create(:label => port_label, :parent_id => host_node.id)

        findings.each do |id, finding|
          Note.create(
              :node => port_node,
              :author => @author,
              :category => @category,
              :text => "Finding ID :  #{id} \n \n Finding Refs :\n-------\n #{finding}"
          )
        end

      end
    end    
  end
  
  def self.notes_full(hosts)
    return if hosts.nil?
    scan_node = Node.create(:label => 'Scan Summary', :parent_id => @parent.id)

    hosts['scan'].each do |scan|
      scan['index'].each do |idx, val|
        Note.create(
          :node => scan_node,
          :author => @author,
          :category => @category,
          :text => "Scan Id: #{val['id']} \nScan Name: #{val['name']} \nScan Start Time: #{val['startTime']} \nScan End Time: #{val['endTime']} \nScan Status: #{val['status']}"
        )
      end
    end

    hosts['nodes'].each do |nodes|
      nodes['index'].each do |nodek, nodev|
        nodes_node = @parent.children.find_or_create_by_label_and_type_id("#{nodek}", Node::Types::HOST)
        str = ''
        nodev.each {|k,v| str << "#{v}"}
        Note.create(
          :node => nodes_node,
          :author => @author,
          :category => @category,
          :text => str
        )
      end
    end
    
    vulns_node = Node.create(:label => "Definitions", :parent_id => @parent.id)
    hosts['vulns'].each do |vulns|
      vulns['index'].each do |vulnk, vulnv|
        str = ''
        vulnv.each {|k,v| str << "#{v}"}
        Note.create(
          :node => vulns_node,
          :author => @author,
          :category => @category,
          :text => str
        )
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

  def self.get_tests(node)
    tstr = "\n"
    tests = node.xpath('tests/test')
    tests.each do |test|
      if test['status'] != 'not-vulnerable'
        tstr << "Status: %{color:red}#{test['status']}%\n"
        tstr << "Vuln ID: #{test['id']}\n"
        @vuln_list.push("#{test['id']}") if !@vuln_list.include?("#{test['id']}")
        paragraph = test.xpath('Paragraph')
        paragraph.each do |para|
          tstr << "Test Description: #{para.text}" if para && para.respond_to?('text')
        end
      end 
    end

    if tstr.include?("Status")
      tstr << "\n"
    else
      tstr = ''
    end
    return tstr
  end

  def self.get_endpoints(node)

    return if node.nil?

    ep_str = ''
    sstr = ''
    fstr = ''
    cstr = ''
     
    ep_str << "\nEndpoints\n\n"
    end_point = node.xpath('endpoints/endpoint')
    end_point.each do |ep|
      svcs = ep.xpath('services/service')
      svcs.each do |svc|
        svc_name = svc['name'].empty? ? "Unknown" : svc['name']
        sstr << "Service Name: #{svc_name}\n"

        fingerprints = svc.xpath('fingerprints/fingerprint')
        fingerprints.each do |fp|
          cert = fp['certainty'].empty? ? "Unknown" : fp['certainty']
          prod = fp['product'].empty? ? "Unknown" : fp['product']
          fstr << "Fingerprint - certainty: #{cert}, product #{prod}\n"
        end

        configurations = svc.xpath('configuration/config')
        configurations.each do |config|
          cn = config['name'].empty? ? "Unknown" : config['name']
          cd  = config.respond_to?('inner_html') ? config.inner_html : ''
          cstr << "Config Name: #{cn}\, "
          cstr << "Config Details: #{cd}\n"
        end
      end

      # Some top level, endpoint data
      protocol = ep['protocol'] if not ep.nil?
      port = ep['port'] if not ep.nil?
      status = ep['status'] if not ep.nil?

      # Finalize/prep the string for return
      ep_str << self.normalize_ep(protocol, port, status)
      ep_str << sstr
      ep_str << cstr
      ep_str << fstr
      ep_str << "\n\n"

      # Reset the various strings (clear them)
      sstr = ''
      fstr = ''
      cstr = ''
    end
    return ep_str
  end

  def self.normalize_ep(*vals)
    protocol, port, status, config_name, config_details = vals
    str = ''
    str << "EndPoint\n"
    str << "========\n"
    str << "Protocol: #{protocol}\n"
    str << "Port: #{port}\n"
    str << "Status: #{status}\n"
    return str
  end

  def self.get_software(node)

    return if node.nil?
    return if node.xpath('software/fingerprint').empty?

    sw_str = ''

    title = "\nSoftware Fingerprints\n"
    sw_str << "#{title}" + "=" * title.length + "\n"
    sw = node.xpath('software/fingerprint')
    sw.each do |fp|
      sw_str << "Certainty: #{fp['certainty']}\n" if !fp['certainty'].nil?
      sw_str << "Software-Class: #{fp['software-class']}\n" if !fp['software-class'].nil?
      sw_str << "Vendor: #{fp['vendor']}\n" if !fp['vendor'].nil?
      sw_str << "Family: #{fp['family']}\n" if !fp['family'].nil?
      sw_str << "Product: #{fp['product']}\n" if !fp['product'].nil?
      sw_str << "Version: #{fp['version']}\n" if !fp['version'].nil?
      sw_str << "\n"
    end
    sw_str << "\n"
    return sw_str
  end

  def self.get_description(vuln)

    return if vuln.nil?

    str = "\n"
    title = "Description"
    str << "#{title}\n" + "=" * title.length  + "\n"
    descriptions = vuln.xpath('description')
    descriptions.each do |desc|
      cbe = desc.xpath('ContainerBlockElement')
      cbe.each do |cb|
        para = cb.xpath('Paragraph')
        para.each do |p|
          str << p
        end
      end
    end
    str << "\n"
    return str
  end

  def self.get_solution(vuln)
    return if vuln.nil?
    str = "\n"
    title = "Solution"
    str << "#{title}\n" + "=" * title.length + "\n"
    solutions = vuln.xpath('solution')
    solutions.each do |solution|
      cbe = solution.xpath('ContainerBlockElement')
      cbe.each do |cb|
        paragraph = cb.xpath('Paragraph')
        paragraph.each do |para|
          str << "#{para.text}" if para && para.respond_to?('text')
        end
      end
    end
    str << "\n"
    return str
  end

  def self.parse_nexpose_full_xml(doc)
    @vuln_list = []
    details = {}
    hosts = Array.new
    scans = doc.xpath('//scans/scan')
    nodes = doc.xpath('//nodes/node')
    vuln_defs = doc.xpath('//VulnerabilityDefinitions/vulnerability')

    #
    # Beginning of scan hash item creation 
    #
    scan_items = []
    scan_hash = {}
    scans.each_with_index do |scan, idx|
      id = scan['id']
      name = scan['name'].to_s || '' 
      startTime = scan['startTime'].to_s || ''
      endTime = scan['endTime'].to_s || ''
      status = scan['status'].to_s || ''
      next if id.nil?
      scan_hash = {
        'index' => { idx.to_s => {
                          'id' => id,
                          'name' => name,
                          'startTime' => startTime,
                          'endTime'   => endTime,
                          'status'    => status
                          }
                }
      }

      scan_items.push(scan_hash)
    end

    details['scan'] = scan_items
    # End of scan parsing and hash item creation

    node_items = []
    node_hash = {}
    nodes.each_with_index do |node, index|
      address = node['address'] || 'N/A'
      status = node['status'] || 'N/A'
      device_id = node['device-id'] || 'N/A'
      hw_addr = node['hardware-address'] || 'N/A'
      names = node.at_xpath('names').nil? ? "No Names" : node.at_xpath('names').text
      tests = get_tests(node)

      idx = tests.empty? ? "Node-#{index.to_s} #{address}" : "!!! Node-#{index.to_s} #{address}"
      ep = get_endpoints(node)
      software = get_software(node)
      node_hash = {
          'index' => { "#{idx}" => {
                               'tests' => "#{tests}\n",
                               'status'  => "Status: #{status}\n",
                               'device-id' => "Device ID: #{device_id}\n",
                               'hardware-address' => "Hardware Address: #{hw_addr}\n",
                               'names' => "Names: #{names}\n",
                               'software' => software,
                               'endpoints' => ep
                              }
                  }
      }

      node_items.push(node_hash)
    end
    details['nodes'] = node_items

    vuln_hash = {}
    vuln_items = []
    vuln_defs.each_with_index do |vuln, index|
      vuln_id = vuln['id'] || 'N/A'
      vuln_title = vuln['title'] || 'N/A'
      vuln_sev = vuln['severity'] || 'N/A'
      vuln_pcisev = vuln['pciSeverity'] || 'N/A'
      vuln_cvssScore = vuln['cvssScore'] || 'N/A'
      vuln_cvssVec = vuln['cvssVector'] || 'N/A'
      vuln_published = vuln['published'] || 'N/A'
      vuln_added = vuln['added'] || 'N/A'
      vuln_modified = vuln['modified'] || 'N/A'
      desc = get_description(vuln)
      ref_str = "\n"
      ref_title = "References"
      ref_str << "#{ref_title}\n" + "=" * ref_title.length + "\n"
      vuln.xpath('references/reference').each {|ref| ref_str << "#{ref['source']}\n" if ref['source']} && ref_str << "\n"
      tags_str = "\n"
      tags_title = "Tags"
      tags_str << "#{tags_title}\n" + "=" * tags_title.length + "\n"
      vuln.xpath('tags/tag').each {|tag| tags_str << "#{tag.text}\n" if tag && tag.respond_to?('text')} && tags_str << "\n"
      solution = get_solution(vuln)
      vuln_hash = {
        'index' => { "#{vuln_id.to_s}" => {
                                  'vtitle' => "Title: #{vuln_title}\n",
                                  'vsev' => "Severity: #{vuln_sev}\n",
                                  'vpcisev' => "PCI Severity: #{vuln_pcisev}\n",
                                  'vcvssScore' => "CVSS Score: #{vuln_cvssScore}\n",
                                  'vcvssVec' => "CVSS Vector: #{vuln_cvssVec}\n",
                                  'vpublished' => "Published: #{vuln_published}\n",
                                  'vadded' => "Added: #{vuln_added}\n",
                                  'vmodified' => "Modified: #{vuln_modified}\n",
                                  'description' => "#{desc}\n",
                                  'references'  => "#{ref_str}\n",
                                  'tags' => "#{tags_str}\n",
                                  'solution' => "#{solution}\n",
            }
        }
      }
     vuln_items.push(vuln_hash) if @vuln_list.include?(vuln_id.downcase)
    end
    details['vulns'] = vuln_items
    return details
  end # self.parse_nexpose_full_xml ends
end
