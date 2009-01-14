# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  layout 'preauth'
  
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
    
    if not pwd1.match(pwd2)
      flash.now[:error] = 'The password did not match the confirmation.'
      render :action => :init
      return      
    end
    
    c = Configuration.find_by_name('password')
    c.value = pwd1
    c.save
    
    flash[:notice] = 'Password set. Please log in.'
    redirect_to :action => :new
  end

  # -------------------------------------------------------------- user session
  # render new.rhtml
  def new
  end

  def create
    usr = params.fetch(:login, nil)
    pwd = params.fetch(:password, nil)
    if not ( usr.nil? || pwd.nil? || !pwd.match(Configuration.password))
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
end
