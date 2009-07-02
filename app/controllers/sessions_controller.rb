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
  end
  
  def setup
    unless Configuration.password.match('dradis')
      redirect_to :action => :new
      return
    end

    pwd = params.fetch( :password, nil )
    if (pwd.nil?)
      flash.now[:error] = 'You need to provide new password information.'
      render :action => :init
      return
    end
    
    pwd1 = pwd.fetch( :value, nil )
    pwd2 = pwd.fetch( :confirm_value, nil )
    
    if (pwd1.nil? || pwd2.nil?)
      flash.now[:error] = 'You need to provide both a password and a confirmation.'
      render :action => :init
      return
    end
    
    if not pwd1 == pwd2
      flash.now[:error] = 'The password did not match the confirmation.'
      render :action => :init
      return      
    end
    
    c = Configuration.find_by_name('password')
    c.value = pwd1
    c.save
    
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
      debugger
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
