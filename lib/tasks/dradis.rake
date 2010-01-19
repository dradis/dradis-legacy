BACKUP_DIR = File.join(RAILS_ROOT, 'backups')

namespace :dradis do

  
  # --------------------------------------------------------------- Attachments
  namespace :attachments do

    desc 'Drop all the attachments from the attachments/ directory'
    task :drop do
      print 'Dropping attachments from attachments/... '
      FileUtils.rm_rf( 'attachments/' )
      puts 'done.'
      FileUtils.mkdir( 'attachments' )
    end
  end


  # -------------------------------------------------------------------- dradis

  task :backup_prepare do
    Dir.mkdir( BACKUP_DIR ) unless File.exists?( BACKUP_DIR ) 
    if !File.directory?( BACKUP_DIR )
      fail "Error creating backup directory [#{BACKUP_DIR}] is not a directory."
    end
  end
  
  desc 'Backup the current project (DB + attachments) into the backups/ directory'
  task :backup => ['dradis:backup_prepare', 'environment'] do
    date = DateTime.now.strftime( '%Y-%m-%d' )
    pattern = File.join( BACKUP_DIR, "dradis_#{date}_*.zip"  )
    day_backup_count = FileList[pattern].size
    backup_file = File.join( BACKUP_DIR, "dradis_#{date}_#{day_backup_count + 1}.zip"  )
    puts "Creating backup file: [#{backup_file}]"
    # TODO: what if the file already exists? 
    #   For example there are three files _1.zip, _2.zip and _4.zip, with the 
    #   method above 
    ProjectExport::Processor.full_project( :filename => backup_file )
    puts 'Backup complete.'
  end

  desc 'Creates a backup. Drops the database, removes the attachments and recreates the DB.'
  task :reset => ['backup', 'db:reset', 'dradis:attachments:drop', 'log:clear'] do
    init_all = false
    Dir['config/*.template'].each do |template|
      config = File.join( 'config', File.basename(template, '.template') )
      if !(File.exists?( config ))
        if (init_all)
          puts "Initilizing #{config}..."
          FileUtils.cp(template, config)
        else
          puts "The config file [#{template}] was found not to be ready to use."
          puts "Do you want to initialize it? [y]es | [n]o | initialize [A]ll"
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
end
