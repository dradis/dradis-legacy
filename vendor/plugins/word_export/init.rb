# Include hook code here
require 'word_export'

Category.find_or_create_by_name( WordExport::REPORTING_CATEGORY_NAME )
