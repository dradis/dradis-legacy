namespace :upload do

  desc 'Uploads and parses a wXf output file'
  task :wxf, :file, :needs => :environment do |t, args|

    # your initialization goes here
    filename = args[:file]

    # standard logging facility
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG

    # your validation goes here
    fail "Please provide a file: rake 'upload:wxf[<file>]'" if filename.nil?
    fail "File [#{filename}] does not exist" unless File.exists?(filename)

    # invoke the plugin
    WxfUpload.import( 
      :file => filename,
      :logger => logger
    )

    logger.close
  end

  # additional tasks go here
  # ...
end
