# Uninstall hook code here

for path in [ ['config', 'osvdb_import.yml'] ]
  original = File.join(File.dirname(__FILE__),*path)
  used = File.join(RAILS_ROOT,*path)

  print "  #{path.join('/')} "
  if File.exists?(used)
    if FileUtils.cmp(original, used)
        File.delete( used )
        puts "done"
    else
      print "has been modified but is no longer needed, delete [yN]?"
      if STDIN.gets("\n").chomp.downcase[0] == ?y
        File.delete( used )
        puts "done"
      else
        puts "    ...skipped"; next
      end
    end
  else
    puts "was not found."
  end
end
