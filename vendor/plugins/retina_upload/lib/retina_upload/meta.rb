module RetinaUpload  
  module Meta
    NAME = "Retina Network Security Scanner (.xml) file upload"
    EXPECTS = "Retina XML Vulnerability Export"
    # change this to the appropriate version
    module VERSION #:nodoc:
      MAJOR = 2
      MINOR = 9
      TINY = 0

      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end
