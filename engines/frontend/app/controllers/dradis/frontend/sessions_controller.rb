require 'bcrypt'

module Dradis
  module Frontend
    class SessionsController < Dradis::Frontend::ApplicationController
      before_action :ensure_setup, only: :new
      before_action :ensure_not_setup, only: [:init, :setup]
      before_action :ensure_valid_password, only: :setup

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
        c.value = ::BCrypt::Password.create(@password)
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
        if not ( usr.blank? || pwd.nil? || ::BCrypt::Password.new(Dradis::Configuration.password) != pwd )
          self.current_user = usr
          redirect_to root_path, notice: 'Logged in successfully'
        else
          flash.now[:alert] = 'Try again.'
          @username = usr
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
        if Dradis::Core::Configuration.password.nil?
          render action: :not_ready
        elsif (Dradis::Core::Configuration.password == 'improvable_dradis')
          redirect_to action: :init
        end
      end

      # Only allow access to the setup actions if we still don't have a valid
      # shared password.
      def ensure_not_setup
        redirect_to :action => :new unless (Dradis::Core::Configuration.password == 'improvable_dradis')
      end

      # Ensure that the user has provided a valid password, that the password
      # matches the confirmation and that they are not empty.
      #
      # FIXME: we should move this to a form object.
      # See:
      #   http://railscasts.com/episodes/416-form-objects
      #
      def ensure_valid_password
        # Step 1:  Password and Password confirmation match
        pwd1 = params.fetch( :password, nil )
        pwd2 = params.fetch( :password_confirmation, nil )

        if (pwd1.nil? || pwd2.nil? || pwd1.blank?)
          flash[:alert] = 'You need to provide both a password and a confirmation.'
          render :init
          return false
        end

        if not pwd1 == pwd2
          flash[:alert] = 'The password did not match the confirmation.'
          render :init
          return false
        end

        @password = pwd1
        return true
      end
    end
  end
end