require 'digest/sha2'
# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  layout 'banner'
  
  before_filter :check_test_password, :only => :new

  # Validate user settings before seting up the new project
  before_filter :update_user_selection, :only => :setup
  before_filter :ensure_valid_password, :only => :setup
  before_filter :ensure_valid_metaserver_settings, :only => :setup
  
  # Initialise the session, clear any objects that might currently exist and
  # present the session start up configuration HTML form.
  def init
    unless (::Configuration.password == 'improvable_dradis')
      redirect_to :action => :new
    end
    @projects = nil
    @new_project = true
    if session[:meta_server]
      @new_project = false
      @projects = Project.find_from_metaserver( session[:meta_server] )
    end
  end

  # Once the user submits the settings form we initialise the database, note 
  # that the ensure_valid_password and ensure_valid_metaserver_settings filters
  # have performed the necessary validation of the supplied input
  def setup
    unless (::Configuration.password == 'improvable_dradis')
      redirect_to :action => :new
      return
    end

   
    # Step 3: Initialise the project
    # @password was set by the ensure_valid_password filter
    c = ::Configuration.find_by_name('password')
    c.value = ::Digest::SHA512.hexdigest(@password)
    c.save

    if (@new_project)
      ::Configuration.create( :name => 'mode', :value => 'new' )
    else
      # Download project revision
      uploadsNode = Node.find_or_create_by_label(::Configuration.uploadsNode)
      import_path = Rails.root.join( 'attachments', uploadsNode.id.to_s )
      FileUtils.mkdir_p( import_path )
      package_file = File.join( import_path, 'revision_import.zip' )
      File.open( package_file, 'wb+') do |f|
        f.write Base64::decode64( @project_revision.get(:download) )
      end

      # Unpack, restore the DB and attachments
      ProjectPackageUpload.import( 
        :file => Attachment.new(:filename => 'revision_import.zip', 
                                :node_id => uploadsNode.id) 
      )
    end

    flash[:notice] =  'Password set. Please log in.'
    redirect_to :action => :new
  end

  # Present the login form
  def new
  end

  # Create a new session for the :login user if the :password matches the one
  # configured in this instance (see Configuration.password)
  def create
    usr = params.fetch(:login, nil)
    pwd = params.fetch(:password, nil)
    if not ( usr.nil? || pwd.nil? || ::Digest::SHA512.hexdigest(pwd) != ::Configuration.password)
      flash[:first_login] = first_login?
      self.current_user = usr
      redirect_back_or_default( root_path )
      #flash[:notice] = 'Logged in successfully.'
    else
      flash.now[:error] = 'Try again.'
      render :action => 'new'
    end
  end
  
  # Logout action. Reset the session.
  def destroy
    #self.current_user.forget_me if logged_in?
    #cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default( login_path )
  end

  protected
  # before filter, if the database doesn't contain a valid password, a new
  # one is created.  
  def check_test_password
    if ::Configuration.password.nil?
      render :action => :not_ready
    elsif (::Configuration.password == 'improvable_dradis')
      redirect_to :action => :init
    end
  end

  # we determine if the login event is the first for this dradis deployment
  # by checking the existance of a file in the config folder
  # the file is created if it does not exist
  def first_login?
    if File.exists?(Rails.root.join('config', 'first_login.txt'))
      first_login = false
    else
      file_handle = File.new(Rails.root.join('config', 'first_login.txt'), "w")
      file_handle << "This file indicates that a succesful login event has occurred on this dradis instance"
      file_handle.close
      first_login = true
    end
    return first_login
  end

  # Ensure that the user has provided a valid password, that the password 
  # matches the confirmation and that they are not empty.
  def ensure_valid_password
    # Step 1:  Password and Password confirmation match
    pwd = params.fetch( :password, nil )
    if (pwd.nil?)
      flash[:error] = 'You need to provide new password information.'
      redirect_to :action => :init
      return false
    end
    
    pwd1 = pwd.fetch( :value, nil )
    pwd2 = pwd.fetch( :confirm_value, nil )
    
    if (pwd1.nil? || pwd2.nil? || pwd1.blank?)
      flash[:error] = 'You need to provide both a password and a confirmation.'
      redirect_to :action => :init
      return false
    end
    
    if not pwd1 == pwd2
      flash[:error] = 'The password did not match the confirmation.'
      redirect_to :action => :init
      return false
    end
 
    @password = pwd1
    return true
  end
end
