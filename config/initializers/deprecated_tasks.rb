
#unless %w{ rake thor }.include?(File.basename($0))
#  # TODO: can't we do this through the Rake library? This code breaks in Ruby 1.9 
#  # (.to_a doesn't exist for Strings any more) someone mentioned it didn't work 
#  # for them as they had both rake and rake1.9 commands
#  `rake -T`.to_a.select { |l| l =~ /upload|export|import/ }.each do |task|
#    task_name = task.match(/rake\s([a-z0-9:_\[\]]+)\s+\#/i)[1]
#
#    puts "DEPRECATION WARNING: the task #{task_name} is still provided through Rake. Since dradis v2.7.0 " +
#          "the dradis command line API has been provided through Thor, and Rake reserved for development " +
#          "tasks."
#  end
#end
