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

  it 'Nessus::Host responds to all the expected fields' do
    doc = Nokogiri::XML( XML1 )
    host = Nessus::Host.new( doc.xpath('/NessusClientData_v2/Report/ReportHost').first )
    host.name.should eq('10.0.0.1')
  end
end