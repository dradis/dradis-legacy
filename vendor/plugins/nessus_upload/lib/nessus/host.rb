module Nessus
  # This class represents each of the /NessusClientData_v2/Report/ReportHost
  # elements in the Nessus XML document.
  #
  # It provides a convenient way to access the information scattered all over
  # the XML in attributes and nested tags.
  #
  # Instead of providing separate methods for each supported property we rely
  # on Ruby's #method_missing to do most of the work.
  class Host
    # Accepts an XML node from Nokogiri::XML.
    def initialize(xml_node)
      @xml = xml_node
    end

    # List of supported tags. They are all desdendents of the ./HostProperties
    # node.
    def supported_tags
      [
        :ip, :fqdn, :operating_system, :mac_address, :netbios_name,
        :scan_start_time, :scan_stop_time
      ]
    end

    # The name of this host, given as attribute to the ReportHost element
    def name
      @xml.attributes['name'].value
    end

    # Each of the entries associated with this host. Returns an array of
    # Nessus::ReportItem objects
    def report_items
      @xml.xpath('./ReportItem').collect { |xml_report_item| ReportItem.new(xml_report_item) }
    end

    # This method is invoked by Ruby when a method that is not defined in this
    # instance is called.
    #
    # In our case we inspect the @method@ parameter and try to find the
    # corresponding <tag/> element inside the ./HostProperties child.
    def method_missing(method, *args)
      # We could remove this check and return nil for any non-recognized tag.
      # The problem would be that it would make tricky to debug problems with
      # typos. For instance: <>.potr would return nil instead of raising an
      # exception
      unless supported_tags.include?(method)
        super
        return
      end
      
      # translation of Host properties
      translations_table = {
        :ip => 'host-ip',
        :fqdn => 'host-fqdn',
        :operating_system => 'operating-system',
        :mac_address => 'mac-address',
        :netbios_name => 'netbios-name',
        :scan_start_time => 'HOST_START',
        :scan_stop_time => 'HOST_END'
      }
      method_name = translations_table.fetch(method, method.to_s)

      property = @xml.xpath("./HostProperties/tag[@name='#{method_name}']").first
      if property
        return property.text
      else
        return nil
      end
    end
  end
end
