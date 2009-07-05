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
    # create an 'Imported files' node
    uploadsNode = Node.find_by_label(Configuration.uploadsNode)
    if (uploadsNode.nil?)
      uploadsNode = Node.new( :label => Configuration.uploadsNode )
      uploadsNode.save
    end
    
    # add the file as an attachment
    attachment = Attachment.new( params[:file].original_filename, :node_id => uploadsNode.id )
    attachment << params[:file].read
    attachment.save

    #Increment revision
    Configuration.increment_revision 
 
    # process the upload using the plugin
    if( @uploader.import(:file => attachment) )
    
      # Notify the caller that everything was fine
      render :text => { :success=>true }.to_json
    else
      # Something went wrong
    end
  end

end
