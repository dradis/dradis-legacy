require 'html_export'


Category.find_or_create_by_name( HTMLExport::Configuration.category )
