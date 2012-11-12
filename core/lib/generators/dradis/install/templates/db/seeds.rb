Dradis::Category.create(:name=>'default category')

Dradis::Configuration.create(:name=>'revision', :value=>'0')
Dradis::Configuration.create(:name=>'password', :value=>'improvable_dradis')
Dradis::Configuration.create(:name=>'uploads_node', :value=>'Uploaded files')
Dradis::Configuration.create(:name=>'emails_node', :value=>'Emailed notes')