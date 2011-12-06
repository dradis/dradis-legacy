module RetinaUpload  
  module Meta
    NAME = "This plugin does not have a name, define it at #{__FILE__.gsub(/#{Rails.root.to_s}/,'.')}"
    # change this to the appropriate version
    module VERSION #:nodoc:
      MAJOR = 2
      MINOR = 7
      TINY = 2

      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end
