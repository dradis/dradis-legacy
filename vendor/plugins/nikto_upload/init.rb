require 'nikto_upload'

Category.find_or_create_by_name( NiktoUpload::Configuration.category )
