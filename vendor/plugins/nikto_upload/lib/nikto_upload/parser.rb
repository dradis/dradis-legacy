# = Synopsys
#
# This module provides a parser for the Nikto XML output format
#
# = License
# 
# This file may be used under the terms of the GNU General Public
# License version 2.0 as published by the Free Software Foundation
# and appearing in the file LICENSE.txt included in the packaging of
# this file.
#
# Copyright: The Dradis Framework project (http://dradisframework.org/)


require 'rexml/document'

module NiktoUpload
module Nikto
  class Parser
    # Details of the Nikto scan
    attr_reader :details

    def self.parsestring(content)
      parser = self.new
      parser.parsestring(content)
      parser
    end

    def parsestring( str )
  		if not str.respond_to?(:to_str)
	  		raise TypeError, "XML data should be a String, or must respond to to_str()"
		  end

      parse(str)
    end

    def scans()
      @scans
    end

    def initialize(opts = {})
      @details = nil
      @scans = []
    end

    def parse(xml)
      parser = XML::Parser.new()
      REXML::Document.parse_stream(xml, parser)

      raise IOError, 'Error parsing XML. Parsing ended before </niktoscan> tag was reached.' unless parser.completed?

      @details = parser.details
      @scans = parser.scans

      true
    end

    def to_s
      out = ''
      out << "Nikto scan details:\n"
      out << "\tNikto version: #{@details.nikto_version}\n"
      out << "\tOptions: #{@details.options}\n"
      out << "\tHosts scanned: #{@details.hosts_test}\n"

      @scans.each do |scan|
        out << scan.to_s
        out << "\n"
      end
      out
    end
  end


  class Item
    attr_reader :id
    attr_reader :osvdbid
    attr_reader :osvdblink
    attr_reader :method

    attr_reader :description, :uri, :namelink, :iplink

    def initialize(details)
      parse(details)
    end

    def parse(item)
      @id = item[:attrs]['id']
      @osvdbid = item[:attrs]['osvdbid']
      @osvdblink = item[:attrs]['osvdblink']
      @method = item[:attrs]['method']

      @description = item[:kids].find_tag(:description)
      @uri = item[:kids].find_tag(:uri)
      @namelink = item[:kids].find_tag(:namelink)
      @iplink = item[:kids].find_tag(:iplink)
    end

    def to_s
      out = "\t\t- Item (#{@id}"
      out << ", #{@osvbd}" if @osvdv
      out << ", #{@method}" if @method
      out << ")"
      out << " - #{@uri[:text]}" if  @uri
      out << " | #{@iplink[:text]}" if @iplink
      out << "\n"
      out << "\t\t\t#{@description[:text]}\n\n"
    end
  end

  class Scan
    attr_reader :target_ip
    attr_reader :target_hostname
    attr_reader :target_port
    attr_reader :target_banner
    attr_reader :starttime
    attr_reader :endtime
    attr_reader :elapsed
    attr_reader :sitename
    attr_reader :siteip
    attr_reader :itemstested
    attr_reader :itemsfound


    def initialize(scaninfo)
      @items = []
      parse(scaninfo)
    end

    def parse(scan)
      @target_ip = scan[:attrs]['targetip']
      @target_hostname = scan[:attrs]['targethostname']
      @target_port = scan[:attrs]['targetport']
      @target_banner = scan[:attrs]['targetbanner']
      @starttime = scan[:attrs]['starttime']
      @endtime = scan[:attrs]['endtime']
      @elapsed = scan[:attrs]['elapsed']
      @sitename = scan[:attrs]['sitename']
      @siteip = scan[:attrs]['siteip']
      @itemstested = scan[:attrs]['itemstested']
      @itemsfound = scan[:attrs]['itemsfound']

      scan[:kids].each do |item|
        @items << Item.new(item)
      end
    end

    def to_s
      out = "Scan details:\n"
      out << "\tIP: #{@target_ip}\n"
      out << "\tHostname: #{@target_hostname}\n"
      out << "\tPort: #{@target_port}\n"
      out << "\tBanner: #{@target_banner}\n"
      out << "\tStart at: #{@starttime}\n"
      out << "\tEnd at: #{@endtime}\n"
      out << "\tElapsed: #{@elapsed}\n"
      out << "\tSite name: #{@sitename}\n"
      out << "\tSite IP: #{@siteip}\n"
      out << "\t# of tests: #{@itemstested}\n"
      out << "\tIssues found: #{@itemsfound}\n"
      
      @items.each do |item|
        out << item.to_s
      end
      out
    end
  end

  class Details
    # Number of hosts scanned
    attr_reader :hosts_test

    # Command line options
    attr_reader :options

    # Nikto version used to scan
    attr_reader :nikto_version

    # XML version of Nikto's output
    attr_reader :xml_version

    def initialize(detailsinfo)
      parse(detailsinfo)
    end
  
    def parse(root)
      @hosts_test = root[:attrs]['hoststest']
      @options = root[:attrs]['options']
      @nikto_version = root[:attrs]['version']
      @xml_version = root[:attrs]['nxmlversion']
    end
  end

  module XML
    class TagGroup < Array
    	def each_tag(name)
  		  self.each { |tag| yield tag if match(tag, name) }
	    end

    	def collect_tags(name)
		    self.map { |tag| yield tag if match(tag, name) }.compact
    	end

    	def find_tag(name)
		    self.find { |tag| match(tag, name) }
    	end

    	private

    	def match(tag, name)
		    tag[:name] == name.to_sym
    	end
    end

    class Tag < Hash
    	private

  	  def initialize(name, attrs)
	  	  self[:name] = name
  	  	self[:attrs] = attrs
		    self[:kids] = TagGroup.new
        self[:text] = nil
  	  end
    end

    class Parser
    	attr_reader :details
	    attr_reader :scans

  	  def tag_start(tag, attrs)
	  	  name = tag.to_sym

  		  return if ignored(name)

    		kv = Tag.new(name, attrs)

	    	if @data.empty?
		    	@data[name] = kv
    		else
	    		@loc.last[:kids].push(kv)
		    end

  		  @loc.push(kv)
  	  end

    	def tag_end(tag)
	    	name = tag.to_sym

  		  return if ignored(name)

    		last = @loc.pop

	    	case name
  		  when :scandetails
  		  	@scans << Scan.new(last)
	    		@loc[@loc.size - 2][:kids].pop

		    	if @callback
			    	Thread.new(@hosts.last) do |host|
  			  		Thread.current[:cb] = true
  	  				@callback.call(host)
	  	  		end
		  	  end
  		  when :niktoscan
  	  		@details = Details.new(last)
  
	    		if @callback and Thread.list.size > 1
		    		Thread.list.reject { |t|
			    		not t[:cb]
				    }.each { |t|
    					t.join
	    			}
		    	end
  		  end
  	  end

      def text( normalized )
        text = normalized.strip
        if !(text.empty? || @loc.empty? )
          @loc.last[:text] = text
        end
      end

      # Treat CDATA sections just like text
      alias_method :cdata, :text

    	def method_missing(sym, *args)
	    end

    	def completed?
	    	# @details becomes non-nil when <niktoscan> closes, which means
		    # we're done
  		  @details ? true : false
  	  end

    	private

	    # We don't want to store anything we don't care about!
    	IGNORED = [
        :statistics
    	]

  	  def ignored(name)
    		IGNORED.find { |ent| ent == name }
	    end

    	def initialize(callback=nil)
	    	@data = {}
		    @loc = []
  
  	  	@details = nil
	  	  @scans = []

  	  	@callback = callback
  	  end

    end

  end # XML
end # Nikto
end # NiktoUpload

if __FILE__ == $0
  if ARGV.size != 1
    puts "Usage:\n\t#{__FILE__} <nikto_output.xml>"
    exit 1
  end

  filename = ARGV[0]
  print "Parsing #{filename} ..."

  niktoscan = NiktoUpload::Nikto::Parser.parsestring( File.read( filename ) )

  puts ' done.'

  puts niktoscan.to_s
end
