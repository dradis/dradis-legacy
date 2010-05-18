# The UploadController provides access to the different upload plugins that 
# have been deployed in the dradis server.
#
# Each upload plugin will include itself in the Plugins::Upload module and this
# controller will include it so all the functionality provided by the different
# plugins is exposed.
#
# A convenience list method is provided that will return all the currently
# loaded plugins of this category.
class UploadController < ApplicationController
  include Plugins::Upload
  before_filter :login_required
  before_filter :validate_uploader, :only => :import

  private
  # Ensure that the requested :uploader is valid and has been included in the
  # Plugins::Upload mixin
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

  # This method handles the execution flow to the requested :uploader. It first
  # copies the uploaded file into the configured uploads node (see
  # Configuration.uploadsNode). Then the request is passed to the chosen plugin.
  def import 
    # create an 'Imported files' node
    uploadsNode = Node.find_or_create_by_label(Configuration.uploadsNode)
   
    # add the file as an attachment
    attachment = Attachment.new( params[:file].original_filename, :node_id => uploadsNode.id )
    attachment << params[:file].read
    attachment.save

    #Increment revision
    Configuration.increment_revision 
 
    # process the upload using the plugin
    begin
      @uploader.import(:file => attachment)
    
      # Notify the caller that everything was fine
      render :text => { :success=>true }.to_json

    rescue Exception => e
      # Something went wrong
      logger.error e, e.backtrace
      render :text => { :success => false, :error => CGI::escape(e.message), :backtrace => e.backtrace.collect{ |line| CGI::escape(line) } }.to_json 
    end
  end

end
