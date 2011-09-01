module WxfUpload  
  module Meta
    NAME = "Web Exploitation Framework (wXf) file upload"
    EXPECTS = "wXf output in XML format"
    # change this to the appropriate version
    module VERSION #:nodoc:
      MAJOR = 2
      MINOR = 8
      TINY = 0

      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end
