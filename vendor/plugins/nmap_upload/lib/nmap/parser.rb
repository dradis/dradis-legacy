# = nmap/parser.rb: Nmap::Parser
#
# Ruby interface to the Nmap Security Scanner and its XML formatted scan data
#
# = Homepage
#
# http://rubynmap.sourceforge.net
#
# = Author
#
# Kris Katterjohn (katterjohn@gmail.com)
#
# = License
#
# Copyright (c) 2007-2009 Kris Katterjohn
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# $Id: parser.rb 203 2009-08-18 18:56:30Z kjak $
# https://rubynmap.svn.sourceforge.net/svnroot/rubynmap/trunk

# :main: Nmap::Parser
# :title: Ruby Nmap::Parser

require 'rexml/document'

begin
	require 'open3'
rescue LoadError
end

# :stopdoc:
begin
	require 'rubygems'
rescue LoadError
end
begin
	require 'blinkenlights'
rescue LoadError
end
# :startdoc:

# Provides a namespace for everything this library creates
module Nmap
	# :stopdoc:

	# Holds all of the classes for the stream-style XML parsing (the
	# listener class and my helper structure classes)
	module XmlParsing
	end

	# :startdoc:
end

=begin rdoc

== What Is This Library For?

This library provides a Ruby interface to the Nmap Security Scanner and its
XML formatted scan data.  It can run Nmap and parse its XML output directly
from the scan, parse a file or string of XML scan data, or parse XML scan
data from an object via its read() method.  This information is presented in
an easy-to-use and intuitive fashion for further storage and manipulation.

Note that while Anthony Persaud's Nmap::Parser for Perl was certainly an
inspiration when designing this library, there are a number of distinguishing
characteristics.  Very briefly, this library contains more classes, many more
methods, and has blocks extensively available.

The Nmap Security Scanner is an awesome utility written and maintained by
Fyodor (fyodor(a)insecure.org).  Its main function is port scanning, but it also
has service and operating system detection, its own scripting engine and a
whole lot more.  One of its many available output formats is XML, which allows
machines to handle all of the information instead of us slowly sifting through
tons of output.

== Conventions

Depending on the data type, unavailable information is presented differently:

* Arrays are empty
* Non-arrays are nil, unless it's a method that returns the size of one of
  the previously mentioned empty arrays.  In this case they still return the
  size (which would be 0).

All information available as arrays are presented via methods.  These methods
not only return the array, but they also yield each element to a block if one
is given.

== Module Hierarchy

  Nmap::Parser
  |
  + Session           <- Scan session information
  |
  + Host              <- General host information
    |
    + ExtraPorts      <- Ports consolidated in an "ignored" state
    |
    + Port            <- General port information
    | |
    | + Service       <- Port Service information
    |
    + Script          <- NSE Script information (both host and port)
    |
    + Times           <- Timimg information (round-trip time, etc)
    |
    + Traceroute      <- General Traceroute information
    | |
    | + Hop           <- Individual Hop information
    |
    + OS              <- OS Detection information
      |
      + OSClass       <- OS Class information
      |
      + OSMatch       <- OS Match information

== Examples

There are two ways to go about getting a new Parser object and actually parsing
Nmap's XML output:

* Call one of the Nmap::Parser class methods to parse the XML and return a new
  Parser object all in one step.

* Call Nmap::Parser.new to get a new object and then call one of the instance
  parsing methods (e.g. parsefile()).  The main reason to go this route is that
  new() takes a hash of options; for example, you take advantage of the callback
  feature this way.

=== Parsing XML Data Already Available as a String

	require 'nmap/parser'

	parser = Nmap::Parser.new
	parser.parsestring(xml)

or

	parser = Nmap::Parser.parsestring(xml)

=== Reading and Parsing From a File

	require 'nmap/parser'

	parser = Nmap::Parser.parsefile("log.xml")

=== Reading and Parsing From an Object

This method can read from any object responding to a read() method that
returns a String (or something else responding to to_str())

	require 'nmap/parser'

	parser = Nmap::Parser.parseread($stdin)

=== Scanning and Parsing

This is the only Parser method that requires Nmap to be available.

	require 'nmap/parser'

	parser = Nmap::Parser.parsescan("sudo nmap", "-sVC 192.168.1.0/24")

=== Registering a Callback

To use a callback you create a new Parser object and register a proc or method
to call each time a new host is parsed, as soon as it's parsed.  The callback
is then run in a new thread and is passed the newly created Nmap::Parser::Host
object.

	require 'nmap/parser'

	callback = proc do |host|
		return if host.status != "up"
		puts "Found #{host.addr}"
	end

	parser = Nmap::Parser.new(:callback => callback)
	parser.parsefile("nmaplog.xml")

	# Found 192.168.10.1
	# Found 192.168.10.2
	# Found 192.168.10.7
	# [...]

=== Doing a Bit More

After printing a little session information, this example will cycle
through all of the up hosts, printing state and service information on
the open TCP and UDP ports.  See the examples directory that comes with
this library for more examples.

	puts "Nmap args: #{parser.session.scan_args}"
	puts "Runtime: #{parser.session.scan_time} seconds"
	puts

	parser.hosts("up") do |host|
		puts "#{host.addr} is up:"
		puts

		[:tcp, :udp].each do |type|
			host.getports(type, "open") do |port|
				srv = port.service

				puts "Port ##{port.num}/#{port.proto} is open (#{port.reason})"
				puts "\tService: #{srv.name}" if srv.name
				puts "\tProduct: #{srv.product}" if srv.product
				puts "\tVersion: #{srv.version}" if srv.version
				puts
			end
		end

		puts
	end

== Credits

Author & Maintainer:

* Kris Katterjohn (katterjohn(a)gmail.com)

Contributors (in chronological order of first contribution):

* Stefan Friedli (stfr(a)scip.ch)
* Daniel Roethlisberger (daniel(a)roe.ch)
* Dustin Webber (dustinw(a)aos5.com)
* Tom Sellers (nmap(a)fadedcode.net)
* Rory McCune (rorym@nmrconsult.net)

Thanks a lot for taking the time and helping out, everybody!

For information on what each contributor actually did, please take a look at
the project's ChangeLog and Subversion logs.

=end
class Nmap::Parser
	# Raw XML output from the scan
	attr_reader :rawxml
	# Session object for the scan
	attr_reader :session

	# Major version number
	Major = 0
	# Minor version number
	Minor = 3
	# Teeny version number
	Teeny = 5
	# Development stage (currently "dev" or "release")
	Stage = "dev"
	# Pre-built version string
	Version = "#{Major}.#{Minor}.#{Teeny}"

	# Wrapper around the instance method's functionality
	#
	# Returns a new Nmap::Parser object and yields it to a block if one is
	# given
	def self.parseread(obj) # :yields: parser
		parser = self.new
		parser.parseread(obj)
		yield parser if block_given?
		parser
	end

	# Read and parse XML from +obj+.  +obj+ can be any object responding
	# to a read() method that returns a String (or something else responding
	# to to_str()).  IO and File are just a couple of examples.
	def parseread(obj)
		if not obj.respond_to?(:read)
			raise TypeError, "Passed object must respond to read()"
		end

		parsestring(obj.read)
	end

	# Wrapper around the instance method's functionality
	#
	# Returns a new Nmap::Parser object and yields it to a block if one is
	# given
	def self.parsefile(filename) # :yields: parser
		parser = self.new
		parser.parsefile(filename)
		yield parser if block_given?
		parser
	end

	# Read and parse the contents of the Nmap XML file +filename+
	def parsefile(filename)
		File.open(filename) { |f| parseread(f) }
	rescue
		raise $!.class, "Error parsing \"#{filename}\": #{$!}"
	end

	# Wrapper around the instance method's functionality
	#
	# Returns a new Nmap::Parser object and yields it to a block if one is
	# given
	def self.parsestring(str) # :yields: parser
		parser = self.new
		parser.parsestring(str)
		yield parser if block_given?
		parser
	end

	# Read and parse a String (or something else responding to to_str()) of
	# XML
	def parsestring(str)
		if not str.respond_to?(:to_str)
			raise TypeError, "XML data should be a String, or must respond to to_str()"
		end

		parse(str.to_str)
	end

	# Wrapper around the instance method's functionality
	#
	# Returns a new Nmap::Parser object and yields it to a block if one is
	# given
	def self.parsescan(nmap, args, targets = []) # :yields: parser
		parser = self.new
		parser.parsescan(nmap, args, targets)
		yield parser if block_given?
		parser
	end

	# Essentially runs "+nmap+ -d +args+ +targets+"
	#
	# +nmap+ is here to allow you to do things like:
	#
	# parser.parsescan("sudo ./nmap", arguments, targets)
	#
	# and still make it easy for me to inject the options for XML output
	# and debugging.
	#
	# +args+ can't contain arguments like -oA, -oX, etc. as these could
	# interfere with Parser's processing.  If you need that other output,
	# you could run Nmap yourself and just pass the -oX output to Parser.
	# Or you could use rawxml to grab the XML from the scan and write it
	# to a file, for example.
	#
	# +targets+ is an optional array of target specifications.  It's here
	# only for convenience because you can also put any targets you want
	# scanned in +args+ (which is what I tend to do unless I happen to
	# already have a collection of targets as an array).
	def parsescan(nmap, args, targets = [])
		if args =~ /[^-]-o|^-o/
			raise ArgumentError, "Output option (-o*) passed to parsescan()"
		end

		# Enable debugging and XML; pass args and targets
		command = "#{nmap} -d -oX - #{args} #{targets.join(" ")}"

		begin
			# First try popen3() if it loaded successfully..
			Open3.popen3(command) do |sin, sout, serr|
				parseread(sout)
			end
		rescue NameError
			# ..but fall back to popen() if not
			IO.popen(command) do |io|
				parseread(io)
			end
		end
	end

	# Returns an array of Host objects and yields them each to a block if
	# one is given
	#
	# If an argument is given, only hosts matching +status+ are given
	#
	# NOTE: Calling parser.hosts(status).size can be very different than
	# running parser.session.numhosts(status) because the information there
	# and here are coming from different places in the XML.  Nmap will not
	# typically list individual hosts which it doesn't know or assume are
	# "up".
	def hosts(status = "") # :yields: host
		@hosts.map { |host|
			if status.empty? or host.status == status
				yield host if block_given?
				host
			end
		}.compact
	end

	# Returns a Host object for the host with the specified IP address
	# or hostname +hostip+
	def host(hostip)
		@hosts.find do |host|
			host.addr == hostip or host.hostname == hostip
		end
	end

	alias get_host host

	# Deletes host with the specified IP address or hostname +hostip+
	#
	# Calling this method from inside of a block given to a method like
	# hosts() or get_ips() may lead to adverse effects.
	def del_host(hostip)
		@hosts.delete_if do |host|
			host.addr == hostip or host.hostname == hostip
		end
	end

	alias delete_host del_host

	# Returns an array of IPs scanned and yields them each to a block if
	# one is given
	#
	# If an argument is given, only hosts matching +status+ are given
	#
	# NOTE: Calling parser.get_ips(status).size can be very different than
	# running parser.session.numhosts(status) because the information there
	# and here are coming from different places in the XML.  Nmap will not
	# typically list individual hosts which it doesn't know or assume are
	# "up".
	def get_ips(status = "") # :yields: host.addr
		hosts(status).map do |host|
			yield host.addr if block_given?
			host.addr
		end
	end

	# This operator simply compares the rawxml members
	def ==(pa)
		@rawxml == pa.rawxml
	end

	# Returns a new Parser object with the following characteristics:
	#  * rawxml = nil
	#  * session = nil
	#  * contains hosts from both operands.  If any of the hosts in the
	#    first operand are also in the second (as determined by comparing
	#    host.addr information), the duplicate hosts from the second one
	#    are not available.
	def +(pa)
		return nil unless self.class == pa.class
		n = Nmap::Parser.new
		n.rawxml = nil
		n.session = nil
		[ self.hosts, pa.hosts ].each do |h|
			n.addhosts(h)
		end
		n
	end

	# Returns a boolean value depending on whether this object is just a
	# combination of others (e.g. using +)
	def combination?
		rawxml.nil? and session.nil? and not @fresh
	end

	protected

	attr_writer :rawxml, :session

	def addhosts(a)
		@hosts << a.find_all do |h|
			not host(h.addr) # ignore dups
		end
		@fresh = false
		@hosts.flatten!
	end

	private

	def initialize(opts = {})
		@hosts = []
		@fresh = true

		opts.keys.each do |key|
			begin
				send("option_#{key}", opts[key])
			rescue NoMethodError
			end
		end
	end

	def option_callback(callback)
		return if callback.nil?

		@callback = callback

		klasses = []
		klasses.push(Proc)
		klasses.push(Method)
		klasses.push(UnboundMethod) if defined?(UnboundMethod)

		return if klasses.find do |klass|
			@callback.instance_of?(klass)
		end

		raise TypeError, "Bad callback type: must be a Proc, Method or UnboundMethod"
	end

	def option_blinken(tty)
		return if tty.nil? or not defined?(BlinkenLights)
		path = (tty.instance_of?(String) and tty or "/dev/console")
		@blinken = proc do
			BlinkenLights.open(path, 0.2) do |lights|
				lights.left_to_right while true
			end
		end
	end

	def parse(xml)
		return unless @fresh

		@rawxml = xml

		# :)
		lthr = Thread.new { @blinken.call } if @blinken

		parser = Nmap::XmlParsing::MyParser.new(@callback)
		REXML::Document.parse_stream(xml, parser)

		lthr.kill if @blinken

		raise IOError, "Error parsing XML" unless parser.completed?

		@session = parser.session

		@hosts = parser.hosts

		@fresh = false

		true
	end
end

# This holds session information, such as runtime, Nmap's arguments,
# and verbosity/debugging
class Nmap::Parser::Session
	# Command run to initiate the scan
	attr_reader :scan_args
	# Version number of the Nmap used to scan
	attr_reader :nmap_version
	# XML version of Nmap's output
	attr_reader :xml_version
	# Starting time
	attr_reader :start_str, :start_time
	# Ending time
	attr_reader :stop_str, :stop_time
	# Total scan time in seconds (could differ from stop_time - start_time)
	attr_reader :scan_time
	# Amount of verbosity (-v) used while scanning
	attr_reader :verbose
	# Amount of debugging (-d) used while scanning
	attr_reader :debug

	alias verbosity verbose
	alias debugging debug

	# Returns the total number of hosts that were scanned or, if an
	# argument is given, returns the number of hosts scanned that were
	# matching +status+ (e.g. "up")
	#
	# NOTE: Calling parser.sessions.numhosts(status) can be very different
	# than running parser.hosts(status).size because the information there
	# and here are coming from different places in the XML.  Nmap will not
	# typically list individual hosts which it doesn't know or assume are
	# "up".
	def numhosts(state = "")
		@numhosts[state.empty? ? "total" : state]
	end

	# Returns the total number of services that were scanned or, if an
	# argument is given, returns the number of services scanned for +type+
	# (e.g. "syn")
	def numservices(type = "")
		@scaninfo.find_all { |info|
			type.empty? or info.type == type
		}.inject(0) { |acc, info|
			acc + info.numservices
		}
	end

	# Returns the protocol associated with the specified scan +type+
	# (e.g. "tcp" for type "syn")
	def scan_type_proto(type)
		@scaninfo.each do |info|
			return info.proto if info.type == type
		end

		nil
	end

	# Returns an array of all the scan types performed and yields them
	# each to a block if one if given
	def scan_types() # :yields: scantype
		@scaninfo.map do |info|
			yield info.type if block_given?
			info.type
		end
	end

	# Returns the scanflags associated with the specified scan +type+
	# (e.g. "PSHACK" for type "ack")
	def scanflags(type)
		@scaninfo.each do |info|
			return info.scanflags if info.type == type
		end

		nil
	end

	private

	def initialize(root)
		parse(root)
	end

	def parse(root)
		@scan_args = root[:attrs]['args']

		@nmap_version = root[:attrs]['version']

		@xml_version = root[:attrs]['xmloutputversion'].to_f

		@start_str = root[:attrs]['startstr']
		@start_time = root[:attrs]['start'].to_i

		runstats = root[:kids].find_tag(:runstats)
		finished = runstats[:kids].find_tag(:finished)

		@stop_str = finished[:attrs]['timestr']
		@stop_time = finished[:attrs]['time'].to_i

		elapsed = finished[:attrs]['elapsed']
		@scan_time = elapsed ? elapsed.to_f : (@stop_time - @start_time).to_f

		@verbose = root[:kids].find_tag(:verbose)[:attrs]['level'].to_i
		@debug = root[:kids].find_tag(:debugging)[:attrs]['level'].to_i

		@numhosts = {}
		runstats[:kids].find_tag(:hosts)[:attrs].each_pair do |k, v|
			@numhosts[k] = v.to_i
		end

		@scaninfo = root[:kids].collect_tags(:scaninfo) do |info|
			ScanInfo.new(info)
		end
	end
end

class Nmap::Parser::Session::ScanInfo # :nodoc: all
	attr_reader :type, :scanflags, :proto, :numservices

	private

	def initialize(info)
		parse(info)
	end

	def parse(info)
		@type = info[:attrs]['type']
		@scanflags = info[:attrs]['scanflags']
		@proto = info[:attrs]['protocol']
		@numservices = info[:attrs]['numservices'].to_i
	end
end

# This holds all of the information about a target host.
#
# Status, IP/MAC addresses, hostnames, all that.  Port information is
# available in this class; either accessed through here or directly
# from a Port object.
class Nmap::Parser::Host
	# Status of the host, typically "up" or "down"
	attr_reader :status
	# Reason for the status
	attr_reader :reason
	# IPv4 address
	attr_reader :ip4_addr
	# IPv6 address
	attr_reader :ip6_addr
	# MAC address
	attr_reader :mac_addr
	# MAC vendor
	attr_reader :mac_vendor
	# OS object holding Operating System information
	attr_reader :os
	# Number of "weird responses"
	attr_reader :smurf
	# TCP Sequence Number information
	attr_reader :tcpsequence_index, :tcpsequence_class
	# TCP Sequence Number information
	attr_reader :tcpsequence_values, :tcpsequence_difficulty
	# IPID Sequence Number information
	attr_reader :ipidsequence_class, :ipidsequence_values
	# TCP Timestamp Sequence Number information
	attr_reader :tcptssequence_class, :tcptssequence_values
	# Uptime information
	attr_reader :uptime_seconds, :uptime_lastboot
	# Traceroute object
	attr_reader :traceroute
	# Network distance (not necessarily the same as from traceroute)
	attr_reader :distance
	# Times object holding timing information
	attr_reader :times
	# Host start and end times
	attr_reader :starttime, :endtime

	alias ipv4_addr ip4_addr
	alias ipv6_addr ip6_addr

	# Returns the IPv4 or IPv6 address of host
	def addr
		@ip4_addr or @ip6_addr
	end

	# Returns an array containing all of the hostnames for this host and
	# yields them each to a block if one is given
	def hostnames
		@hostnames.each { |hostname| yield hostname } if block_given?
		@hostnames
	end

	alias all_hostnames hostnames

	# Returns the first hostname
	def hostname
		@hostnames[0]
	end

	# Returns an array of ExtraPorts objects and yields them each to a
	# block if one if given
	def extraports # :yields: extraports
		@extraports.each { |e| yield e } if block_given?
		@extraports
	end

	# Returns the Port object for the port +portnum+ of protocol +type+
	# (:tcp, :udp, :sctp or :ip) and yields it to a block if one is given.
	def getport(type, portnum) # :yields: port
		type = type.to_sym

		port = case type
		when :tcp, :udp, :sctp, :ip
			@ports[type][portnum.to_i]
		else
			raise ArgumentError, "Invalid protocol type"
		end

		yield port if block_given?

		port
	end

	# Returns an array of Port objects for each port of protocol +type+
	# (:tcp, :udp, :sctp or :ip) and yields them each to a block if one is
	# given
	#
	# If +type+ is :any rather than a protocol name, then matching ports
	# from all protocols are given.
	#
	# If +state+ is given, only ports matching that state are given.  Note
	# that combinations like "open|filtered" will get matched by "open" and
	# "filtered"
	def getports(type, state = "")
		type = type.to_sym

		ports = case type
		when :tcp, :udp, :sctp, :ip
			@ports[type].values
		when :any
			@ports.map { |ent| ent[1].values }.flatten
		else
			raise ArgumentError, "Invalid protocol type"
		end

		list = ports.find_all { |port|
			state.empty? or
			port.state == state or
			port.state.split(/\|/).include?(state)
		}.sort

		list.each { |port| yield port } if block_given?

		list
	end

	# Returns an array of port numbers of protocol +type+ (:tcp, :udp, :sctp
	# or :ip) and yields them each to a block if one given
	#
	# If +state+ is given, only ports matching that state are given.  Note
	# that combinations like "open|filtered" will get matched by "open" and
	# "filtered"
	def getportlist(type, state = "") # :yields: port
		getports(type, state).map do |port|
			yield port.num if block_given?
			port.num
		end
	end

	# :method: tcp_port(portnum)
	# Just like getport(:tcp, +portnum+)

	# :method: tcp_ports(state="")
	# Just like getports(:tcp, +state+)

	# :method: tcp_port_list(state="")
	# Just like getportlist(:tcp, +state+)

	# :method: tcp_state(portnum)
	# Returns the state of TCP port +portnum+

	# :method: tcp_reason(portnum)
	# Returns the state reason of TCP port +portnum+

	# :method: tcp_service(portnum)
	# Returns the Port::Service for TCP port +portnum+

	# :method: tcp_script(portnum,name)
	# Returns the Script object for the script +name+ run against the
	# TCP port +portnum+

	# :method: tcp_scripts(portnum)
	# Returns an array of Script objects for each script run on the TCP
	# port +portnum+ and yields them each to a block if one is given

	# :method: tcp_script_output(portnum,name)
	# Returns the output of the script +name+ on the TCP port +portnum+

	# :method: udp_port(portnum)
	# Just like getport(:udp, +portnum+)

	# :method: udp_ports(state="")
	# Just like getports(:udp, +state+)

	# :method: udp_port_list(state="")
	# Just like getportlist(:udp, +state+)

	# :method: udp_state(portnum)
	# Returns the state of UDP port +portnum+

	# :method: udp_reason(portnum)
	# Returns the state reason of UDP port +portnum+

	# :method: udp_service(portnum)
	# Returns the Port::Service for UDP port +portnum+

	# :method: udp_script(portnum,name)
	# Returns the Script object for the script +name+ run against the
	# UDP port +portnum+

	# :method: udp_scripts(portnum)
	# Returns an array of Script objects for each script run on the UDP
	# port +portnum+ and yields them each to a block if one is given

	# :method: udp_script_output(portnum,name)
	# Returns the output of the script +name+ on the UDP port +portnum+

	# :method: sctp_port(portnum)
	# Just like getport(:sctp, +portnum+)

	# :method: sctp_ports(state="")
	# Just like getports(:sctp, +state+)

	# :method: sctp_port_list(state="")
	# Just like getportlist(:sctp, +state+)

	# :method: sctp_state(portnum)
	# Returns the state of SCTP port +portnum+

	# :method: sctp_reason(portnum)
	# Returns the state reason of SCTP port +portnum+

	# :method: sctp_service(portnum)
	# Returns the Port::Service for SCTP port +portnum+

	# :method: ip_proto(protonum)
	# Just like getport(:ip, +protonum+)

	# :method: ip_protos(state="")
	# Just like getports(:ip, +state+)

	# :method: ip_proto_list(state="")
	# Just like getportlist(:ip, +state+)

	# :method: ip_reason(protonum)
	# Returns the state of IP proto +protonum+

	# :method: ip_state(protonum)
	# Returns the state reason of IP proto +protonum+

	# :method: ip_service(protonum)
	# Returns the Port::Service for IP proto +protonum+

	[
		["tcp", "port"],
		["udp", "port"],
		["sctp", "port"],
		["ip", "proto"]
	].each do |type, prt|
		self.class_eval("
			def #{type}_#{prt}(portnum)
				getport(:#{type}, portnum) do |p|
					yield p if block_given?
				end
			end

			def #{type}_#{prt}s(state = '')
				getports(:#{type}, state) do |p|
					yield p if block_given?
				end
			end

			def #{type}_#{prt}_list(state = '')
				getportlist(:#{type}, state) do |p|
					yield p if block_given?
				end
			end

			def #{type}_state(portnum)
				(#{type}_#{prt}(portnum) or return).state
			end

			def #{type}_reason(portnum)
				(#{type}_#{prt}(portnum) or return).reason
			end

			def #{type}_service(portnum)
				(#{type}_#{prt}(portnum) or return).service
			end
		")

		next unless ['tcp', 'udp'].include?(type)

		self.class_eval("
			def #{type}_script(portnum, name)
				(#{type}_port(portnum) or return).script(name)
			end
		
			def #{type}_scripts(portnum)
				port = #{type}_port(portnum) or return
				port.scripts { |script| yield script } if block_given?
				port.scripts
			end
		
			def #{type}_script_output(portnum, name)
				(#{type}_port(portnum) or return).script_output(name)
			end
		")
	end

	# Returns the Script object for the specified host script +name+
	def script(name)
		@scripts.find { |script| script.id == name }
	end

	# Returns an array of Script objects for each host script run and
	# yields them each to a block if given
	def scripts
		@scripts.each { |script| yield script } if block_given?
		@scripts
	end

	# Returns the output of the specified host script +name+
	def script_output(name)
		@scripts.each do |script|
			return script.output if script.id == name
		end

		nil
	end

	private

	def parseAddr(elem)
		case elem[:attrs]['addrtype']
		when "mac"
			@mac_addr = elem[:attrs]['addr']
			@mac_vendor = elem[:attrs]['vendor']
		when "ipv4"
			@ip4_addr = elem[:attrs]['addr']
		when "ipv6"
			@ip6_addr = elem[:attrs]['addr']
		end
	end

	def parseHostnames(elem)
		@hostnames = []

		return if elem.nil?

		@hostnames = elem[:kids].collect_tags(:hostname) do |name|
			name[:attrs]['name']
		end
	end

	def parsePorts(ports)
		@ports = {
			:tcp => {},
			:udp => {},
			:sctp => {},
			:ip => {}
		}

		return if ports.nil?

		ports[:kids].each_tag(:port) do |port|
			num = port[:attrs]['portid'].to_i
			proto = port[:attrs]['protocol'].to_sym

			case proto
			when :tcp, :udp, :sctp, :ip
				@ports[proto][num] = Port.new(port)
			end
		end
	end

	def parseExtraPorts(ports)
		@extraports = []

		return if ports.nil?

		@extraports = ports[:kids].collect_tags(:extraports) { |e|
			ExtraPorts.new(e)
		}.sort
	end

	def parseScripts(scriptlist)
		@scripts = []

		return if scriptlist.nil?

		@scripts = scriptlist[:kids].collect_tags(:script) do |script|
			Script.new(script)
		end
	end

	def tcpseq(seq)
		return if seq.nil?

		@tcpsequence_index = seq[:attrs]['index'].to_i
		@tcpsequence_class = seq[:attrs]['class']
		@tcpsequence_values = seq[:attrs]['values']
		@tcpsequence_difficulty = seq[:attrs]['difficulty']
	end

	def ipidseq(seq)
		return if seq.nil?

		@ipidsequence_class = seq[:attrs]['class']
		@ipidsequence_values = seq[:attrs]['values']
	end

	def tcptsseq(seq)
		return if seq.nil?

		@tcptssequence_class = seq[:attrs]['class']
		@tcptssequence_values = seq[:attrs]['values']
	end

	def uptime(time)
		return if time.nil?

		@uptime_seconds = time[:attrs]['seconds'].to_i
		@uptime_lastboot = time[:attrs]['lastboot']
	end

	def initialize(hostinfo)
		parse(hostinfo)
	end

	def parse(host)
		status = host[:kids].find_tag(:status)

		@status = status[:attrs]['state']

		@reason = status[:attrs]['reason']

		@os = OS.new(host[:kids].find_tag(:os))

		host[:kids].each_tag(:address) do |elem|
			parseAddr(elem)
		end

		parseHostnames(host[:kids].find_tag(:hostnames))

		smurf = host[:kids].find_tag(:smurf)
		@smurf = smurf[:attrs]['responses'] if smurf

		ports = host[:kids].find_tag(:ports)

		parsePorts(ports)

		parseExtraPorts(ports)

		parseScripts(host[:kids].find_tag(:hostscript))

		trace = host[:kids].find_tag(:trace)
		@traceroute = Traceroute.new(trace) if trace

		tcpseq(host[:kids].find_tag(:tcpsequence))

		ipidseq(host[:kids].find_tag(:ipidsequence))

		tcptsseq(host[:kids].find_tag(:tcptssequence))

		uptime(host[:kids].find_tag(:uptime))

		distance = host[:kids].find_tag(:distance)
		@distance = distance[:attrs]['value'].to_i if distance

		@times = Times.new(host[:kids].find_tag(:times))

		stime = host[:attrs]['starttime']
		@starttime = stime.to_i if stime

		etime = host[:attrs]['endtime']
		@endtime = etime.to_i if etime
	end
end

# This holds information on the time statistics for this host
class Nmap::Parser::Host::Times
	# Smoothed round-trip time
	attr_reader :srtt
	# Round-trip time variance / deviation
	attr_reader :rttvar
	# How long before giving up on a probe (timeout)
	attr_reader :to

	private

	def initialize(times)
		parse(times)
	end

	def parse(times)
		return if times.nil?

		@srtt = times[:attrs]['srtt'].to_i
		@rttvar = times[:attrs]['rttvar'].to_i
		@to = times[:attrs]['to'].to_i
	end
end

# This holds the information about an NSE script run against a host or port
class Nmap::Parser::Host::Script
	# NSE Script name
	attr_reader :id
	# NSE Script output
	attr_reader :output

	alias name id

	private

	def initialize(script)
		parse(script)
	end

	def parse(script)
		return if script.nil?

		@id = script[:attrs]['id']
		@output = script[:attrs]['output']
	end
end

# This holds the information about an individual port or protocol
class Nmap::Parser::Host::Port
	# Port number
	attr_reader :num
	# Port protocol ("tcp", "udp", etc)
	attr_reader :proto
	# Service object for this port
	attr_reader :service
	# Port state ("open", "closed", "filtered", etc)
	attr_reader :state
	# Reason for the port state
	attr_reader :reason
	# The host that responded, if different than the target
	attr_reader :reason_ip
	# TTL from the responding host
	attr_reader :reason_ttl

	# Returns the Script object with the specified +name+
	def script(name)
		@scripts.find { |script| script.id == name }
	end

	# Returns an array of Script objects associated with this port and
	# yields them each to a block if one is given
	def scripts
		@scripts.each { |script| yield script } if block_given?
		@scripts
	end

	# Returns the output of the script +name+
	def script_output(name)
		@scripts.each do |script|
			return script.output if script.id == name
		end

		nil
	end

	# Compares port numbers
	def <=>(port)
		@num <=> port.num
	end

	private

	def initialize(portinfo)
		parse(portinfo)
	end

	def parse(port)
		@num = port[:attrs]['portid'].to_i
		@proto = port[:attrs]['protocol']
		state = port[:kids].find_tag(:state)
		@state = state[:attrs]['state']
		@reason = state[:attrs]['reason']
		@reason_ttl = state[:attrs]['reason_ttl'].to_i
		@reason_ip = state[:attrs]['reason_ip']

		@service = Service.new(port)

		@scripts = port[:kids].collect_tags(:script) do |script|
			Nmap::Parser::Host::Script.new(script)
		end
	end
end

# This holds the information about "extra ports": groups of ports which have
# the same state.
class Nmap::Parser::Host::ExtraPorts
	# Total number of ports in this state
	attr_reader :count
	# What state the ports are in
	attr_reader :state

	# Returns an array of arrays, each of which are in the form of:
	#
	# [ <port count>, reason ]
	#
	# for each set of reasons and yields them each to a block if one is
	# given
	def reasons
		@reasons.each { |reason| yield reason } if block_given?
		@reasons
	end

	# Compares the port counts
	def <=>(extraports)
		@count <=> extraports.count
	end

	private

	def initialize(extraports)
		parse(extraports)
	end

	def parse(extraports)
		@count = extraports[:attrs]['count'].to_i
		@state = extraports[:attrs]['state']

		@reasons = []

		extraports[:kids].each_tag(:extrareasons) do |extra|
			ecount = extra[:attrs]['count'].to_i
			ereason = extra[:attrs]['reason']
			@reasons << [ ecount, ereason ]
		end
	end
end

# This holds information on a traceroute, such as the port and protocol used
# and an array of responsive hops
class Nmap::Parser::Host::Traceroute
	# Port number used during traceroute
	attr_reader :port
	# Protocol used during traceroute
	attr_reader :proto

	# Returns the Hop object for the given TTL
	def hop(ttl)
		@hops.find { |hop| hop.ttl == ttl.to_i }
	end

	# Returns an array of Hop objects, which are each a responsive hop,
	# and yields them each to a block if one if given.
	def hops
		@hops.each { |hop| yield hop } if block_given?
		@hops
	end

	private

	def initialize(trace)
		parse(trace)
	end

	def parse(trace)
		@port = trace[:attrs]['port'].to_i
		@proto = trace[:attrs]['proto']

		@hops = trace[:kids].collect_tags(:hop) do |hop|
			Hop.new(hop)
		end
	end
end

# This holds information on an individual traceroute hop
class Nmap::Parser::Host::Traceroute::Hop
	# How many hops away the host is
	attr_reader :ttl
	# Round-trip time of the host
	attr_reader :rtt
	# IP address of the host
	attr_reader :addr
	# Hostname of the host
	attr_reader :hostname

	alias host hostname 
	alias ipaddr addr

	# Compares the TTLs
	def <=>(hop)
		@ttl <=> hop.ttl
	end

	private

	def initialize(hop)
		parse(hop)
	end

	def parse(hop)
		@ttl = hop[:attrs]['ttl'].to_i
		@rtt = hop[:attrs]['rtt'].to_f
		@addr = hop[:attrs]['ipaddr']
		@hostname = hop[:attrs]['host']
	end
end

# This holds the service information for a port
class Nmap::Parser::Host::Port::Service
	# Name of the service
	attr_reader :name
	# Vendor name
	attr_reader :product
	# Version number
	attr_reader :version
	# How this information was obtained, such as "table" or "probed"
	attr_reader :method
	# Service owner
	attr_reader :owner
	# Any tunnelling used, like "ssl"
	attr_reader :tunnel
	# RPC program number
	attr_reader :rpcnum
	# Range of RPC version numbers
	attr_reader :lowver, :highver
	# How confident the version detection is
	attr_reader :confidence
	# Protocol, such as "rpc"
	attr_reader :proto
	# Extra misc. information about the service
	attr_reader :extra
	# Type of device the service is running on
	attr_reader :devicetype
	# OS the service is running on
	attr_reader :ostype
	# Service fingerprint
	attr_reader :fingerprint

	alias extrainfo extra

	private

	def initialize(port)
		parse(port)
	end

	def parse(port)
		service = port[:kids].find_tag(:service)

		return if service.nil?

		@name = service[:attrs]['name']
		@product = service[:attrs]['product']
		@version = service[:attrs]['version']
		@method = service[:attrs]['method']
		owner = port[:kids].find_tag(:owner)
		@owner = owner[:attrs]['name'] if owner
		@tunnel = service[:attrs]['tunnel']
		rpcnum = service[:attrs]['rpcnum']
		@rpcnum = rpcnum.to_i if rpcnum
		lowver = service[:attrs]['lowver']
		@lowver = lowver.to_i if lowver
		highver = service[:attrs]['highver']
		@highver = highver.to_i if highver
		conf = service[:attrs]['conf']
		@confidence = conf.to_i if conf
		@proto = service[:attrs]['proto']
		@extra = service[:attrs]['extrainfo']
		@devicetype = service[:attrs]['devicetype']
		@ostype = service[:attrs]['ostype']
		@fingerprint = service[:attrs]['servicefp']
	end
end

# This holds the OS information from OS Detection
class Nmap::Parser::Host::OS
	# OS fingerprint
	attr_reader :fingerprint

	# Returns an array of OSClass objects and yields them each to a block
	# if one is given
	def osclasses
		@osclasses.each { |osclass| yield osclass } if block_given?
		@osclasses
	end

	# Returns an array of OSMatch objects and yields them each to a block
	# if one is given
	def osmatches
		@osmatches.each { |osmatch| yield osmatch } if block_given?
		@osmatches
	end

	# Returns the number of OS class records
	def class_count
		@osclasses.size
	end

	# Returns OS class accuracy of the first OS class record, or Nth record
	# as specified by +index+
	def class_accuracy(index = 0)
		(@osclasses[index.to_i] or return).accuracy
	end

	# :method: osfamily(index=0)
	# Returns OS family information of first OS class record, or Nth record
	# as specified by +index+

	# :method: osgen(index=0)
	# Returns OS generation information of first OS class record, or Nth
	# record as specified by +index+

	# :method: ostype(index=0)
	# Returns OS type information of the first OS class record, or Nth
	# record as specified by +index+

	# :method: osvendor(index=0)
	# Returns OS vendor information of the first OS class record, or Nth
	# record as specified by +index+

	["family", "gen", "type", "vendor"].each do |name|
		self.class_eval("
			def os#{name}(index = 0)
				(@osclasses[index.to_i] or return).os#{name}
			end
		")
	end

	# Returns the number of OS match records
	def name_count
		@osmatches.size
	end

	# Returns name of first OS match record, or Nth record as specified by
	# +index+
	def name(index = 0)
		(@osmatches[index.to_i] or return).name
	end

	# Returns OS name accuracy of the first OS match record, or Nth record
	# as specified by +index+
	def name_accuracy(index = 0)
		(@osmatches[index.to_i] or return).accuracy
	end

	# Returns an array of names from all OS records and yields them each to
	# a block if one is given
	def names() # :yields: name
		@osmatches.map do |match|
			yield match.name if block_given?
			match.name
		end
	end

	alias all_names names

	# Returns the closed TCP port used for this OS Detection run
	def tcpport_closed
		getportnum("tcp", "closed")
	end

	# Returns the open TCP port used for this OS Detection run
	def tcpport_open
		getportnum("tcp", "open")
	end

	# Returns the closed UDP port used for this OS Detection run
	def udpport_closed
		getportnum("udp", "closed")
	end

	private

	def getportnum(proto, state)
		@portsused.each do |port|
			if port.proto == proto and port.state == state
				return port.num
			end
		end

		nil
	end

	def initialize(os)
		parse(os)
	end

	def parse(os)
		@portsused = []
		@osclasses = []
		@osmatches = []

		return if os.nil?

		@portsused = os[:kids].collect_tags(:portused) do |port|
			PortUsed.new(port)
		end

		@osclasses = os[:kids].collect_tags(:osclass) { |osclass|
			OSClass.new(osclass)
		}.sort.reverse

		@osmatches = os[:kids].collect_tags(:osmatch) { |match|
			OSMatch.new(match)
		}.sort.reverse

		fp = os[:kids].find_tag(:osfingerprint)
		@fingerprint = fp[:attrs]['fingerprint'] if fp
	end
end

class Nmap::Parser::Host::OS::PortUsed # :nodoc: all
	attr_reader :state, :proto, :num

	private

	def initialize(ports)
		parse(ports)
	end

	def parse(ports)
		@state = ports[:attrs]['state']
		@proto = ports[:attrs]['proto']
		@num = ports[:attrs]['portid'].to_i
	end
end

# Holds information for an individual OS class record
class Nmap::Parser::Host::OS::OSClass
	# Device type, like "router" or "general purpose"
	attr_reader :ostype
	# Company that makes the OS, like "Apple" or "Microsoft"
	attr_reader :osvendor
	# Product name, like "Linux" or "Windows"
	attr_reader :osfamily
	# A more precise description, like "2.6.X" for Linux
	attr_reader :osgen
	# Accuracy of this information
	attr_reader :accuracy

	# Compares accuracy
	def <=>(osclass)
		@accuracy <=> osclass.accuracy
	end

	private

	def initialize(osclass)
		parse(osclass)
	end

	def parse(osclass)
		@ostype = osclass[:attrs]['type']
		@osvendor = osclass[:attrs]['vendor']
		@osfamily = osclass[:attrs]['osfamily']
		@osgen = osclass[:attrs]['osgen']
		@accuracy = osclass[:attrs]['accuracy'].to_i
	end
end

# Holds information for an individual OS match record
class Nmap::Parser::Host::OS::OSMatch
	# Operating System name
	attr_reader :name
	# Accuracy of this match
	attr_reader :accuracy

	# Compares accuracy
	def <=>(osmatch)
		@accuracy <=> osmatch.accuracy
	end

	private

	def initialize(os)
		parse(os)
	end

	def parse(os)
		@name = os[:attrs]['name']
		@accuracy = os[:attrs]['accuracy'].to_i
	end
end

# :stopdoc:

#
# Now for the actual XML parsing stuff for Nmap::Parser ...
#

class Nmap::XmlParsing::TagGroup < Array
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

# Super simple!
class Nmap::XmlParsing::Tag < Hash
	private

	def initialize(name, attrs)
		self[:name] = name
		self[:attrs] = attrs
		self[:kids] = Nmap::XmlParsing::TagGroup.new
	end
end

class Nmap::XmlParsing::MyParser
	include Nmap

	attr_reader :session
	attr_reader :hosts

	def tag_start(tag, attrs)
		name = tag.to_sym

		return if ignored(name)

		kv = XmlParsing::Tag.new(name, attrs)

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
		when :host
			@hosts << Parser::Host.new(last)
			@loc[@loc.size - 2][:kids].pop

			if @callback
				Thread.new(@hosts.last) do |host|
					Thread.current[:cb] = true
					@callback.call(host)
				end
			end
		when :nmaprun
			@session = Parser::Session.new(last)

			if @callback and Thread.list.size > 1
				Thread.list.reject { |t|
					not t[:cb]
				}.each { |t|
					t.join
				}
			end
		end
	end

	def method_missing(sym, *args)
	end

	def completed?
		# @session becomes non-nil when <nmaprun> closes, which means
		# we're done
		@session ? true : false
	end

	private

	# We don't want to store anything we don't care about!
	IGNORED = [
		:taskbegin,
		:taskprogress,
		:taskend,
		# Zenmap uses this for screen output
		:output
	]

	def ignored(name)
		IGNORED.find { |ent| ent == name }
	end

	def initialize(callback)
		@data = {}
		@loc = []

		@session = nil
		@hosts = []

		@callback = callback
	end
end

