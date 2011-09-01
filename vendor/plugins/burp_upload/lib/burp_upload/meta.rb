module BurpUpload  
  module Meta
    NAME = "Burp Scanner output (.xml) file upload"
    EXPECTS = "Burp Scanner XML output. Go to the Scanner tab > right-click item > generate report"
    # change this to the appropriate version
    module VERSION #:nodoc:
      MAJOR = 2
      MINOR = 8
      TINY = 0

      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end
