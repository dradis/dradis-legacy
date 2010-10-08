# TODO: this fixes the assumption of the plugin that it will be receiving an 
#       as the :file parameter Attachment
class File
  def fullpath
    File.expand_path self.path
  end
end

namespace :upload do
  desc 'Upload an parse a Nessus XML file'
  task :nessus, :file, :needs => :environment do |t, args|

    filename = args[:file]

    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG

    fail "Please provide a file: rake 'upload:nessus[<file>]'" if filename.nil?
    fail "File [#{filename}] does not exist" unless File.exists?(filename)


    NessusUpload.import( 
      :file => File.new(filename),
      :logger => logger
    )

    logger.close
  end
end
