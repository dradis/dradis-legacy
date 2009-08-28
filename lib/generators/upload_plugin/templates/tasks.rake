namespace :upload do

  desc 'Explain here what the task does'
  task :<%= file_name %>, :file, :needs => :environment do |t, args|

    # your initialization goes here
    filename = args[:file]

    # standard logging facility
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG

    # your validation goes here
    fail "Please provide a file: rake 'upload:nmap[<file>]'" if filename.nil?
    fail "File [#{filename}] does not exist" unless File.exists?(filename)

    # invoke the plugin
    <%= class_name %>.import( 
      :file => Attachment.new(:filename => filename, :node_id => 1),
      :logger => logger
    )

    logger.close
  end

  # additional tasks go here
  # ...
end
