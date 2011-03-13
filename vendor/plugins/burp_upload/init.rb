require 'burp_upload'

Category.find_or_create_by_name( BurpUpload::Configuration.category )
