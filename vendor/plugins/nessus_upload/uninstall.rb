# Uninstall hook code here

for path in [ ['config', 'nessus_upload.yml'] ]
  full_path = Rails.root.join(*path)
  print "  #{path.join('/')} "

  if File.exists?(full_path)
    print 'exists, it was created by the plugin and is no longer needed, remove [yN]? '
    if STDIN.gets("\n").chomp.downcase.first == 'y'
      File.delete( full_path )
    else
      puts "    ...skipped";
    end
  end
end
