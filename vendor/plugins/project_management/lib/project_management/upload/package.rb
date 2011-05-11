# In this module you will find the implementation details that enable you to
# upload a project archive (generated using ProjectExport::Processor::full_project)
module ProjectPackageUpload
  def self.import(params={})
    logger = params.fetch(:logger, Rails.logger)

    package = params[:file]
    success = false

    # Unpack the archive in a temporary location
    FileUtils.mkdir Rails.root.join('tmp', 'zip')
    
    begin
      logger.info{ 'Uncompressing the file' }
      #TODO: this could be improved by only uncompressing the XML, then parsing
      # it to get the node_lookup table and then uncompressing each entry to its
      # final destination
      Zip::ZipFile.foreach(package) { |entry|
        path = Rails.root.join('tmp', 'zip', entry.name)
        FileUtils.mkdir_p(File.dirname(path))
        entry.extract(path)
        logger.info{ "\t#{entry.name}" }
      }
      logger.info{ 'Done.' }
    
      logger.info{ 'Loading XML state file' } 
      node_lookup = ProjectTemplateUpload.import( 
                                          :logger => logger, 
                                          :file => Rails.root.join('tmp', 'zip', 'dradis-repository.xml')
                                        ) 

      logger.info{ 'Moving attachments to their final destinations' }
      node_lookup.each do |oldid,newid|      
        if File.directory?( Rails.root.join('tmp', 'zip', oldid) )
          FileUtils.mkdir_p( Rails.root.join('attachments', newid.to_s) )

          Dir.glob(Rails.root.join('tmp', 'zip', oldid, '*')).each do |attachment|
            FileUtils.mv( attachment, Rails.root.join('attachments', newid.to_s) )
          end
        end
      end

      success = true
    rescue Exception => e
      logger.error{ e.message }
      success = false
    ensure
      # clean up the temporary files
      FileUtils.rm_rf( Rails.root.join('tmp', 'zip') )
    end

    return success
  end
end
