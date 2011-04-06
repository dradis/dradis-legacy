require 'w3af_upload'

Category.find_or_create_by_name(W3afUpload::Configuration.category)
