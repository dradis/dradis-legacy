require 'openvas_upload'

Category.find_or_create_by_name(OpenvasUpload::Configuration.category)
