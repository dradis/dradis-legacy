# It is fair to assume that once the server goes down, past activity is no
# longer useful and can be disposed of.
Rails.logger.info "Clearing old Logs and Feeds..."

Dradis::Core::Log.destroy_all if Dradis::Core::Log.table_exists?

