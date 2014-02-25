module Dradis
  class SessionsController < BaseController
    before_action :ensure_setup, :only => :new
    before_action :ensure_not_setup, :only => [:init, :setup]

    # ------------------------------------------- Initial shared password setup
    # Initialise the session, clear any objects that might currently exist and
    # present the session start up configuration HTML form.
    #
    # GET /setup
    def init
    end

    # POST /setup
    def setup
          # @password was set by the ensure_valid_password filter
          c = Dradis::Configuration.find_by_name('password')
          c.value = ::Digest::SHA512.hexdigest(@password)
          c.save
          flash[:notice] = 'Password set. Please log in.'
              redirect_to :action => :new
    end
    # ------------------------------------------ /Initial shared password setup



    # GET /login
    def new
    end

    # POST /sessions
    def create
      usr = params.fetch(:username, nil)
      pwd = params.fetch(:password, nil)
      if not ( usr.blank? || pwd.nil? || ::Digest::SHA512.hexdigest(pwd) != Dradis::Configuration.password)
        self.current_user = usr
        redirect_to root_path, notice: 'Logged in successfully'
      else
        flash.now[:error] = 'Try again.'
        render :action => 'new'
      end
    end

    # GET /logout
    def destroy
      reset_session
      redirect_to root_url, :notice => 'You have been logged out.'
    end

    protected

    # If the database doesn't contain a valid password, a new one needs to be
    # created.
    def ensure_setup
      redirect_to :action => :init if (Dradis::Configuration.password == 'improvable_dradis')
    end

    # Only allow access to the setup actions if we still don't have a valid
    # shared password.
    def ensure_not_setup
      redirect_to :action => :new unless (Dradis::Configuration.password == 'improvable_dradis')
    end
  end
end