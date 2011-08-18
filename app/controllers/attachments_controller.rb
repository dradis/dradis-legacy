# Each Node of the repository can have multiple Attachments associated with it.
# This controller is used to handle REST operations for the attachments.
class AttachmentsController < ApplicationController
  before_filter :login_required
  before_filter :find_or_initialize_node

  # Retrieve all the associated attachments for a given :node_id
  def index
    @attachments = Node.find(params[:node_id]).attachments
    respond_to do |format|
      format.html{ render :action => 'index'}
      format.json{ render :text => '[' + @attachments.collect(&:to_json).join(',') + ']' }
    end
    @attachments.each do |a| a.close end
  end

  # Create a new attachment for a give :node_id using a file that has been 
  # submitted using an HTML form POST request.
  def create
    # TODO: what happens with files if they already exist?
    @attachment = Attachment.new(params['attachment_file'].original_filename, :node_id => params[:node_id])
    @attachment << params['attachment_file'].read
    @attachment.save
    
    # Note: this breaks the basic html scaffolds, but is required for the FileTree 
    # extension
    #redirect_to node_attachments_path(params[:node_id])
    response.headers["Content-Type"] = 'text/html'
    render :text => {:success => true}.to_json
  end

  # It is possible to rename attachments and this function provides that
  # functionality.
  def update
    filename = params[:id]
    attachment = Attachment.find(filename, :conditions => {:node_id => Node.find(params[:node_id]).id})
    attachment.close
    new_name = CGI::unescape( params[:rename] )
    destination = Attachment.pwd.join( params[:node_id], new_name ).to_s

    if !File.exist?(destination) && ( !destination.match(/^#{Attachment.pwd}/).nil? )
      File.rename( attachment.fullpath, destination  )
    end
    render :json => {:success => true}
  end

  # This function will send the Attachment file to the browser. It will try to 
  # figure out if the file is an image in which case the attachment will be 
  # displayed inline. By default the <tt>Content-disposition</tt> will be set to
  # +attachment+.
  def show
    filename = params[:id]

    @attachment = Attachment.find(filename, :conditions => {:node_id => Node.find(params[:node_id]).id})
    send_options = { :filename => @attachment.filename }

    # Figure out the best way of displaying the file (by default send the it as
    # an attachment).
    extname = File.extname(filename)
    send_options[:disposition] = 'attachment'

    # File.extname() returns either an empty string or the extension with a 
    # leading dot (e.g. '.pdf')
    if !extname.empty?
      # account for the possibility of this being an image and present the
      # attachment inline
      mime_type = Mime::Type.lookup_by_extension(extname[1..-1])
      if mime_type
        send_options[:type] = mime_type.to_s
        if mime_type =~ 'image'
          send_options[:disposition] = 'inline'
        end
      end
    end

    send_data(@attachment.read, send_options)

    @attachment.close
  end

  # Invoke this method to delete an Attachment from the server. It receives the
  # attachment's file name in the :id parameter and the corresponding node in
  # the :node_id parameter.
  def destroy
    filename = params[:id]
    
    @attachment = Attachment.find(filename, :conditions => {:node_id => Node.find(params[:node_id]).id})
    @attachment.delete
    render :json => {:success => true}
  end

  private
  # For most of the operations of this controller we need to identify the Node
  # we are working with. This filter sets the @node instance variable if the 
  # give :node_id is valid.
  def find_or_initialize_node
    begin 
      @node = Node.find(params[:node_id])
    rescue
      flash[:error] = 'Node not found'
      redirect_to root_path
    end
  end
end
