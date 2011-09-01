module ProjectPackageUpload 
  module Meta
    NAME = "Project package upload"
    EXPECTS = "A Dradis project archive (.zip) generated through Export > Project export > Full project"
    # change this to the appropriate version
    module VERSION #:nodoc:
      MAJOR = 2
      MINOR = 8
      TINY = 0

      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end
module ProjectTemplateUpload 
  module Meta
    NAME = "Project template upload"
    EXPECTS = "A Dradis template XML file generated through Export > Project export > As template"
    # change this to the appropriate version
    module VERSION #:nodoc:
      MAJOR = 2
      MINOR = 8
      TINY = 0

      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end
