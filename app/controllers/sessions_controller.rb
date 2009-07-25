# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  layout 'banner'
  
  before_filter :check_test_password, :only => :new
  
  # ------------------------------------------------------------- test password
  # render init.rhtml
  def init
    unless Configuration.password.match('dradis')
      redirect_to :action => :new
    end
    @projects = nil
    @new_project = true
    if session[:meta_server]
      @new_project = false
      @projects = Project.find_from_metaserver( session[:meta_server] )
    end
  end

  def change_metaserver
    session[:meta_server] = nil
    render :update do |page|
      page.replace_html 'meta_server', :partial => 'meta_server'
    end
  end

  def get_projects
    render :update do |page|
      @projects = nil
      begin
        meta_server = session[:meta_server] || MetaServer.new( params.fetch( :meta_server, {} ) )
        @projects = Project.find_from_metaserver(meta_server)
        session[:meta_server] = meta_server

        page.replace_html 'meta_server', :partial => 'project_browser'
      rescue Exception => e
        flash.now[:meta_server] = e.message
        page.replace_html 'meta_server', :partial => 'meta_server'
      end
    end
  end
  
  def setup
    unless Configuration.password.match('dradis')
      redirect_to :action => :new
      return
    end

    mode = params.fetch(:mode, nil)
    # Just in case validation fails, ensure that the checkboxes have the right
    # selection
    session[:meta_server] = nil if (mode == 'new')
    @new_project = session[:meta_server] ? false : true

    # Step 1:  Password and Password confirmation match
    pwd = params.fetch( :password, nil )
    if (pwd.nil?)
      flash[:error] = 'You need to provide new password information.'
      redirect_to :action => :init
      return
    end
    
    pwd1 = pwd.fetch( :value, nil )
    pwd2 = pwd.fetch( :confirm_value, nil )
    
    if (pwd1.nil? || pwd2.nil? || pwd1.blank?)
      flash[:error] = 'You need to provide both a password and a confirmation.'
      redirect_to :action => :init
      return
    end
    
    if not pwd1 == pwd2
      flash[:error] = 'The password did not match the confirmation.'
      redirect_to :action => :init
      return      
    end
    
    # Step 2: Ensure that we have a Revision, if the user has chosen meta-server mode
    revision = params.fetch(:revision, nil)

    if (mode.nil? || ((mode!='meta-server') & (mode!='new')))
      flash[:error] = 'You have to choose a valid mode'
      redirect_to :action => :init
      return      
    end

    if (mode == 'meta-server') && revision.nil? 
      flash[:error] = 'You have to choose a revision to checkout'
      redirect_to :action => :init
      return      
    end

    if (mode == 'meta-server') && session[:meta_server].nil?
      # TODO: this should never happen!!
      #flash[:error] = 'You have to choose a revision to checkout'
      redirect_to :action => :init
      return      
    end
    
    
    project_revision = nil
    if ( !@new_project )
      project, revision = revision.split('_')
      p_id = project.to_i
      r_id = revision.to_i
      begin
        Project.find_from_metaserver( session[:meta_server] )
        project = Project.find(p_id)
        revision_found = false
        project.attributes['revisions'].each do |rev|
          next if (rev.id != r_id)
          revision_found = true
          project_revision = rev
        end

        if !revision_found
          flash[:error] = 'Invalid revision'
          redirect_to :action => :init
          return      
        end
      rescue
          flash[:error] = 'Invalid revision'
          redirect_to :action => :init
          return      
      end
    end

    # Step 3: Initialise the project
    c = Configuration.find_by_name('password')
    c.value = pwd1
    c.save

    # Download project revision
    
    flash[:notice] =  'Password set. Please log in.<br/> Remember to adjust the client configuration file (client/conf/dradis.xml).'
    redirect_to :action => :new
  end

  # -------------------------------------------------------------- user session
  # render new.rhtml
  def new
  end

  def create
    usr = params.fetch(:login, nil)
    pwd = params.fetch(:password, nil)
    if not ( usr.nil? || pwd.nil? || pwd != Configuration.password)
      flash[:first_login] = first_login?
      self.current_user = usr
      redirect_back_or_default('/')
      flash[:notice] = 'Logged in successfully.'
    else
      flash.now[:error] = 'Try again.'
      render :action => 'new'
    end
  end
  
  def destroy
    #self.current_user.forget_me if logged_in?
    #cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_back_or_default( login_path )
  end

  protected
  # before filter, if the database doesn't contain a valid password, a new
  # one is created.  
  def check_test_password
    if Configuration.password.match('dradis')
      redirect_to :action => :init
    end
  end

  # we determine if the login event is the first for this dradis deployment
  # by checking the existance of a file in the config folder
  # the file is created if it does not exist
  def first_login?
    if File.exists?(File.join(RAILS_ROOT, "config/fist_login.txt"))
      first_login = false
    else
      file_handle = File.new(File.join(RAILS_ROOT, "config/fist_login.txt"), "w")
      file_handle << "This file indicates that a succesful login event has occurred on this dradis instance"
      file_handle.close
      first_login = true
    end
    return first_login
  end
end
