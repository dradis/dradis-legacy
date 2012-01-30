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
Here are your notes for the node you just clicked (*Dradis Framework 2.8*)

If a node has attachments associated with it you will see an exclamation mark @(!)@ by the _Attachments_ title in the tab strip below.
EON

  NOTE2 =<<EON
h1. What's new in this release?

!{float:left;}/images/logo_small.png!

We always try to improve the interface and UX for our users. With this realease
we are introducing a cleaner three-column layout that maximizes the amount of
space available to view your notes and removes the clutter in the note list.

Read more about the three-column layout here:
"http://blog.dradisframework.org/2011/09/new-in-dradis-28-three-column-layout.html":http://blog.dradisframework.org/2011/09/new-in-dradis-28-three-column-layout.html

Knowing that there is a new revision in the server and that we should update is
a good way to learn that others in the team are making changes, however the new
smart updates will bring any changes made by your team mates to your current
session without having to hit refresh or take any other action. Automagic!

A screencast showing the smart ajax updates in action can be found here:
"http://blog.dradisframework.org/2011/09/new-in-dradis-28-smart-refresh.html":http://blog.dradisframework.org/2011/09/new-in-dradis-28-smart-refresh.html

In addition to the above, we have worked on an improved version of the Nmap and
Nessus upload plugins to re-use existing host nodes and thus avoid duplication.

Send us your feature requests! Add them to the project tracker:
"https://github.com/dradis/dradisframework/issues/new":https://github.com/dradis/dradisframework/issues/new

Remember that the _First Time User's Wizard_ can be found at "/wizard":/wizard

And finally, every time you want to reset your Dradis environment and start with an empty repository you can run @reset.sh@ or @reset.bat@

That's all for now, enjoy your Dradis session!
EON

  NOTE3 =<<EON
h1. Getting Help
* Project Site: "http://dradisframework.org":http://dradisframework.org
* Dradis Guides: "http://guides.dradisframework.org":http://guides.dradisframework.org
* "Community Forums":http://dradisframework.org/community/
* "Request a feature":http://dradisframework.uservoice.com/
* Found a bug? "Report it!":http://sourceforge.net/tracker/?atid=1010917&group_id=209736&func=browse
* IRC: *#dradis* @irc.freenode.org
EON

  root = Node.create!(:label => 'Dradis Framework 2.8')
  root.notes.create!( :author => 'First time wizard', :category_id => 1, :text => NOTE1)
  destination = Attachment.pwd.join(root.id.to_s)
  FileUtils.mkdir_p(destination)
  FileUtils.cp( Rails.root.join('app', 'assets', 'images', 'logo_small.png'), destination.join('logo.png') )

  whats_new = root.children.create!( :label => 'What\'s new?')
  whats_new.notes.create!( :author => 'First time wizard', :category_id => 1, :text =>  NOTE2)

  help = root.children.create!( :label => 'Getting help')
  help.notes.create!( :author => 'First time wizard', :category_id => 1, :text =>  NOTE3)
end
