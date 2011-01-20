# = nessus/parser.rb: Nessus::Parser
#
# Ruby interface to the Nessus Security Scanner and its XML formatted scan data
#
# = Author
#
# Hans-Martin Münch (hansmartin.muench@gmail.com)
#

# :main: Nessus::Parser
# :title: Ruby Nessus::Parser

require 'rexml/document'

# :startdoc:

# Provides a namespace for everything this library creates
module Nessus
        # :stopdoc:

        # Holds all of the classes for the stream-style XML parsing (the
        # listener class and my helper structure classes)
        module XmlParsing
        end

        # :startdoc:
end


class Nessus::Parser
    # Raw XML output form the scan
    attr_reader :raw_xml

    # The reports that have been found inside the xml file
    attr_reader :reports

    # Wrapper arround the instance method's functionality
    def self.parse_file(file_name)
        parser = self.new
        parser.parse_file(file_name)
        parser
    end


    def parse_file(file_name)
        File.open(file_name) { |file| parse_read(file) }

   # rescue
    #    raise $!.class, "Error parsing \"#{file_name}\": #{$!}"
    end


    def parse_read(obj) 
        if not obj.respond_to?(:read)
            raise TypeError, "Passed object must respond to read()"
        end
        
        parse_string(obj.read)
    end


    def self.parse_string(str)
        parser = self.new
        parser.parse_string(str)
        parser
    end

    def parse_string(str) 
        if not str.respond_to?(:to_str)
            raise TypeError, "XML data should be a String, or must respond to to_str()"
        end

        parse(str.to_str)
    end


    def parse(xml_data)
        @raw_xml = xml_data
        @xml     = REXML::Document.new(xml_data)
        @reports = Array.new        

        # Loop through all reports 
        @xml.elements.each("//NessusClientData_v2/Report") do |report_xml|
            @reports << Report.new(report_xml)
        end
        
    end

end 


class Nessus::Parser::Report
        # The name of the report
        attr_reader :name
       
        # The hosts of the report
        attr_reader :hosts
 
        def initialize(xml)
            @name  = xml.attributes['name']
            @hosts = Array.new

            xml.elements.each("./ReportHost") do |host_xml|
                @hosts <<  Nessus::Parser::Host.new(host_xml)
            end
       end 
end



class Nessus::Parser::Host

        def initialize(xml)

            @name               = xml.attributes['name']
            
            # Process the host properties
            @host_properties = Hash.new()
            ["HOST_END", "HOST_START", "operating-system", "host-fqdn", "host-ip", "mac-address", "netbios-name"].each do |property|
                begin
                    @host_properties[property] = xml.elements["HostProperties/tag[@name='#{property}']"].text
                rescue NoMethodError
                end 
            end

            # Process the report items
            @report_items = Array.new
            xml.elements.each("ReportItem") do |report_item_node|
                @report_items << Nessus::Parser::ReportItem.new(report_item_node)
            end            
 
        end
       
        # The host name (normaly the ip adress of the system
        attr_reader :name

        # The report_items of the host
        attr_reader :report_items

        # The operation system of the host
        # nil if not given
        def operating_system
            @host_properties["operating-system"]
        end

        # The mac address of the system
        # nil if not given
        def mac_address
            @host_properties["mac-address"]
        end

        # The netbios name of the system
        # nil if not given
        def netbios_name
            @host_properties["netbios-name"]
        end

        # The start time of the scan
        def scan_start_time
            @host_properties["HOST_START"]
        end

        # Time when the scan ended
        def scan_stop_time
            @host_properties["HOST_END"]
        end

        # Host FQDN
        def fqdn
            @host_properties["host-fqdn"]
        end


        # Host IP
        def ip
            @host_properties["host-ip"]
        end
 
end

class Nessus::Parser::ReportItem
        
        def initialize(xml)
            @xml            = xml
            @port           = xml.attributes["port"]
            @svc_name       = xml.attributes["svc_name"]
            @protocol       = xml.attributes["protocol"]
            @severity       = xml.attributes["severity"]
            @plugin_id      = xml.attributes["pluginID"]
            @plugin_name    = xml.attributes["pluginName"]
            @plugin_family  = xml.attributes["pluginFamily"]

        end

	attr_reader :xml, :port, :svc_name, :protocol, :severity, :plugin_id, :plugin_name, :plugin_family

        # Exploit ease  
        # Example: Exploits are available
        def exploitability_ease
            @exploitability_ease = get_tag_content("exploitability_ease") if @exploitability_ease_checked.nil?
            @exploitability_ease_checked = true
            @exploitability_ease
        end

        # The date when details about the vulnerability have been publicated 
        # Example: 2006/11/14
        def vuln_publication_date
            @vuln_publication_date = get_tag_content("vuln_publication_date") if @vuln_publication_date_checked.nil?
            @vuln_publication_date_checked = true
            @vuln_publication_date
        end


        # Tells you if a exploit is available for ImmunityCanvas 
        # Example: true
        def exploit_framework_canvas
            @exploit_framework_canvas = get_tag_content("exploit_framework_canvas") if @exploit_framework_canvas_checked.nil?
            @exploit_framework_canvas_checked = true
            @exploit_framework_canvas = false if @exploit_framework_canvas.nil?
            @exploit_framework_canvas
        end



        # Tells you if a exploit is available for Metasploit 
        # Example: true
        def exploit_framework_metasploit
            @exploit_framework_metasploit = get_tag_content("exploit_framework_metasploit") if @exploit_framework_metasploit_checked.nil?
            @exploit_framework_metasploit_checked = true
            @exploit_framework_metasploit = false if @exploit_framework_metasploit.nil?
            @exploit_framework_metasploit
        end


        # Tells you if a exploit is available for Core Impact 
        # Example: true
        def exploit_framework_core
            @exploit_framework_core = get_tag_content("exploit_framework_core") if @exploit_framework_core_checked.nil?
            @exploit_framework_core_checked = true
            @exploit_framework_core = false if @exploit_framework_core.nil?
            @exploit_framework_core
        end


        # Solution for the issue   
        # Example: Microsoft has released a set of patches for Windows 2000 and XP :
        #          http://www.microsoft.com/technet/security/bulletin/ms06-070.mspx 
        def solution
            @solution = get_tag_content("solution") if @solution_checked.nil?
            @solution_checked = true
            @solution
        end


        # The risk factor   
        # Example: Critical 
        def risk_factor
            @risk_factor = get_tag_content("risk_factor") if @risk_factor_checked.nil?
            @risk_factor_checked = true
            @risk_factor
        end


        # The report description  
        # Example: The remote host is vulnerable to a buffer overrun in the..."
        def description 
            @description = get_tag_content("description") if @description_checked.nil?
            @description_checked = true
            @description
        end



        # The date of the plugin release
        # Example:  2006/11/14
        def plugin_publication_date 
            @plugin_publication_date = get_tag_content("plugin_publication_date") if @plugin_publication_date_checked.nil?
            @plugin_publication_date_checked = true
            @plugin_publication_date
        end


        # The name of the exploit inside the metasploit framework 
        # Example: Microsoft Workstation Service NetpManageIPCConnect Overflow 
        def metasploit_name
            @metasploit_name = get_tag_content("metasploit_name") if @metasploit_name_checked.nil?
            @metasploit_name_checked = true
            @metasploit_name
        end



        # CVSS Vector 
        # Example: CVSS2#AV:N/AC:L/Au:N/C:C/I:C/A:C 
        def cvss_vector 
            @cvss_vector = get_tag_content("cvss_vector") if @cvss_vector_checked.nil?
            @cvss_vector_checked = true
            @cvss_vector
        end


        # CVSS Temporal Vector 
        # Example: CVSS2#E:F/RL:OF/RC:C 
        def cvss_temporal_vector
            @cvss_temporal_vector = get_tag_content("cvss_temporal_vector") if @cvss_temporal_vector_checked.nil?
            @cvss_temporal_vector_checked = true
            @cvss_temporal_vector
        end


        # Synopsis 
        # Example: Arbitrary code can be executed on the remote host due to a flaw in the &apos;workstation&apos; service
        def synopsis
            @synopsis = get_tag_content("synopsis") if @synopsis_checked.nil?
            @synopsis_checked = true
            @synopsis
        end


        # Is a exploit available 
        # Example: true
        def exploit_available 
            @exploit_available = get_tag_content("exploit_available") if @exploit_available_checked.nil?
            @exploit_available_checked = true
            @exploit_available = true
            @exploit_available = false if @exploit_available.nil? 
            @exploit_available
        end


        # The patch publication date
        # Example: 2010/10/06
        def patch_publication_date
            @patch_publication_date = get_tag_content("patch_publication_date") if @patch_publication_date_checked.nil?
            @patch_publication_date_checked = true
            @patch_publication_date
        end


        # The plugin modification date
        # Example: 2010/10/06
        def plugin_modification_date
            @plugin_modification_date = get_tag_content("plugin_modification_date") if @plugin_modification_date_checked.nil?
            @plugin_modification_date_checked = true
            @plugin_modification_date
        end


        # The CVSS temporal score as a float number
        # Example: 10.0
        def cvss_temporal_score
            @cvss_temporal_score = get_tag_content("cvss_temporal_score") if @cvss_temporal_score_checked.nil?
            @cvss_temporal_score_checked = true
            return @cvss_temporal_score.to_f unless @cvss_temporal_score.nil?
            @cvss_temporal_score
        end


        # The CVSS base score as a float number
        # Example: 10.0
        def cvss_base_score
            @cvss_base_score = get_tag_content("cvss_base_score") if @cvss_base_score_checked.nil?
            @cvss_base_score_checked = true 
            return @cvss_base_score.to_f unless @cvss_base_score.nil?
            @cvss_base_score
        end


        # If a the canvas package that contains the exploit if available
        # Example: CANVAS
        def canvas_package
            @canvas_package = get_tag_content("canvas_package") if @canvas_package_checked.nil? 
            @canvas_package_checked = true
            @canvas_package
        end


        # The ouput of the plugin
        def plugin_output
            @plugin_output = get_tag_content("plugin_output") if @plugin_output_checked.nil? 
            @plugin_output_checked = true
            @plugin_output
        end


        # The version of the plugin
        # Example: $Revision: 1.11 $
        def plugin_version
            @plugin_version = get_tag_content("plugin_version") if @plugin_version_checked.nil?
            @plugin_version_checked = true
            @plugin_version 
        end

        
        # The buqtrack ids for the plugin as a array
        def bid_entries
             if @bid_entries.nil? then
                @bid_entries = Array.new
                @xml.elements.each("./bid") {|bid| @bid_entries << bid.text }
             end        
             
            return nil if @bid_entries.size == 0
             @bid_entries
        end

        # The cve entries as a array
        def cve_entries
             if @cve_entries.nil? then
                @cve_entries = Array.new
                @xml.elements.each("./cve") {|cve| @cve_entries << cve.text }
             end

             return nil if @cve_entries.size == 0
             @cve_entries
        end

        # Other references  as a array
        def xref_entries
             if @xref_entries.nil? then
                @xref_entries = Array.new
                @xml.elements.each("./xref") {|xref| @xref_entries << xref.text }
             end

             return nil if @xref_entries.size == 0
             @xref_entries
        end

        private
        def get_tag_content(tag)
            begin
                return @xml.elements[tag].text
            rescue NoMethodError
                return nil
            end
        end
end
