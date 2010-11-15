# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)


Category.create(:name=>'default category')

Configuration.create(:name=>'revision', :value=>'0')
Configuration.create(:name=>'password', :value=>'improvable_dradis')
Configuration.create(:name=>'uploads_node', :value=>'Uploaded files')
Configuration.create(:name=>'emails_node', :value=>'Emailed notes')


# The code below checks whether the config/first_login.txt file exists. If it 
# doesn't then it will pre-populate the database with some default Nodes and 
# Notes.
#
# This is specially useful for people running Dradis for the first time and to
# explain the new features introduced in this release.
#
# Upon first login, the @show_first_time_wizard@ before_filter in the ApplicationController
# will create the config/first_login.txt file and this code will never be 
# processed again.
#

magic_file = File.join( Rails.root, 'config', 'first_login.txt' )
if ( !File.exists?(magic_file) )

  NOTE1 =<<EON
Here are your notes for the node you just clicked (*Dradis Framework 2.6*)

If a node has attachments associated with it you will see an exclamation mark @(!)@ by the _Attachments_ title in the tab strip below.
EON

  NOTE2 =<<EON
h1. What's new in this release?

!{float:left;}/images/logo_small.png!

This is (mostly) a *performance improvement* release. 

We have upgraded the server-side engine of Dradis and the client-side JavaScript library to the latest stable  version available from their vendors to "Rails 3":http://rubyonrails.org/ and "ExtJS 3.3":http://www.sencha.com/products/js/.

One of the most expected upload plugins is finally here, it is now possible to upload "Qualys":http://qualys.de/ XML files.

Remember that the _First Time User's Wizard_ can be found at "/wizard":/wizard

That's all for now, enjoy your Dradis session!
EON

  NOTE3 =<<EON
h1. Getting Help
* Project Site: "http://dradisframework.org":http://dradisframework.org
* "Community Forums":http://dradisframework.org/community/
* "Request a feature":http://dradisframework.uservoice.com/
* Found a bug? "Report it!":http://sourceforge.net/tracker/?atid=1010917&group_id=209736&func=browse
* IRC: *#dradis* @irc.freenode.org
EON

  root = Node.create!(:label => 'Dradis Framework 2.6')
  root.notes.create!( :author => 'First time wizard', :category_id => 1, :text => NOTE1)
  destination = File.join(Rails.root, 'attachments', root.id.to_s)
  FileUtils.mkdir_p(destination)
  FileUtils.cp( File.join(Rails.root, 'public', 'images', 'logo_small.png'), File.join(destination, 'logo.png') )

  whats_new = root.children.create!( :label => 'What\'s new?')
  whats_new.notes.create!( :author => 'First time wizard', :category_id => 1, :text =>  NOTE2)

  help = root.children.create!( :label => 'Getting help')
  help.notes.create!( :author => 'First time wizard', :category_id => 1, :text =>  NOTE3)
end
