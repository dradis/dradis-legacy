module W3afUpload
  module W3af
    class Parser
      def self.parse_w3af_xml(doc)

        host = Hash.new

        scaninfo = doc.search('scaninfo')

        host['target'] = scaninfo[0]['target']

        vulns = doc.search('vulnerability')

        host['vulns'] = Hash.new

        vulns.each do |vuln|
          vuln_name = vuln['name']
          vuln_url = vuln['url']
          vuln_desc = vuln.text
          vuln_sev = vuln['severity']

          unless host['vulns'][vuln_sev]
            host['vulns'][vuln_sev] = Hash.new
          end

          unless host['vulns'][vuln_sev][vuln_name]
            host['vulns'][vuln_sev][vuln_name] = Hash.new
          end

          unless host['vulns'][vuln_sev][vuln_name][vuln_url]
            host['vulns'][vuln_sev][vuln_name][vuln_url] = Array.new
          end

          host['vulns'][vuln_sev][vuln_name][vuln_url] << vuln_desc
        end
        return host
      end
    end
  end
end