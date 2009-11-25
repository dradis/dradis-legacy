# The MetaServer class is a helper class created out of the need to store all
# the Meta-Server related configuration into a single object during the server
# initialisation.
#
# It holds information about the Meta-Server's host name and port number along
# with credentials to access it.
#
# Objects of this class are never persisted in the DB and only live in memory
# associated with a user's session.
class MetaServer
  attr_reader  :host, :port, :user, :password, :path
  attr_writer  :host, :port, :user, :password, :path

  # To create a MetaServer object you need to provide a configuration Hash 
  # containing the following items:
  #
  # +host+
  # +port+
  # +user+
  # +password+
  def initialize(attributes={})
    if (([ 'host', 'port', 'user', 'password' ] &  attributes.keys).size != 4)
      raise 'Submit all the required fields'
    end

    @host = attributes.fetch( 'host', '' )
    @port = attributes.fetch( 'port', '' )
    @user = attributes.fetch( 'user', '' )
    @password = attributes.fetch( 'password', '' )

    # Maybe the Meta-Server is configured in a sub-path. Add a trailing slash
    # if it is missing.
    @path = attributes.fetch( 'path', '/' )
    @path.sub!(/\?|\z/) { "/" + $& } unless @path[-1]==?/
  end


  # Create an ActiveResource +site+ URL from the configuration settings
  # associated with this MetaServer instance. The format URL will follow
  # this pattern:
  #   http://<user>:<password>@<host>:<port>/
  def site_url()
    return @site_url if defined?(@site_url)

    @site_url = 'http://'
    @site_url << @user
    @site_url << ':'
    @site_url << @password
    @site_url << '@'
    @site_url << @host
    @site_url << ':'
    @site_url << @port.to_s
    @site_url << @path 

    return @site_url
  end

end
