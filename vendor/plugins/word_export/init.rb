# Include hook code here
require 'word_export'

if (Category.connected? && Category.find_by_name(WordExport::REPORTING_CATEGORY_NAME).nil?)
  Category.new(:name => WordExport::REPORTING_CATEGORY_NAME).save
end
