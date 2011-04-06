require 'surecheck_upload'

Category.find_or_create_by_name(SurecheckUpload::Configuration.category)
