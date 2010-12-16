# Install hook code here
# code borrowed from ext_scaffold plugin: 
#    http://github.com/martinrehfeld/ext_scaffold/tree/master

for path in [ ['config', 'osvdb_import.yml'] ]
  source = File.join(File.dirname(__FILE__),*path)
  destination = Rails.root.join(*path)
  print "  #{path.join('/')} "
  if File.exists?(destination)
    if FileUtils.cmp(source, destination)
      puts "identical"
    else
      print "exits, overwrite [yN]?"
      if STDIN.gets("\n").chomp.downcase.first == 'y'
        FileUtils.cp source, destination
      else
        puts "    ...skipped"; next
      end
    end
  else
    puts "create"
    FileUtils.mkdir_p File.dirname(destination)
    FileUtils.cp source, destination
  end
end
