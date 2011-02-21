#!/usr/bin/env ruby
# = Synopsys
#
# This module provides a parser for the Web Exploitation Framework XML output format
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

module WxfUpload
  module Wxf
 
class Parser 
    attr_reader :contentdata
  
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

    
    def initialize(opts = {})
      @items = []
    end
    
     def parse(xml)
        parser = XML::Parser.new()
        REXML::Document.parse_stream(xml, parser)

        raise IOError, 'Error parsing XML' unless parser.completed?
        @contentdata = parser.contentdata
        true
     end
     
     def to_s
       out = ''
       out << "wXf Output:\n"
       @contentdata.each do |cdata|
       out << cdata.to_s
       out << "\n"
       end
      
     return out
    end

end

class Content
  attr_reader :time
  attr_reader :name
  attr_reader :headers
  attr_reader :request
  attr_reader :bodyofmessage
  
  
  def initialize(details)
    parse(details)
  end
 
  def parse(details)
    @time    = details[:kids].find_tag(:time)
    @name    = details[:kids].find_tag(:name)
    @headers = details[:kids].find_tag(:headers)
    @request = details[:kids].find_tag(:request)
    @bodyofmessage    = details[:kids].find_tag(:bodyofmessage)    
  end
  
  def to_s
    out = ''
    out << "\n"
    out << "| #{@time[:text]} " if @time
    out << "| #{@name[:text]} " if @name
    out << "| #{@headers[:text]} " if @headers
    out << "| #{@request[:text]}" if @request
    out << "| #{@bodyofmessage[:text]} " if @bodyofmessage
    out << "\n"
  end
  
end

module XML
  
   class TagGroup < Array
     
      def each_tag(name)
  	 self.each { |tag| yield tag if match(tag, name) }
      end

      def collect_tags(name)
        self.map {|tag| yield tag if match(tag,name) }.compact
      end
      
      def find_tag(name)
        self.find{|tag| match(tag,name)}
      end
      
      private
      
      def match(tag,name)
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
      attr_reader :contentdata
      
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
	 when :content
           @contentdata<< Content.new(last)
           @loc[@loc.size - 2][:kids].pop
            when :contentdata
              @meta = {}
          end
     end
     
      def text(normalized)
          text = normalized.strip
          if !(text.empty? || @loc.empty?)
            @loc.last[:text] = text
          end
      end
       
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
        @contentdata = []
      end   
    
   end #EndOfParser
  
end

   

end end
 
 if __FILE__ == $0
  if ARGV.size != 1
    puts "Usage:\n\t#{__FILE__} <wXf_output.xml>"
    exit 1
  end

  filename = ARGV[0]
  print "Parsing #{filename} ..." 

  wxftext = WxfUpload::Wxf::Parser.parsestring( File.read( filename ) )

  puts ' done.'

  puts wxftext.to_s
end