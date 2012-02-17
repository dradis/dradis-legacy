# It is fair to assume that once the server goes down, past activity is no
# longer useful and can be disposed of.
Rails.logger.info "Clearing old Logs and Feeds..."

Log.destroy_all if Log.table_exists?
Feed.destroy_all if Feed.table_exists?
