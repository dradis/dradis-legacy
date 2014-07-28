module Dradis
  module Frontend

    # Each Node of the repository can have multiple Attachments associated with it.
    # This controller is used to handle REST operations for the attachments.
    class AttachmentsController < Dradis::Frontend::AuthenticatedController
      before_filter :find_node

      respond_to :json

      # Create a new attachment for a give :node_id using a file that has been
      # submitted using an HTML form POST request.
      def create
        uploaded_file = params.fetch('attachment_file', params.fetch('files', []).first)

        attachment_name = get_name(original: uploaded_file.original_filename)

        @attachment = Dradis::Core::Attachment.new(attachment_name, node_id: @node.id)
        @attachment << uploaded_file.read
        @attachment.save

        # new jQuery uploader
        json = {
                 name: @attachment.filename,
                 size: File.size(@attachment.fullpath),
                  url: node_attachment_path(@node, @attachment.filename),
           delete_url: node_attachment_path(@node, @attachment.filename),
          delete_type: 'DELETE'
        }
        if Mime::Type.lookup_by_extension(File.extname(@attachment.filename).downcase.tr('.','')).to_s =~ /^image\//
          json[:thumbnail_url] = node_attachment_path(@node, @attachment.filename)
        end
        render json: {files: [json]}, content_type: 'text/plain'
      end

      # It is possible to rename attachments and this function provides that
      # functionality.
      # TODO: implement?
      # def update
      #   filename = params[:id]
      #   attachment = Dradis::Core::Attachment.find(filename, conditions: {node_id: @node.id})
      #   attachment.close
      #   new_name = CGI::unescape(params[:rename])
      #   destination = Dradis::Core::Attachment.pwd.join(@node.id, new_name).to_s
      #
      #   if !File.exist?(destination) && ( !destination.match(/^#{Dradis::Core::Attachment.pwd}/).nil? )
      #     File.rename(attachment.fullpath, destination)
      #   end
      #   respond_to do |format|
      #     format.json{ render json: {success: true} }
      #   end
      # end

      # This function will send the Attachment file to the browser. It will try to
      # figure out if the file is an image in which case the attachment will be
      # displayed inline. By default the <tt>Content-disposition</tt> will be set to
      # +attachment+.
      def show
        filename = params[:id]

        @attachment = Dradis::Core::Attachment.find(filename, conditions: {node_id: @node.id})
        send_options = {filename: @attachment.filename}

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

        @attachment = Dradis::Core::Attachment.find(filename, conditions: {node_id: @node.id})
        @attachment.delete

        respond_to do |format|
          format.json{ render json: {success: true}}
        end
      end

      private
      # For most of the operations of this controller we need to identify the Node
      # we are working with. This filter sets the @node instance variable if the
      # give :node_id is valid.
      def find_node
        @node = Dradis::Core::Node.find_by(id: params[:node_id].to_i)
        redirect_to root_path, alert: 'Node not found' unless @node
      end

      # Obtain a suitable attachment name for the recently uploaded file. If the
      # original file name is still available, use it, otherwise, provide count-based
      # an alternative.
      def get_name(args={})
        original = args[:original]
        node_attachments = Dradis::Core::Attachment.pwd.join(@node.id.to_s)

        return original unless File.exists?(node_attachments)

        # The original name is taken, so we'll add the "_copy-XX." suffix
        extension = File.extname(original)
        basename = File.basename(original, extension)
        sequence  = Dir.glob(node_attachments.join("#{basename}_copy-*#{extension}")).collect { |a| a.match(/_copy-([0-9]+)#{extension}\z/)[1].to_i }.max || 0
        "%s_copy-%02i%s" % [basename, sequence + 1, extension]
      end
    end

  end
end