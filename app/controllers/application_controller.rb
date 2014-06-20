# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery
  
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem  
  
  before_filter :show_first_time_wizard

  # This filter would display the 'First Time' wizard the first time dradis is
  # run in this box. 
  # In order to do this it checks for the presence of the 
  # config/first_login.txt file and if not found, it creates it and presents
  # the user with the wizard view.
  def show_first_time_wizard
    magic_file = Rails.root.join('config', 'first_login.txt')
    if (File.exists?(magic_file) )
      return true
    else
      File.open(magic_file, "w") do |f|
        f << "This file indicates that a succesful login event has occurred on this dradis instance"
      end

      redirect_to :controller => :wizard
    end
  end

end
