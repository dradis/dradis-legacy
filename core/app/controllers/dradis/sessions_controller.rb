module Dradis
  class SessionsController < BaseController
    # GET /login
    def new
    end

    # POST /sessions
    def create
      usr = params.fetch(:username, nil)
      # pwd = params.fetch(:password, nil)
      if not ( usr.nil? ) #|| pwd.nil? || ::Digest::SHA512.hexdigest(pwd) != ::Configuration.password)
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
  end
end