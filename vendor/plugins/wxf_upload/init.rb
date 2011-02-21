require 'wxf_upload'

Category.find_or_create_by_name( WxfUpload::Configuration.category )
