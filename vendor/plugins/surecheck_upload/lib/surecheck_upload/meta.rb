module SurecheckUpload  
  module Meta
    NAME = "SureCheck SQLite3 file upload"
    EXPECTS = "Expects an .sc file from SureCheck which is in SQLite3 format"

    module VERSION #:nodoc:
      MAJOR = 2
      MINOR = 8
      TINY = 0

      STRING = [MAJOR, MINOR, TINY].join('.')
    end
  end
end
