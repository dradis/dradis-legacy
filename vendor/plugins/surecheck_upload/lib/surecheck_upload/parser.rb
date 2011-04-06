# = Synopsis
#
# This module provides a parser for SureCheck Reports
#
# = License
# 
# This file may be used under the terms of the GNU General Public
# License version 2.0 as published by the Free Software Foundation
# and appearing in the file LICENSE.txt included in the packaging of
# this file.
#
# Copyright: The Dradis Framework project (http://dradisframework.org/)

require 'rubygems'
require 'active_record'

module SurecheckUpload
  module Surecheck
		class Findings < ActiveRecord::Base; end
		class Parser
			attr_reader :findings
			def self.parsefile(file)
			  parser = self.new
			  parser.parsefile(file)
			  parser
			end

			def parsefile(file)
				Findings.establish_connection(
				    :adapter => "sqlite3",
				    :database  => file
				)
				@findings = Findings.find(:all)
			end
			
			def initialize(opts = {})
			  @findings = []
			end

			def to_s
				out = ''
				out << "SureCheck results:\n"
				@findings.each do |finding|
				  out << '#'*80 << "\n| "
					out << finding.id.to_s << ' | '
					out << finding.title << ' | '
					out << finding.severity_before_type_cast << " |\n"
					out << '#'*80 << "\n"
					out << finding.content << "\n"
				end

				return out
			end
		end # Surecheck::Parser 
		
		
	end # Surecheck::Parser
end # Surecheck

if __FILE__ == $0
  if ARGV.size != 1
    puts "Usage:\n\t#{__FILE__} <surecheck_output.sc>"
    exit 1
  end

  filename = ARGV[0]
  print "Parsing #{filename} ..."
  sc = SurecheckUpload::Surecheck::Parser.parsefile( filename )
  puts ' done.'
  puts sc.to_s
end

