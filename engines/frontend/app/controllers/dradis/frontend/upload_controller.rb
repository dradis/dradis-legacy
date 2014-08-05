# The UploadController provides access to the different upload plugins that 
# have been deployed in the dradis server.
#

module Dradis
  module Frontend

    class UploadController < Dradis::Frontend::AuthenticatedController
      before_filter :find_nodes
      before_filter :find_plugins
      before_filter :find_uploads_node, only: [:create, :parse]
      before_filter :validate_uploader, only: [:create, :parse]

      layout 'dradis/themes/snowcrash'


      def index
        @last_job = Dradis::Core::Log.maximum(:uid) || 1
      end

      def create
        # TODO: this would overwrite an existing file with the same name.
        # See AttachmentsController#create

        # save a copy of the uploaded file
        filename = params[:file].original_filename

        # add the file as an attachment
        @attachment = Dradis::Core::Attachment.new(filename, node_id: @uploads_node.id)
        @attachment << params[:file].read
        @attachment.save

        @success = true
        flash.now[:notice] = "Successfully uploaded #{filename}"
      end

      def parse
        attachment = Dradis::Core::Attachment.find(params[:file], conditions: { node_id: @uploads_node.id })

        # Files smaller than 1Mb are processed inlined, others are
        # processed in the background via a Redis worker.
        if File.size(attachment.fullpath) < 1024*1024
          process_upload_inline(attachment: attachment)
        else
          process_upload_background(attachment: attachment)
        end

        # Nothing to do, the client-side JS will poll ./status for updates
        # from now on
        render nothing: true
      end

      def status
        @logs = Dradis::Core::Log.where("uid = ? and id > ?", params[:item_id].to_i, params[:after].to_i)
        @uploading = !(@logs.last.text == 'Worker process completed.') if @logs.any?
      end

      private

      # There should be a better way of handling this.
      def find_nodes
        @nodes = Dradis::Core::Node.includes(:children).all
        @new_node = Dradis::Core::Node.new
      end

      # The list of available Upload plugins. See the dradis_plugins gem.
      def find_plugins
        @plugins = Dradis::Plugins::with_feature(:upload).collect do |plugin|
          path = plugin.to_s
          path[0..path.rindex('::')-1].constantize
        end.sort{|a,b| a.name <=> b.name }
      end

      def find_uploads_node
        @uploads_node = Dradis::Core::Node.find_or_create_by(label: Dradis::Core::Configuration.plugin_uploads_node)
      end

      def logger
        @job_logger ||= Dradis::Core::Log.new(uid: params[:item_id].to_i)
      end

      def process_upload_inline(args={})
        attachment = args[:attachment]

        logger.write('Small attachment detected. Processing in line.')
        begin
          content_service = Dradis::Plugins::ContentService.new(plugin: @uploader)
          template_service = Dradis::Plugins::TemplateService.new(plugin: @uploader)

          importer = @uploader::Importer.new(
                      logger: logger,
             content_service: content_service,
            template_service: template_service
          )

          importer.import(file: attachment.fullpath)

        rescue Exception => e
          logger.write('There was a fatal error processing your upload:')
          logger.write(e.message)
          if Rails.env.development?
            e.backtrace[0..10].each do |trace|
              logger.debug{ trace }
              sleep(0.2)
            end
          end
        end
        logger.write('Worker process completed.')
      end

      def process_upload_background(args={})
        raise 'unimplemented!'
        attachment = args[:attachment]

        # Is it worth making Bj compatible?
        # Bj.submit "ruby script/rails runner lib/upload_processing_job.rb %s \"%s\" %s" % [ params[:uploader], attachment.fullpath, params[:item_id] ]

        @job_id = UploadProcessor.create(
                                        file: attachment.fullpath,
                                        plugin: params[:uploader],
                                        project_id: @project.id,
                                        uid: item_id)

        logger.write("Enqueueing job to start in the background. Job id is #{item_id}")
      end

      # Ensure that the requested :uploader is valid
      def validate_uploader()
        valid_uploaders = @plugins.collect(&:name)

        if (params.key?(:uploader) && valid_uploaders.include?(params[:uploader]))
          @uploader = params[:uploader].constantize
        else
          redirect_to upload_manager_path, alert: 'Something fishy is going on...'
        end
      end

    end

  end
end