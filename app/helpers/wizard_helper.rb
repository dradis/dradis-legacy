module WizardHelper
  def menu_tabs
    [ 
      [ 'Welcome', 'index' ], 
      [ 'Users and Passwords', 'users' ],
      [ 'Interface', 'interface' ],
      [ 'Plugins', 'plugins' ],
      [ 'Reporting', 'reporting'],
      [ 'Community / Help', 'community' ]
    ].collect do |title, link|
      action = request.parameters.fetch('action', '')
      if (action == link)
        "<li class=\"active\"><a href=\"#\"><span>#{title}</span></a></li>"  
      else
        "<li><a href=\"/wizard/#{link}\"><span>#{title}</span></a></li>"  
      end
    end.join
  end
end
