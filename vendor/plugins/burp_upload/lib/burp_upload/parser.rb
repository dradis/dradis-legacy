# = Synopsys
#
# This module provides a parser for the Burp Scanner XML output format
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

module BurpUpload
  module Burp
    class Parser
      attr_reader :issues

      def self.parsestring(content)
        parser = self.new
        parser.parsestring(content)
        parser
      end


      def parsestring(str)
    		if not str.respond_to?(:to_str)
	    		raise TypeError, "XML data should be a String, or must respond to to_str()"
		    end

        parse(str)
      end

      def initialize(opts = {})
        @items = []
      end

      def parse(xml)
        parser = XML::SAXParser.new()
        REXML::Document.parse_stream(xml, parser)

        raise IOError, 'Error parsing XML' unless parser.completed?
        @issues = parser.issues
        true
      end

      def to_s
        out = ''
        out << "Burp Scanner results:\n"
        @issues.each do |issue|
          out << issue.to_s
          out << "\n"
        end

        return out
      end

    end # Burp::Parser 

    class Issue
      attr_reader :serialNumber
      attr_reader :type
      attr_reader :name
      attr_reader :host
      attr_reader :path
      attr_reader :location
      attr_reader :severity
      attr_reader :confidence
      attr_reader :issueBackground
      attr_reader :remediationBackground
      attr_reader :issueDetail
      attr_reader :remediationDetail
      attr_reader :requestresponse

      def initialize(details)
        parse(details)
      end

      def parse(issue)
        @serialNumber = issue[:kids].find_tag(:serialNumber)
        @type = issue[:kids].find_tag(:type)
        @name = issue[:kids].find_tag(:name)
        @host = issue[:kids].find_tag(:host)
        @path = issue[:kids].find_tag(:path)
        @location = issue[:kids].find_tag(:location)
        @severity = issue[:kids].find_tag(:severity)
        @confidence = issue[:kids].find_tag(:confidence)
        @issueBackground = issue[:kids].find_tag(:issueBackground)
        @remediationBackground = issue[:kids].find_tag(:remediationBackground)
        @issueDetail = issue[:kids].find_tag(:issueDetail)
        @remediationDetail = issue[:kids].find_tag(:remediationDetail)
        @requestresponse = issue[:kids].find_tag(:requestresponse)
      end

      def to_s
        out = "\t\tIssue "
        out << @serialNumber[:text] if @serialNumber
        out << " | #{@type[:text]}" if @type
        out << " | #{@severity[:text]}" if @severity
        out << " | #{@confidence[:text]}" if @confidence
        out << "\n\t\t\t"
        out << @name[:text] if @name
        out << " | #{@host[:text]}" if @host
        out << " | #{@path[:text]}" if @path
#        out << @issueBackground
#        out << @remediationBackground
#        out << @issueDetail
#        out << @remediationDetail
 #       out << @requestresponse
        out << "\n"
      end

    end # Burp::Issue

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

      class SAXParser
        attr_reader :meta
        attr_reader :issues

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
          when :issue
            @issues << Issue.new(last)
            @loc[@loc.size - 2][:kids].pop
          when :issues
              @meta = {}
          end
        end

        def text(normalized)
          text = normalized.strip
          if !(text.empty? || @loc.empty?)
            @loc.last[:text] = text
          end
        end

        # Treat CDATA sections just like text
        alias_method :cdata, :text

        def method_missing(sym, *args)
        end

        def completed?
          @meta ? true : false
        end

        private
  	    # We don't want to store anything we don't care about!
      	IGNORED = [
      	]

  	    def ignored(name)
    		  IGNORED.find { |ent| ent == name }
  	    end

        def initialize(callback=nil)
          @data = {}
          @loc = []

          @meta = nil 
          @issues = []
        end
      end # SAXParser
    end # XML

  end # Burp
end # BurpUpload

if __FILE__ == $0
  if ARGV.size != 1
    puts "Usage:\n\t#{__FILE__} <burp_scanner_output.xml>"
    exit 1
  end

  filename = ARGV[0]
  print "Parsing #{filename} ..."

  burpscan = BurpUpload::Burp::Parser.parsestring( File.read( filename ) )

  puts ' done.'

  puts burpscan.to_s
end
