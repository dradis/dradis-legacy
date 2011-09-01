module <%= class_name %>  
  module Meta
    NAME = "This plugin does not have a name, define it at #{__FILE__.gsub(/#{Rails.root.to_s}/,'.')}"
    EXPECTS = "Describe what file format the plugin is able to parse in #{__FILE__.gsub(/#{Rails.root.to_s}/,'.')}"
    # change this to the appropriate version
    module VERSION #:nodoc:
      MAJOR = <%= Core::VERSION::MAJOR %>
      MINOR = <%= Core::VERSION::MINOR %>
      TINY = <%= Core::VERSION::TINY %>

      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end
