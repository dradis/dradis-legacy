# FIXME: this fixes the assumption of the plugin that it will be receiving an 
#       as the :file parameter Attachment
class File
  def fullpath
    File.expand_path self.path
  end
end

namespace :upload do

  desc 'Explain here what the task does'
  task :<%= file_name.split('_').first %>, :file, :needs => :environment do |t, args|

    # your initialization goes here
    filename = args[:file]

    # standard logging facility
    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG

    # your validation goes here
    fail "Please provide a file: rake 'upload:<%= file_name.split('_').first  %>[<file>]'" if filename.nil?
    fail "File [#{filename}] does not exist" unless File.exists?(filename)

    # invoke the plugin
    <%= class_name %>.import( 
      :file => File.new(filename),
      :logger => logger
    )

    logger.close
  end

  # additional tasks go here
  # ...
end
