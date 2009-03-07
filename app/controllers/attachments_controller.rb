class AttachmentsController < ApplicationController

  def index
    @attachments = Node.find(params[:node_id]).attachments
  end
end
