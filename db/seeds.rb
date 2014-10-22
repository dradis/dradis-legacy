# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

Dradis::Core::Configuration.create(name:'password', value: 'improvable_dradis')

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

# magic_file = File.join( Rails.root, 'config', 'first_login.txt' )
# if ( !File.exists?(magic_file) )
#
#   NOTE1 =<<EON
# Here are your notes for the node you just clicked (*#{Core::VERSION.string}*)
#
# If a node has attachments associated with it you will see an exclamation mark @(!)@ by the _Attachments_ title in the tab strip below.
# EON
#
#   NOTE2 =<<EON
# h1. What's new in this release?
#
# !{float:left;}/assets/logo_small.png!
#
# In this release we have worked on a number of new plugins and improvements to
# our existing ones:
#
# * New "Retina Network Security Scanner":http://www.eeye.com/products/retina/retina-network-scanner plugin
# * New "Zed Attack Proxy":https://www.owasp.org/index.php/OWASP_Zed_Attack_Proxy_Project upload plugin
# * Faster (60x times) "Nessus":http://www.nessus.org/products/nessus upload plugin
# * Faster "Nikto":http://cirt.net/nikto2 upload plugin
# * Faster "Nmap":http://nmap.org upload plugin (through ruby-nmap gem)
# * Updated VulnDB import plugin (to support "VulnDB HQ":http://vulndbhq.com integration)
#
# We have also updated our core stack to use Rails 3.2, the latest release available.
#
# Do you have some ideas? Send us your feature requests!
# "http://dradisframework.uservoice.com/":http://dradisframework.uservoice.com/forums/38386-general
#
# Remember that the _First Time User's Wizard_ can be found at "/wizard":/wizard
#
# And finally, every time you want to reset your Dradis environment and start with an empty repository you can run @reset.sh@ or @reset.bat@
#
# That's all for now, enjoy your Dradis session!
# EON
#
#   NOTE3 =<<EON
# h1. Getting Help
# * Project Site: "http://dradisframework.org":http://dradisframework.org
# * Dradis Guides: "http://guides.dradisframework.org":http://guides.dradisframework.org
# * "Community Forums":http://dradisframework.org/community/
# * "Request a feature":http://dradisframework.uservoice.com/
# * Found a bug? "Report it!":http://sourceforge.net/tracker/?atid=1010917&group_id=209736&func=browse
# * IRC: *#dradis* @irc.freenode.org
# EON
#
#   root = Node.create!(:label => Core::VERSION.string)
#   root.notes.create!( :author => 'First time wizard', :category_id => 1, :text => NOTE1)
#   destination = Attachment.pwd.join(root.id.to_s)
#   FileUtils.mkdir_p(destination)
#   FileUtils.cp( Rails.root.join('app', 'assets', 'images', 'logo_small.png'), destination.join('logo.png') )
#
#   whats_new = root.children.create!( :label => 'What\'s new?')
#   whats_new.notes.create!( :author => 'First time wizard', :category_id => 1, :text =>  NOTE2)
#
#   help = root.children.create!( :label => 'Getting help')
#   help.notes.create!( :author => 'First time wizard', :category_id => 1, :text =>  NOTE3)
# end
