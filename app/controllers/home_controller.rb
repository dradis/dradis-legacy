
# This is the primary controller in charge of rendering the 
# ExtJS[http://extjs.com] interface
class HomeController < ApplicationController
  layout 'postauth'
#  before_filter :login_required
  
  # The only action provided by the controller renders the home page view
  # located at app/views/home/index.html.erb.
  def index
  end
  
  # Returns the Textile version of a text passed as parameter
  def textilize
    respond_to do |format|
      format.html { head :method_not_allowed }
      format.json { 
        # gracefully handle RedCloth absence
        output = params[:text] 
        begin
          require 'RedCloth'
          output = RedCloth.new(output, [:filter_html]).to_html 
        rescue Exception
        end

        render :json => { 
          :html => output 
        }
      }
    end
  end
end
