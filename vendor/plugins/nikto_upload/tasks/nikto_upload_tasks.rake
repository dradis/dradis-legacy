# TODO: this fixes the assumption of the plugin that it will be receiving an 
#       as the :file parameter Attachment
class File
  def fullpath
    File.expand_path self.path
  end
end

namespace :upload do
  desc 'Upload an parse a Nikto XML file'
  task :nikto, :file, :needs => :environment do |t, args|

    filename = args[:file]

    logger = Logger.new(STDOUT)
    logger.level = Logger::DEBUG

    fail "Please provide a file: rake 'upload:nikto[<file>]'" if filename.nil?
    fail "File [#{filename}] does not exist" unless File.exists?(filename)


    NiktoUpload.import( 
      :file => File.new(filename),
      :logger => logger
    )

    logger.close
  end
end
