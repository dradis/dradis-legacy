class AttachmentsController < ApplicationController

  def index
    @attachments = Node.find(params[:node_id]).attachments
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
    send_data(@attachment.read, :type => 'image',
      :filename => @attachment.filename,
      :disposition => 'inline')
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