class MetasploitController < AuthenticatedController  
  # show the main interface
  def index
  end
  
  # retrieve Hosts and Services from remote Metasploit instance
  def hosts
    @success = false
    msf_client = nil
    
    # create a Metasploit connection object
    begin 
      msf_client = Msf.new({:host => MsfImport::Configuration.host, 
        :port => MsfImport::Configuration.port.to_i,
        :user => MsfImport::Configuration.user,
        :pass => MsfImport::Configuration.pass})
      @success = true
    rescue MsfError => e
      flash.now[:error] = "Error: #{e.reason}"
      return
    end

    # pull hosts and services
    begin
      @hosts = msf_client.hosts
      @services = msf_client.services
    rescue MsfError => e
      flash.now[:error] = "Error: #{e.reason}"
    end
  end
end