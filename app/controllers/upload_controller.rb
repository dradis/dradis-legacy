# The UploadContoller will be the centralised point from which all the 
# functionality exposed by uploader plugins is made available to the user.
class UploadController < ApplicationController
  include Plugins::Upload
  before_filter :login_required
  before_filter :validate_uploader, :only => :import

  private
  def validate_uploader()
    valid_uploaders = Plugins::Upload::included_modules.collect do |m| m.name; end
    if (params.key?(:uploader) && valid_uploaders.include?(params[:uploader])) 
      @uploader = params[:uploader].constantize
    else
      redirect_to '/'
    end
  end

  public
  # This method provides a list of all the available uploader plugins. It 
  # assumes that each export plugin inclides instance methods in the
  # Plugins::Upload mixing.
  def list
    respond_to do |format|
      format.html{ redirect_to '/' }
      format.json{ 
        list = []
        Plugins::Upload.included_modules.each do |plugin|
          list << { 
            :name => plugin.name.underscore.humanize.gsub(/\//,' - '), 
            :plugin => plugin.name 
          }
        end

        render :json => list
      }
    end
  end

  def import 
    p params

    file = params[:file]
    # process the upload using the plugin
    

    # create an 'Imported files' node
    
    # add the file as an attachment
    #Configuration.increment_revision 

    render :text => { :success=>true }.to_json
  end

end
