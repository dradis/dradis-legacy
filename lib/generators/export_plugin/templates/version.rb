module <%= class_name %>
  # change this to the appropriate version
  module VERSION #:nodoc:
    MAJOR = <%= Core::VERSION::MAJOR %>
    MINOR = <%= Core::VERSION::MINOR %>
    TINY = <%= Core::VERSION::TINY %>

    STRING = [MAJOR, MINOR, TINY].join('.')
  end
end
