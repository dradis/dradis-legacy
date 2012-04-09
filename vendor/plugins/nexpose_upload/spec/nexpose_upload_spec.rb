require 'spec_helper'

module NexposeUploadSpecHelper
  XML1=<<EOXML01
  <NeXposeSimpleXML version="1.0">
  <generated>20111128T142609232</generated>
  <devices>
  <device address="1.1.1.1">
  <fingerprint certainty="0.80">
  <description>Linux 2.6.9-89.ELsmp</description>
  <vendor>Linux</vendor>
  <family>Linux</family>
  <product>Linux</product>
  <version>0.0.0</version>
  <device-class></device-class>
  <architecture>i686</architecture>
  </fingerprint>
  <vulnerabilities>
  </vulnerabilities>
  <services>
  <service name="NTP" port="000" protocol="udp">
  <fingerprint certainty="0.20">
  <description>NTP 4.2</description>
  <vendor></vendor>
  <family>NTP</family>
  <product>NTP</product>
  <version>4.2</version>
  </fingerprint>
  <vulnerabilities>
  <vulnerability id="ntpd-crypto" resultCode="VV">
  <id type="cve">CVE-2009-1252</id>
  <id type="bid">35017</id>
  <id type="secunia">35137</id>
  <id type="secunia">35138</id>
  <id type="secunia">35166</id>
  <id type="secunia">35169</id>
  <id type="secunia">35243</id>
  <id type="secunia">35253</id>
  <id type="secunia">35308</id>
  <id type="secunia">35336</id>
  <id type="secunia">35388</id>
  <id type="secunia">35416</id>
  <id type="secunia">35630</id>
  <id type="secunia">37470</id>
  <id type="secunia">37471</id>
  <id type="url">http://bugs.ntp.org/1151</id>
  <id type="url">http://www.kb.cert.org/vuls/id/853097</id>
  <id type="url">https://lists.ntp.org/pipermail/announce/2009-May/000062.html</id>
  </vulnerability>
  <vulnerability id="ntp-clock-radio, he cannot afford, wah wah wee wah" resultCode="VE">
  </vulnerability>
  </vulnerabilities>
  </service>
  </services>
  </device>
  </devices>
  </NeXposeSimpleXML>
EOXML01
end

describe 'NexposeUpload plugin' do
  include NexposeUploadSpecHelper

  # Breakdown of each test line:
  # Ensure the hosts are not empty
  # Ensure the first array row (which is a hash) has the key 'address'
  # Ensure the first array row has the key 'fingerprint'
  # Ensure the first array row has the key 'description'
 
  it 'NexposeUpload responds to all the expected fields' do
    doc = Nokogiri::XML( NexposeUploadSpecHelper::XML1 )
    hosts = NexposeUpload.parse_nexpose_simple_xml(doc)
    # Begin tests
    hosts.length.should > 0
    hosts.first.keys.should include('address')
    hosts.first.keys.should include('fingerprint')
    hosts.first.keys.should include('description')
    hosts.first.keys.should include('generic_vulns')
    hosts.first['generic_vulns'].keys.length.should eq 0
    hosts.first.keys.should include('ports')
    hosts.first['ports'].keys.length >= 1
    hosts.first['ports']["udp-000"].keys.should  include("ntpd-crypto") and ("ntp-clock-radio, he cannot afford, wah wah wee wah")
  end

  pending 'NexposeUpload should provide access to each of its ReportItems'
end