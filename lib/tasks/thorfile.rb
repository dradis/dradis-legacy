class DradisTasks < Thor
  namespace       "dradis"
  
  desc      "backup", "creates a backup of your current repository"
  long_desc "Creates a backup of the current repository, including all nodes, notes and " +
            "attachments as a zipped archive. The backup can be imported into another " +
            "dradis instance using the 'Project Package Upload' option."
  method_option   :file, :type => :string, :desc => "the backup file to create, or directory to create it in"
  def backup
    require 'config/environment'

    backup_path   = options.file || Rails.root.join('backup')

    unless backup_path.to_s =~ /\.zip\z/
      date        = DateTime.now.strftime("%Y-%m-%d")
      sequence    = Dir.glob(File.join(backup_path, "dradis_#{date}_*.zip")).collect { |a| a.match(/_([0-9]+)\.zip\z/)[1].to_i }.max || 0
      backup_path = File.join(backup_path, "dradis_#{date}_#{sequence + 1}.zip")
    end

    if ActiveRecord::Migrator::current_version > 0
      print "** Saving backup...                                                   "

      begin
        FileUtils.mkdir_p File.dirname(backup_path)
        
        exporter = Dradis::Plugins::Projects::Export::Package.new
        exporter.export(filename: backup_path)

        puts "[  DONE  ]"
        puts "** Backup Saved as: #{backup_path}"
      rescue RuntimeError => e
        puts "[ FAILED ]"
        puts "** #{e.message}"
        exit -1
      end
    else
      puts "** Nothing to Backup."
    end
  end

  desc      "reset", "resets your local dradis repository"
  long_desc "Resets your dradis repository, removing all nodes, notes and attachments and log files " +
            "so it is ready to start a new project.\n\nA backup of the current repository "+
            "will be taken before anything is removed."
  method_option   :file, :type => :string, :desc => "the backup file to create, or directory to create it in"
  method_option   :no_backup, :type => :boolean, :desc => "do not create a backup of the current repository"
  def reset
    invoke "dradis:setup:configure"
    invoke "dradis:setup:migrate"

    invoke "dradis:backup", options             unless options.no_backup
    
    invoke "dradis:reset:attachments", options
    invoke "dradis:reset:database", options
    invoke "dradis:setup:seed"
    invoke "dradis:reset:logs", options
  end

  desc "server", "start dradis server"
  method_option   :p, :type => :string, :desc => "specify the port to listen to (default 3004)"
  method_option   :b, :type => :string, :desc => "bind to a specific IP address (default 0.0.0.0)"
  method_option   :d, :type => :boolean, :desc => "run in the background"
  method_option   :P, :type => :string, :desc => "specify the location of the PID file (default tmp/pids)"
  def server
    require 'rubygems'

    ARGV.shift        # remove dradis:server from the command-line arguments
    ARGV.unshift 's'  # add 's' to the beginning of the command-line arguments,
                      # because we want a server

    gem 'rails', ">= 0"
    # now that we've massaged the arguments a little, we let Rails take over and
    # do its magic (this is essentially invoking 'rails s' with all the options
    # passed into Thor
    load Gem.bin_path('rails', 'rails', ">= 0")
  end

  desc "settings [NAMESPACE]", "list dradis settings, with an optional namespace to filter the results"
  def settings(namespace=nil)
    require 'config/environment'

    settings = Core::Configurator.configurables.collect(&:settings).flatten.sort_by(&:name)
    width = settings.collect { |s| s.name.length + 1 }.max

    settings.each do |setting|
      puts "%-#{width}s %s" % [setting.name, setting.value] if namespace.nil? || setting.name.include?(namespace)
    end
  end

  desc "version", "displays the version of the dradis server"
  def version
    require 'config/environment'
    
    puts Core::VERSION::string
  end
  

  class Import < Thor; end
  class Export < Thor; end
  class Upload < Thor; end


  class Setup < Thor
    namespace     "dradis:setup"

    desc "configure", "Creates the Dradis configuration files from their templates (see config/*.yml.template)"
    def configure
      # init the config files
      init_all = false
      Dir['config/*.template'].each do |template|
        config = File.join( 'config', File.basename(template, '.template') )
        if !(File.exists?( config ))
          if (init_all)
            puts "Initilizing #{config}..."
            FileUtils.cp(template, config)
          else
            puts "The config file [#{template}] was found not to be ready to use."
            puts "Do you want to initialize it? [y]es | [N]o | initialize [a]ll"
            response = STDIN.gets.chomp.downcase
            response = 'Y' if ( response.empty? || !['y', 'n', 'a'].include?(response) )
  
            if response == 'n'
              next
            else
              puts "Initilizing #{config}..."
              FileUtils.cp(template, config)
              if (response == 'a')
                init_all = true
              end
            end
          end
        end
      end
    end

    desc "migrate", "ensures the database schema is up-to-date"
    def migrate
      require 'config/environment'

      print "** Checking database migrations...                                    "
      ActiveRecord::Migrator.migrate(Rails.application.config.paths["db/migrate"], nil)
      puts "[  DONE  ]"
    end
    
    desc "seed", "adds initial values to the database (i.e., categories and configurations)"
    def seed
      require 'config/environment'

      print "** Seeding database...                                                "
      require 'db/seeds'
      puts "[  DONE  ]"
    end
    
  end

  class Settings < Thor
    namespace     "dradis:settings"

    desc "get SETTING", "get the value of a dradis setting"
    def get(name)
      require 'config/environment'

      setting = Core::Configurator.configurables.collect(&:settings).flatten.detect { |c| c.name == name }

      unless setting.nil?
        puts "%s %s" % [setting.name, setting.value]
      else
        puts "Unknown setting %s." % [name]
      end
    end

    desc "set SETTING VALUE", "change the value of a dradis setting"
    def set(name, value)
      require 'config/environment'

      setting = Core::Configurator.configurables.collect(&:settings).flatten.detect { |c| c.name == name }

      unless setting.nil?
        old_value = setting.value

        if setting.update_attribute(:value, value)
          puts "Changed %s from \"%s\" to \"%s\"." % [setting.name, old_value, setting.value]
        else
          puts "Failed to change %s to \"%s\"." % [setting.name, value]
        end
      else
        puts "Unknown setting %s." % [name]
      end
    end
  end
  
  class Reset < Thor
    namespace     "dradis:reset"

    desc "attachments", "removes all attachments"
    def attachments
      print "** Deleting all attachments...                                        "
      FileUtils.rm_rf(Dir.glob( Dradis::Core::Attachment::pwd.join('*')) )
      puts(Dir.glob( Dradis::Core::Attachment::pwd.join('*')).empty? ? "[  DONE  ]" : "[ FAILED ]")
    end

    desc "database", "removes all data from a dradis repository, except configurations"
    def database
      require 'config/environment'
      
      print "** Cleaning database...                                               "

      Dradis::Core::Evidence.destroy_all
      Dradis::Core::Issue.destroy_all
      Dradis::Core::Note.destroy_all
      Dradis::Core::Node.destroy_all
      Dradis::Core::Category.destroy_all
      
      Dradis::Core::Log.destroy_all
      
      puts "[  DONE  ]"
    end

    desc "logs", "removes all log files"
    def logs
      print "** Deleting all log files...                                          "
      FileUtils.rm_rf(Dir.glob('log/*.log'))
      puts(Dir.glob('log/*.log').empty? ? "[  DONE  ]" : "[ FAILED ]")
    end

    desc "password", "Set a new shared password to access the web interface"
    def password()
      require 'config/environment'

      say "Changing password for Dradis server."
      password = ask "Enter new Dradis password:", echo: false
      puts
      confirmation = ask "Retype new Dradis password:", echo: false
      puts

      if !password.blank? && password == confirmation
        new_pass = ::BCrypt::Password.create(password)
        pwd_config = Dradis::Core::Configuration.find_or_create_by(name: 'password')
        pwd_config.update_attribute(:value, new_pass)
        say("Password Changed.", Thor::Shell::Color::GREEN)
      else
        say("Passwords do not match. Password Unchanged.", Thor::Shell::Color::RED)
      end
    end
  end
end
