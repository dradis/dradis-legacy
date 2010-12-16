# In this module you will find the implementation details that enable you to
# upload a project archive (generated using ProjectExport::Processor::full_project)
module ProjectPackageUpload
  def self.import(params={})
    logger = params.fetch(:logger, RAILS_DEFAULT_LOGGER)

    package = params[:file].fullpath
    success = false

    # Unpack the archive in a temporary location
    FileUtils.mkdir Rails.root.join('tmp', 'zip')
    
    begin
      logger.debug{ 'Uncompressing the file' }
      #TODO: this could be improved by only uncompressing the XML, then parsing
      # it to get the node_lookup table and then uncompressing each entry to its
      # final destination
      Zip::ZipFile.foreach(package) { |entry|
        path = Rails.root.join('tmp', 'zip', entry.name)
        FileUtils.mkdir_p(File.dirname(path))
        entry.extract(path)
        logger.debug{ "\t#{entry.name}" }
      }
      logger.debug{ 'Done.' }
    
      logger.debug{ 'Loading XML state file' } 
      # FIXME: due to a limitation in the way ProjectTemplateUpload::import is 
      # coded we need to move the XML file under attachments/ so we can generate
      # an Attachment instance to pass it to the import() method.
      dradis_repository = Rails.root.join('tmp', 'zip', 'dradis-repository.xml')
      dradis_attachment = File.join( File.dirname(package), 'dradis-repository.xml' )
      FileUtils.mv( dradis_repository, dradis_attachment )
      node_lookup = ProjectTemplateUpload.import( 
                                          :logger => logger, 
                                          :file => Attachment.new( :filename => 'dradis-repository.xml', :node_id => params[:file].node_id )
                                        ) 
      File.delete(dradis_attachment)

      logger.debug{ 'Moving attachments to their final destinations' }
      node_lookup.each do |oldid,newid|      
        if File.directory?( File.join(RAILS_ROOT, 'tmp', 'zip', oldid) )
          FileUtils.mkdir_p( File.join(RAILS_ROOT, 'attachments', newid.to_s) )

          Dir.glob(File.join(RAILS_ROOT, 'tmp', 'zip', oldid, '*')).each do |attachment|
            FileUtils.mv( attachment, File.join(RAILS_ROOT, 'attachments', newid.to_s) )
          end
        end
      end

      success = true
    rescue Exception => e
      logger.error{ e.message }
      success = false
    ensure
      # clean up the temporary files
      FileUtils.rm_rf( File.join(RAILS_ROOT, 'tmp', 'zip') )
    end

    return success
  end
end
