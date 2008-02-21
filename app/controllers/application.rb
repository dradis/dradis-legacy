# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # Pick a unique cookie name to distinguish our session data from others'
  #session :session_key => '_dserver_session_id'
  session :disabled => true
  layout 'main'
  # not ye implemented, plus it breaks the client web service calls :)
  #before_filter :authorise


  private
    def authorise
      # Log in using session data if it exists.
      if session['user']
        p session['user']
        @user = session['user'] and return true
      end

      # Otherwise log in from authentication data sent in request header.
      login, password = get_auth_data
      if login and password and password == 'etd001'
        session["user"] = login
        @user = login
        return true
      end

      # If no auth data, or wrong auth data, issue a challenge.
      response.headers["Status"] = "Unauthorized" 
      response.headers["WWW-Authenticate"] = 'Basic realm="st. eves"'
      render(:text => "Authentication required", :status => 401)       
    end 

    def deauthorise
      session.delete("account_id")
    end

    def get_auth_data 
      auth_data = nil
      [
        'REDIRECT_REDIRECT_X_HTTP_AUTHORIZATION',
        'REDIRECT_X_HTTP_AUTHORIZATION',
        'X-HTTP_AUTHORIZATION', 
        'HTTP_AUTHORIZATION'
      ].each do |key|
        if request.env.has_key?(key)
          auth_data = request.env[key].to_s.split
          break
        end
      end

      if auth_data && auth_data[0] == 'Basic' 
        return Base64.decode64(auth_data[1]).split(':')[0..1] 
      end 
    end 
end
