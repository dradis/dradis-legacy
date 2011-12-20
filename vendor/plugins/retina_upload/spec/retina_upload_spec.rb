require 'spec_helper'

module RetinaUploadSpecHelper
  XML1=<<EOXML01
<scanJob>
  <hosts>
    <host>
      <ip>192.168.41.113</ip>
      <netBIOSName>VMDEMO</netBIOSName>
      <netBIOSDomain>DEMO</netBIOSDomain>
      <dnsName>du.draddemo.com</dnsName>
      <mac>00:0C:29:FF:C2:85 (VMware, Inc.)</mac>
      <os>Windows Server 2003</os>
      <audit>
        <rthID>163</rthID>
        <cve>CVE-2000-1200</cve>
        <cce>N/A</cce>
        <name>Null Session</name>
        <description>A Null Session occurs when an attacker sends a blank username and blank password to try to connect to the IPC$ (Inter Process Communication) pipe. By creating a null session to IPC$ an attacker is then able to gain a list of user names, shares, and other potentially sensitive information.</description>
        <date>12/11/2011</date>
        <risk>High</risk>
        <pciLevel>Medium</pciLevel>
        <cvssScore>5 [AV:N/AC:L/Au:N/C:P/I:N/A:N]</cvssScore>
        <fixInformation>FixHere</fixInformation>
        <exploit>No</exploit>
        <context>N/A</context>
      </audit>
    </host>
  </hosts>
  <metrics>
    <jobName>dradis_test</jobName>
    <fileName>I:\Program Files (x86)\eEye Digital Security\Retina 5\Scans\1C3AA5EB1662430FA68959543ED7D71F.rtd</fileName>
    <scannerVersion>5.14.2</scannerVersion>
    <auditsRevision>2445</auditsRevision>
    <credentials>- Null Session -</credentials>
    <auditGroups>All Audits</auditGroups>
    <addressGroups>N/A</addressGroups>
    <ipRanges>192.168.41.113</ipRanges>
    <attempted>1</attempted>
    <scanned>1</scanned>
    <noAdmin>1</noAdmin>
    <start>11/12/2011 13:31:41</start>
    <duration>0d 0h 2m 6s</duration>
  </metrics>
</scanJob>

EOXML01

  describe 'RetinaUpload plugin' do
    include RetinaUploadSpecHelper
    it 'RetinaUpload responds to all the expected fields' do
      doc = Nokogiri::XML( XML1 )
      hosts = RetinaUpload.parse_retina_xml(doc)
      #Begin Tests
      hosts.length.should > 0
      hosts.first.keys.should include('address')
      hosts.first.keys.should include('dnsName')
      hosts.first.keys.should include('netBIOSName')
      hosts.first.keys.should include('vulns')
      hosts.first['vulns'].keys.length.should eq 1
      hosts.first['vulns'].first[1]['cve'].should match 'CVE-2000-1200'
    end

    pending 'RetinaUpload should provide access to each of its report items'
  end


end