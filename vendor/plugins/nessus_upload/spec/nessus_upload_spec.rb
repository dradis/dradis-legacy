require 'spec_helper'

module NessusUploadSpecHelper
  XML1=<<EOXML01
<?xml version="1.0" ?>
<NessusClientData_v2>
<Report name="RSpec-01">
  <ReportHost name="10.0.0.1">
    <HostProperties>
      <tag name="HOST_END">Tue Aug  9 09:59:24 2011</tag>
      <tag name="HOST_START">Tue Aug  9 09:50:18 2011</tag>
    </HostProperties>
    <ReportItem
      port="0"
      svc_name="general"
      protocol="udp"
      severity="1"
      pluginID="10287"
      pluginName="Traceroute Information"
      pluginFamily="General">
    </ReportIem>
  </ReportHost>
</Report>
</NessusClientData_v2>
EOXML01
end

describe 'NessusUpload plugin' do
  include NessusUploadSpecHelper

  # These are the properties we need to support:
  # host.name                 The name given at scan time, usually an IP address
  # host.ip                   The ip address of the host
  # host.fqdn                 The full qualified domain name of the host
  # host.operating_system     The OS of the system if detected
  # host.mac_address          The mac address if the scanned system was on the same subnet
  # host.netbios_name         The netbios name of the system
  # host.scan_start_time      The date/time the scan started
  # host.scan_stop_time       The date/time the scan ended
  it 'Nessus::Host responds to all the expected fields' do
    doc = Nokogiri::XML( XML1 )
    host = Nessus::Host.new( doc.xpath('/NessusClientData_v2/Report/ReportHost').first )
    host.name.should eq('10.0.0.1')
    host.scan_start_time eq('Tue Aug 9 09:59:24 2011')
  end

  pending 'Nessus::Host should provide access to each of its ReportItems'
end