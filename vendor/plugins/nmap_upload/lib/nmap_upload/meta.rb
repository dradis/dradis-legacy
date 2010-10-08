module NmapUpload
  module Meta
    NAME = "This plugin does not have a name, define it at #{__FILE__.gsub(/#{RAILS_ROOT}/,'.')}"
    # change this to the appropriate version
    module VERSION #:nodoc:
      MAJOR = 2
      MINOR = 2
      TINY = 0

      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end
