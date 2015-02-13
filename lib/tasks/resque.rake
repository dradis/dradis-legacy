require 'resque/tasks'

# We may want to include only the stuff we need, instead of loading the full
# See:
#   http://railscasts.com/episodes/271-resque
task "resque:setup" => :environment do
  ENV['QUEUE'] = 'dradis_upload,dradis_export'
end
