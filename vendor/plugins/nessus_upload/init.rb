require 'nessus_upload'

Category.find_or_create_by_name( NessusUpload::Configuration.category ) 
