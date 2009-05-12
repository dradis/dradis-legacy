class AttachmentsController < ApplicationController
  before_filter :login_required

  def index
    @attachments = Node.find(params[:node_id]).attachments
    respond_to do |format|
      format.html{ render :action => 'index'}
      format.json{ render :json => @attachments }
    end
    @attachments.each do |a| a.close end
  end

  def create
    @attachment = Attachment.new(params['attachment_file'].original_filename, :node_id => params[:node_id])
    @attachment << params['attachment_file'].read
    @attachment.save
    redirect_to node_attachments_path(params[:node_id])
  end

  def show
    # we send the file name as the id, the rails parser however split the filename
    # at the fullstop so we join it again
    filename = params[:id]
    @attachment = Attachment.find(filename, :conditions => {:node_id => Node.find(params[:node_id]).id})
    extname = File.extname(filename)[1..-1]
    mime_type = Mime::Type.lookup_by_extension(extname)
    content_type = mime_type.to_s unless mime_type.nil?
    send_data(@attachment.read, :type => content_type,
      :filename => @attachment.filename,
      :disposition => content_type.match('image') ? 'inline' : 'attachment')
    @attachment.close
  end

  def destroy
    # we send the file name as the id, the rails parser however split the filename
    # at the fullstop so we join it again
    filename = params[:id]
    @attachment = Attachment.find(filename, :conditions => {:node_id => Node.find(params[:node_id]).id})
    @attachment.delete
    redirect_to node_attachments_path(params[:node_id])
  end
  
end
