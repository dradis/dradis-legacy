require "xmlrpc/client"
require 'socket'


# XMLRPC Client based off of Metasploit's nonstandard client
class Client < ::XMLRPC::Client

  attr_accessor :sock

  # Use a TCP socket to do RPC
  def initialize(args={})

    @buff = ""
    self.sock = TCPSocket.new(args[:host],args[:port])
  end

  def do_rpc(request,async)

    begin
      self.sock.send(request + "\x00",0)

      while(not @buff.index("\x00"))
        resp = self.sock.recv(32768)
        raise EOFError, "XMLRPC connection closed" if resp == ""
        @buff << resp if resp
      end
    rescue ::Exception => e
      self.close
      raise EOFError, "XMLRPC connection closed"
    end

    mesg,left = @buff.split("\x00", 2)
    @buff = left.to_s
    mesg
  end

  def close
    self.sock.close rescue nil
    self.sock = nil
  end

end

class MsfError < StandardError
    attr_reader :reason
    def initialize(reason)
      @reason = reason
    end
end

class Msf
  def initialize(args)
    @host = args[:host]
    @port = args[:port]
    @user = args[:user]
    @pass = args[:pass]
    @token = nil
    @lastauth = nil
    @connecterror = "An error occured while talking to the Metasploit backend.  Please verify the server is up and try again"

    begin
      @c = Client.new({:host => @host, :port => @port})
    rescue
      raise MsfError.new("Could not create XMLRPC object, verify the xmlrpc ruby module is installed and that your host and port information are correct")
    end
  end

  def login()
    begin
      res = @c.call('auth.login',@user,@pass)
    rescue Exception => e
      raise MsfError.new("Invalid username or password.  Please check your credentials and try again")
    end

    if res['result'] == "success"
      @token = res['token'] 
      @lastauth = Time.new
    else
      raise MsfError.new("Invalid username or password.  Please check your credentials and try again")
    end

  end

  def auth()
    login() if @token == nil
    login() if (Time.now  - @lastauth > 600)
  end

  def services()
    auth()
    begin
      res = @c.call('db.services',@token,{})
    rescue
      raise MsfError.new(@connecterror)
    end
    res['services']
  end

  def hosts()
    auth()
    begin
      res = @c.call('db.hosts',@token,{})
    rescue
      raise MsfError.new(@connecterror)
    end
    res['hosts']
  end

  def get_notes(opts)
    auth()
    begin
      res = @c.call('db.get_note',@token,opts)
    rescue
      raise MsfError.new(@connecterror)
    end
    res['note']
  end

  def get_vulns(opts)
    auth()
    begin
      res = @c.call('db.get_vuln',@token,opts)
    rescue
      raise MsfError.new(@connecterror)
    end
    res['vuln']
  end

end
