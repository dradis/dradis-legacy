class AttachmentsController < ApplicationController

  def index
    @attachments = Node.find(params[:node_id]).attachments
  end

  def create
    @attachment = Attachment.new(params['attachment_file'].original_filename, :node_id => params[:node_id])
    @attachment << params['attachment_file'].read
    @attachment.save
    debugger
    redirect_to node_attachments_path(params[:node_id])
  end
end