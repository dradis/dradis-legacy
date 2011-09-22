
# This is the primary controller in charge of rendering the 
# ExtJS[http://extjs.com] interface
class HomeController < ApplicationController
  layout 'postauth'
  before_filter :login_required
  
  # The only action provided by the controller renders the home page view
  # located at app/views/home/index.html.erb.
  def index
    @last_audit = 0
    if Log.where(:uid=>0).count > 0
      @last_audit = Log.where(:uid => 0).order('created_at desc').limit(1)[0].id
    end
  end
  
  # Returns the Textile version of a text passed as parameter
  def textilize
    respond_to do |format|
      format.html { head :method_not_allowed }
      format.json { 
        # gracefully handle RedCloth absence
        output = '' 
        begin
          output = params[:text]
          Hash[ *params[:text].scan(/#\[(.+?)\]#[\r|\n](.*?)(?=#\[|\z)/m).flatten.collect{ |str| str.strip } ].keys.each do |field|
            output.gsub!(/#\[#{field}\]#\n/, "h1. #{field}\n\n")
          end
          
          output = RedCloth.new(output, [:filter_html]).to_html 
        rescue Exception
          output = "<pre style=\"background-color: #fff;\">#{ CGI::escapeHTML(params[:text]) }</pre>"
        end

        render :json => { 
          :html => output 
        }
      }
    end
  end
end
