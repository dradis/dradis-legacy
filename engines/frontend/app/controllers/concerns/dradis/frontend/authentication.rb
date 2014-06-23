module Dradis
  module Frontend
    module Authentication

      def self.included(base)
        base.extend ClassMethods
        base.class_eval do
          helper_method :current_user
        end
      end

      def access_denied
        redirect_to(login_path, alert: 'Please sign in first. Access denied.')
      end

      # Proxy to the authenticated? method on warden
      # :api: public
      def authenticated?(*args)
        warden.authenticated?(*args)
      end

      # Access the currently logged in user
      # :api: public
      def current_user(*args)
        warden.user(*args)
      end

      # Filter method to enforce a login requirement.
      #
      # To require logins for all actions, use this in your controllers:
      #
      #   before_filter :login_required
      #
      # To require logins for specific actions, use this in your controllers:
      #
      #   before_filter :login_required, :only => [ :edit, :update ]
      #
      # To skip this in a subclassed controller:
      #
      #   skip_before_filter :login_required
      #
      def login_required
        authenticated? || access_denied
      end

      # Logout the current user
      # :api: public
      def logout(*args)
        warden.raw_session.inspect # Without this inspect here. The session does not clear :|
        warden.logout(*args)
      end

      # Redirect to the URI stored by the most recent store_location call or
      # to the passed default.
      def redirect_to_target_or_default(default, *args)
        redirect_to(session[:return_to] || default, *args)
        session[:return_to] = nil
      end

      # The main accessor for the warden proxy instance
      # :api: public
      def warden
        request.env['warden']
      end

      # methods defined here are going to extend the class, not the instance of it
      module ClassMethods
      end
    end
  end
end