class UploadProcessingJob < Struct.new(:uploader, :file, :item_id)

  def perform
    logger = Log.new(:uid => item_id)
    logger.write{ "Worker process starting background task" }
    uploader.constantize::import(:file => file, :logger => logger)
    logger.write{ "Worker process completed." }
  end
end
