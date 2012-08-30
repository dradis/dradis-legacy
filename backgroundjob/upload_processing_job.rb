if __FILE__ == $0
  if ARGV.size != 3
    STDERR.puts "%s <uploader_module> <file> <job_id>" % $0
    exit
  end

  uploader, file, job_id = ARGV
  logger = Log.new(:uid => job_id)

  logger.write{ "Running Ruby version %s" % RUBY_VERSION }

  logger.write{ 'Worker process starting background task.' } 
  uploader.constantize::import(:file => file, :logger => logger)
  logger.write{ 'Worker process completed.' } 
end

