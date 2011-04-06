# Code borrowed from ext_scaffold plugin via nessus_plugin:
#    http://github.com/martinrehfeld/ext_scaffold/tree/master

for path in [ ['config', 'surecheck_upload.yml'] ]
  source = File.join(File.dirname(__FILE__),*path)
  destination = File.join(RAILS_ROOT,*path)
  print "  #{path.join('/')} "
  if File.exists?(destination)
    if FileUtils.cmp(source, destination)
      puts "identical"
    else
      print "exists, overwrite [yN]?"
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

