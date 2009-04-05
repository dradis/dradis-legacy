module <%= class_name %>  
  module Meta
    NAME = 'Reporting <%= class_name.gsub(/Export/, '') %>'
    # change this to the appropriate version
    module VERSION #:nodoc:
      MAJOR = 2
      MINOR = 0
      TINY  = 2

      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end