module NiktoUpload  
  module Meta
    NAME = "Nikto XML file upload"
    EXPECTS = "Nikto results XML. Use the -o switch with a file name ending in .xml"
    # change this to the appropriate version
    module VERSION #:nodoc:
      MAJOR = 2
      MINOR = 9
      TINY = 0

      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end
