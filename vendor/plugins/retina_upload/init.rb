require 'retina_upload'

Category.find_or_create_by_name(RetinaUpload::Configuration.category)