require 'logger'

class DradisTasks < Thor
  class Export < Thor
    class ProjectManagement < Thor
      namespace   "dradis:export:project"

      desc "template", "export the current repository structure as a dradis template"
      method_option   :file, :type => :string, :desc => "the template file to create, or directory to create it in"
      def template
        require 'config/environment'

        logger = Logger.new(STDOUT)
        logger.level = Logger::DEBUG
        
        template_path = options.file || Rails.root.join('backup')

        unless template_path =~ /\.xml\z/
          date      = DateTime.now.strftime("%Y-%m-%d")
          sequence  = Dir.glob(File.join(template_path, "dradis-template_#{date}_*.xml")).collect { |a| a.match(/_([0-9]+)\.xml\z/)[1].to_i }.max || 0
          template_path = File.join(template_path, "dradis-template_#{date}_#{sequence + 1}.xml")
        end

        template    = ProjectExport::Processor.db_only(:logger => logger)
        
        f = File.new(template_path, 'w')
        f.write template
        f.close

        logger.info{ "Template file created at:\n\t#{ File.expand_path( f.path ) }" }
        logger.close
      end


#    desc "metaserver", "commit project to the Meta-Server"
#    def metaserver
#      require 'config/environment'
#
#      logger = Logger.new(STDOUT)
#      logger.level = Logger::DEBUG
#
#      mode = Configuration.find_by_name('mode').value
#      title = "NewProject_#{DateTime.now.strftime('%Y-%m-%d')}"
#
#      # If this project was never checked out from the Meta-Server, give the
#      # user a chance to choose a project title
#      if (mode == 'new')
#        puts "This project was not checked out from a Meta-Server. Please provide a project name:"
#        response = STDIN.gets("\n").chomp
#        if !response.empty?
#          title = response
#        end
#      end
#
#      begin
#        ProjectExport::MetaServerProcessor.commit(:logger => logger, :title => title)
#      rescue Exception => e
#        logger.error{ 'There was an error sending the project to the Meta-Server:' }
#        logger.error{ e.message }
#        logger.error{ "The current settings from [#{ProjectManagement::CONF_FILE}]:" }
#        logger.error{ ProjectManagement::CONF['meta-server'] }
#      end
#
#      logger.close
#    end


      desc      "package", "creates a copy of your current repository"
      long_desc "Creates a copy of the current repository, including all nodes, notes and " +
                "attachments as a zipped archive. The backup can be imported into another " +
                "dradis instance using the 'Project Package Upload' option."
      method_option   :file, :type => :string, :desc => "the package file to create, or directory to create it in"
      def package
        require 'config/environment'
        
        logger = Logger.new(STDOUT)
        logger.level = Logger::DEBUG

        package_path  = options.file || Rails.root.join('backup')

        unless package_path =~ /\.xml\z/
          date      = DateTime.now.strftime("%Y-%m-%d")
          sequence  = Dir.glob(File.join(package_path, "dradis-export_#{date}_*.zip")).collect { |a| a.match(/_([0-9]+)\.zip\z/)[1].to_i }.max || 0
          package_path = File.join(package_path, "dradis-export_#{date}_#{sequence + 1}.zip")
        end

        ProjectExport::Processor.full_project(:logger => logger, :filename => package_path)
        
        logger.info{ "Project package created at:\n\t#{ File.expand_path( package_path ) }" }
        logger.close
      end

    end
  end

  class Upload < Thor
    class ProjectManagement < Thor
      namespace   "dradis:upload:project"

      # This task will load into the current database the contents of the template
      # file passed as the first argument
      desc "template FILE", "create a new repository structure from an XML file"
      def template(file_path)
        require 'config/environment'

        logger = Logger.new(STDOUT)
        logger.level = Logger::DEBUG
        
        unless File.exists?(file_path)
          $stderr.puts "** the file [#{file_path}] does not exist"
          exit -1
        end
        
        ProjectTemplateUpload::import(:logger => logger, :file => file_path )
        logger.close
      end


      # The reverse operation to the dradis:export:project:package task. From a
      # zipped project package extract the contents of the archive and populate
      # the dradis DB and attachments with them.
      desc "package FILE", "import an entire repository package"
      def package(file_path)
        require 'config/environment'

        logger = Logger.new(STDOUT)
        logger.level = Logger::DEBUG

        unless File.exists?(file_path)
          $stderr.puts "** the file [#{file_path}] does not exist"
          exit -1
        end

        ProjectPackageUpload::import(:logger => logger, :file => file_path )
        logger.close
      end

    end
  end
end
