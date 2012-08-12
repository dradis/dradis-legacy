module Dradis
  module Concerns
    module CurrentUser
      extend ActiveSupport::Concern
      included do
        # Add before_filter calls here
        helper_method :current_user
      end

      protected
      def login_from_session
        # In Dradis we don't have a User model, we store the user's name in the
        # session.
        #User.find_by_id(session[:user_id]) if session[:user_id]
        session[:user_id] if session[:user_id]
      end

      def current_user
        @current_user ||= login_from_session # || login_from_basic_auth
      end

      def current_user=(username)
        session[:user_id] = username
      end

      def access_denied
        respond_to do |format|
          format.html do
            # store_location
            flash[:notice] = 'Please sign in first.'
            redirect_to login_path
          end
          format.json { head :unauthorized }
        end
      end

      def login_required
        !!current_user || access_denied
      end
    end
  end
end