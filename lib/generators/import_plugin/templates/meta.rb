module <%= class_name %>  
  module Meta
    NAME = "This plugin does not have a name, define it at #{__FILE__.gsub(/#{RAILS_ROOT}/,'.')}"
    # change this to the appropriate version
    module VERSION #:nodoc:
      MAJOR = <%= Core::VERSION::MAJOR %>
      MINOR = <%= Core::VERSION::MINOR %>
      TINY = <%= Core::VERSION::TINY %>

      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end
