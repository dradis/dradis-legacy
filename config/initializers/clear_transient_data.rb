# It is fair to assume that once the server goes down, past activity is no
# longer useful and can be disposed of.
Rails.logger.info "Clearing old Logs and Feeds..."

# Check that we are in normal operating mode, if we are in dradis:reset, skip.
unless ActiveRecord::Migrator.new(:up, ActiveRecord::Migrator.migrations_paths).pending_migrations.empty?
  Log.destroy_all
  Feed.destroy_all
end