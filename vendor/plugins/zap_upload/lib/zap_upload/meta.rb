module ZapUpload  
  module Meta
    NAME = "ZAP Upload plugin"
    EXPECTS = "ZAP Proxy XML reports. Generate through  Report > Generate XML Report ..."
    # change this to the appropriate version
    module VERSION #:nodoc:
      MAJOR = 2
      MINOR = 9
      TINY = 0

      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end
