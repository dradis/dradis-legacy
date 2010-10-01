# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => 'f03fd569848374a6c0110c829c91ef57'
  
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem  
  
  before_filter :show_first_time_wizard

  # This filter would display the 'First Time' wizard the first time dradis is
  # run in this box. 
  # In order to do this it checks for the presence of the 
  # config/first_login.txt file and if not found, it creates it and presents
  # the user with the wizard view.
  def show_first_time_wizard
    magic_file = File.join( RAILS_ROOT, 'config', 'first_login.txt' )
    if (File.exists?(magic_file) )
      return true
    else
      File.open(File.join(RAILS_ROOT, "config/first_login.txt"), "w") do |f|
        f << "This file indicates that a succesful login event has occurred on this dradis instance"
      end

      redirect_to :controller => :wizard
    end
  end

end
