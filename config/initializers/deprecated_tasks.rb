
unless %w{ rake thor }.include?(File.basename($0))
  `rake -T`.to_a.select { |l| l =~ /upload|export|import/ }.each do |task|
    task_name = task.match(/rake\s([a-z0-9:_\[\]]+)\s+\#/i)[1]

    puts "DEPRECATION WARNING: the task #{task_name} is still provided through Rake. Since dradis v2.7.0 " +
          "the dradis command line API has been provided through Thor, and Rake reserved for development " +
          "tasks."
  end
end