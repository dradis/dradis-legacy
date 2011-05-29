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
Here are your notes for the node you just clicked (*Dradis Framework 2.7*)

If a node has attachments associated with it you will see an exclamation mark @(!)@ by the _Attachments_ title in the tab strip below.
EON

  NOTE2 =<<EON
h1. What's new in this release?

!{float:left;}/images/logo_small.png!

We have improved the web interface with a new 
"Configuration Manager":configurations to handle all your plugin's configuration.

There is also a new "Upload Manager":upload that processes uploads in the 
background while providing you with status updates via Ajax.

We have lots of new plugins:
* "Metasploit":http://www.metasploit.com import
* "NeXpose":http://www.rapid7.com/products/nexpose-community-edition.jsp (.xml) upload
* "OpenVAS":http://openvas.org/ (.xml) upload
* "SureCheck":http://www.wildcroftsecurity.com/ (.sc) upload (for build reviews)
* "w3af":http://w3af.sourceforge.net/ (.xml) upload
* "Web Exploitation Framework":https://github.com/WebExploitationFramework/wXf (wXf) upload

And a few that have been updated:
* "Nessus":http://www.tenable.com/products/nessus plugin supports .nessus version 2
* "Vuln::DB":http://securityroots.com/vulndb/ import plugin updated to work with the latest release

Oh, and we have also improved the command line API with Thor. To checkout all 
the available tasks, go to the server folder and run:

bc. thor -T

Remember that the _First Time User's Wizard_ can be found at "/wizard":/wizard

And finally, every time you want to reset your Dradis environment and start with an empty repository you can run @reset.sh@ or @reset.bat@

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

  root = Node.create!(:label => 'Dradis Framework 2.7')
  root.notes.create!( :author => 'First time wizard', :category_id => 1, :text => NOTE1)
  destination = Attachment::pwd.join(root.id.to_s)
  FileUtils.mkdir_p(destination)
  FileUtils.cp( File.join(Rails.root, 'public', 'images', 'logo_small.png'), File.join(destination, 'logo.png') )

  whats_new = root.children.create!( :label => 'What\'s new?')
  whats_new.notes.create!( :author => 'First time wizard', :category_id => 1, :text =>  NOTE2)

  help = root.children.create!( :label => 'Getting help')
  help.notes.create!( :author => 'First time wizard', :category_id => 1, :text =>  NOTE3)
end
