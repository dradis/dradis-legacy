def substitute_placeholder(file, placeholder, value)
  f = File.open(file, 'r')
  lines = f.readlines
  f.close
  
  lines.each_index do |index|
    # check for place holder /* dbfile */
    if lines[index] =~ placeholder
      lines[index] = lines[index].gsub(placeholder, value)
    end
  end
  
  f = File.open(file, 'w')
  f.write(lines)
  f.close  
end


namespace :win32 do
  desc 'Roundhouse kick Vista and reconfigure the app to avoid storing information in the Program Files directory.'
  task :vistafu do
    app_data = ENV['APPDATA'] || nil
    if app_data
      dradis_path = app_data + '\\dradis\\'
      FileUtils.mkdir(dradis_path) unless File.exists?(dradis_path)
      # database
      db_path = dradis_path + 'dradis-database-1.2.sqlite3'
      substitute_placeholder( Rails::Configuration.new().database_configuration_file, /db\/dev.db/, db_path)
      # logfile
      log_path = "config.log_path = \"#{dradis_path}dradis-1.2.log\""
      substitute_placeholder( 'config/environment.rb', /#--w32logfile--#/, log_path)
    end
  end  
end

