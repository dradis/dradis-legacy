module W3afUpload  
  module Meta
    NAME = "w3af file upload"
    EXPECTS = "w3af output in XML format"
    # change this to the appropriate version
    module VERSION #:nodoc:
      MAJOR = 2
      MINOR = 8
      TINY = 0

      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end
