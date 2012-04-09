module NexposeUpload  
  module Meta
    NAME = "NeXpose XML file upload"
    EXPECTS = "NeXpose Simple or Full XML format."

    module VERSION #:nodoc:
      MAJOR = 2
      MINOR = 7
      TINY = 0

      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end
