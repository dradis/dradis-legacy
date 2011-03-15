require 'nmap_upload'

# get the "nmap output" category instance or create it if it does not exist
Category.find_or_create_by_name( NmapUpload::Configuration.category ) 

