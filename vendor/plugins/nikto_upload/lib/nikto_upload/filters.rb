module NiktoUpload  
  private
  @@logger=nil

  public
    
    # This method will be called by the framework when the user selects your 
    # plugin from the drop down list of the 'Import from file' dialog
  def self.import(params={})
    file_content = File.read( params[:file] )
    file_name = File.basename(params[:file])

    # Hack because the Nikto file isn't correctly formatted yet (https://trac.assembla.com/Nikto_2/ticket/229)
    xml_arr = file_content.split("\n")
    xml_arr[2,0] = "<nikto>"
    xml_arr << "</nikto>"

    xml = xml_arr.join

    # every note we create will be assigned to this author
    author = Configuration.author

    # get the note category instance or create it if it does not exist
    category = Category.find_or_create_by_name( Configuration.category )

    @@logger = params.fetch(:logger, Rails.logger)

    @@logger.info{ 'Parsing Nikto output...' }
    doc = Nokogiri::XML(xml)
    @@logger.info{ 'Done.' }

    doc.xpath('/nikto/niktoscan/scandetails').each do |scan_details|
      if scan_details.has_attribute? "sitename"
        node_name = scan_details['sitename']
      else
        node_name = scan_details['siteip']
      end

      node_name = node_name + " - " + Configuration.parent_node

      # The rand is good for debugging as it means each node is fairly unique
      #node_name = node_name + " - " + Configuration.parent_node + rand(99).to_s

      @@logger.info{ 'Adding ' + node_name }
      # create the parent node early so we can use it to provide feedback on errors
      parent = Node.find_or_create_by_label(node_name)

      node_text = "#[Details]#\n"
      node_text += "IP = " + scan_details['targetip'] + "\n" if scan_details.has_attribute? "targetip"
      node_text += "Hostname = " + scan_details['targethostname'] + "\n" if scan_details.has_attribute? "targethostname"
      node_text += "Port = " + scan_details['targetport'] + "\n" if scan_details.has_attribute? "targetport"
      node_text += "Banner = " + scan_details['targetbanner'] + "\n" if scan_details.has_attribute? "targetbanner"
      node_text += "Starttime = " + scan_details['starttime'] + "\n" if scan_details.has_attribute? "starttime"
      node_text += "Site Name = " + scan_details['sitename'] + "\n" if scan_details.has_attribute? "sitename"
      node_text += "Site IP = " + scan_details['siteip'] + "\n" if scan_details.has_attribute? "siteip"
      node_text += "Host Header = " + scan_details['hostheader'] + "\n" if scan_details.has_attribute? "hostheader"
      node_text += "Errors = " + scan_details['errors'] + "\n" if scan_details.has_attribute? "errors"
      node_text += "Total Checks = " + scan_details['checks'] + "\n" if scan_details.has_attribute? "checks"

      parent.notes.create(
        :author => author,
        :category => category,
        :text => "#[Title]#\nNikto upload: #{file_name}\n\n#{node_text}")

      # Check for SSL cert tag and add that data in as well
      unless scan_details.at_xpath("ssl").nil?
        ssl_details = scan_details.at_xpath("ssl")
        node_text = "#[Details]#\n"
        node_text += "Ciphers = " + ssl_details['ciphers'] + "\n" if ssl_details.has_attribute? "ciphers"
        node_text += "Issuers = " + ssl_details['issuers'] + "\n" if ssl_details.has_attribute? "issuers"
        node_text += "Info = " + ssl_details['info'] + "\n" if ssl_details.has_attribute? "info"

        parent.notes.create(
          :author => author,
          :category => category,
          :text => "#[Title]#\nSSL Cert Information\n\n#{node_text}")
      end

      scan_details.xpath("item").each do |item|
        item_text = "#[Title]#\n"
        item_text = "Finding\n"
        item_text = "#[Details]#\n"

        item_title = "Unknown"
        item_title = item["id"] if item.has_attribute? "id"
        if item.has_attribute? 'osvdbid'
          if item.has_attribute? 'osvdblink'
            item_text += 'OSVDB = "' + item['osvdbid'] + '":' + item['osvdblink'] + "\n"
          else
            item_text += 'OSVDB = ' + item['osvdbid'] + "\n"
          end
        end

        item_text += "Request Method = " + item['method'] + "\n"  if item.has_attribute? 'method'
        item_text += "Description = " + item.at_xpath("description").text + "\n"  unless item.at_xpath("description").nil?
        item_text += 'Link = "' + item.at_xpath("namelink").text + '":' + item.at_xpath("namelink").text + "\n"  unless item.at_xpath("namelink").nil?
        item_text += 'IP Based Link = "' + item.at_xpath("iplink").text + '":' + item.at_xpath("iplink").text + "\n"  unless item.at_xpath("iplink").nil?

        alert_node = parent.children.find_or_create_by_label(item_title)
        alert_node.notes.create(
          :author => author,
          :category => category,
          :text => item_text)
      end
    end

    @@logger.info("All Done!")
  end
end
