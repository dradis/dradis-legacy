# This is the primary controller in charge of rendering the 
# ExtJS[http://extjs.com] interface
class HomeController < ApplicationController
  layout 'postauth'
  before_filter :login_required
  
  # The only action provided by the controller renders the home page view
  # located at app/views/home/index.html.erb.
  def index
  end
  
end
