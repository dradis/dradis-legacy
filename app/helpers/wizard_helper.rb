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
        content_tag :li do
          link_to wizard_path() + '/' + link do
            content_tag :span, title
          end
        end
      end
    end.join
  end
end
