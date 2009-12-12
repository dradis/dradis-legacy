# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'f03fd569848374a6c0110c829c91ef57'
  
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem  
  
  filter_parameter_logging :password, :password_confirmation

end
