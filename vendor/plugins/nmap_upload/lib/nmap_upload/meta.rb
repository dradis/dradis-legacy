module NmapUpload
  module Meta
    NAME = "Nmap output (.xml) file upload"
    EXPECTS = "Nmap results file in XML format. Generate with -oX"
    # change this to the appropriate version
    module VERSION #:nodoc:
      MAJOR = 2
      MINOR = 9
      TINY = 0

      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end
