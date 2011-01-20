BACKUP_DIR = File.join(Rails.root, 'backups')

namespace :dradis do

  desc 'Creates the Dradis configuration files from their templates (see config/*.yml.template)'
  task :configure do 
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
          response = 'Y' if ( response.blank? || !['y', 'n', 'a'].include?(response) )

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

  # ------------------------------------------------------ Deprecated tasks

  def rake_thor_deprecation_warning(new_task)
    puts "Deprecation warning: This Rake task has been deprecated in favour of a Thor task. Please use:\n" +
      "$ thor #{new_task}\n" +
      "To see all Thor tasks use:\n" +
      "$ thor -T"
  end

  namespace :attachments do

    desc 'Deprecated: Drop all the attachments from the attachments/ directory'
    task :drop do
      rake_thor_deprecation_warning "dradis:reset:attachments"
    end
  end

  desc 'Deprecated: Backup the current project (DB + attachments) into the backups/ directory'
  task :backup do
    rake_thor_deprecation_warning "dradis:backup"
  end

  desc 'Deprecated: Creates a backup, drops the database, removes the attachments and recreates the DB.'
  task :reset do
    rake_thor_deprecation_warning "dradis:reset"
  end

end
