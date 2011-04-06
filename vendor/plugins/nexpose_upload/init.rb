require 'nexpose_upload'

Category.find_or_create_by_name(NexposeUpload::Configuration.category)
