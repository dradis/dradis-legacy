# Initialize the different Note categories that are required by the framework.

# Unless the DB is already migrated, do nothing
if Dradis::Core::Category.table_exists?
  [
    :default,
    :issue,
    :properties,
    :report
  ].each do |category|
    Dradis::Core::Category.send(category)
  end
end