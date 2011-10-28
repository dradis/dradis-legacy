class DradisTasks < Thor
  class Upload < Thor
    namespace "dradis:upload"

#    desc  "<%= class_name.underscore.gsub(/_upload/, '') %> FILE", "upload <%= class_name.underscore.gsub(/_upload/, '') %> results"
#    long_desc "This will appear if the user runs 'thor help dradis:upload:<%= class_name.underscore.gsub(/_upload/, '') %>'"
#    def <%= class_name.underscore.gsub(/_upload/, '') %>(file_path)
#      require 'config/environment'
#
#      logger = Logger.new(STDOUT)
#      logger.level = Logger::DEBUG
#
#      unless File.exists?(file_path)
#        $stderr.puts "** the file [#{file_path}] does not exist"
#        exit -1
#      end
#
#      <%= class_name %>.import(
#        :file => file_path,
#        :logger => logger)
#
#      logger.close
#    end

  end
end
