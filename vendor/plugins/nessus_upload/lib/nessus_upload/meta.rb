module NessusUpload
  module Meta
    NAME = "Nessus output (.nessus) file upload"
    EXPECTS = "Nessus XML (V2) format."
    # change this to the appropriate version
    module VERSION #:nodoc:
      MAJOR = 2
      MINOR = 9
      TINY = 0

      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end
