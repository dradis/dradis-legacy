namespace :dradis do

  namespace :attachments do

    desc 'Drop all the attachments from the attachments/ directory'
    task :drop do
      print 'Dropping attachments from attachments/... '
      FileUtils.rm_rf( 'attachments/' )
      puts 'done.'
      FileUtils.mkdir( 'attachments' )
    end
  end

  desc 'Drops the database, removes the attachments and recreates the DB.'
  task :reset => ['db:migrate:reset', 'dradis:attachments:drop'] do
  end
end
