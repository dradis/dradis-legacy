# The NmapUpload::Validator module provides methods that allow the nmap upload
# plugin to validate a file before it is passed to the nmap parser. It would 
# allow the plugin to give better feedback to the user if a wrong file is uploaded
module NmapUpload
  module Validator
    require 'rexml/document'

    class NmapValidationError < StandardError; end;

    # TODO: the current implementation parses the file twice, once in the
    # validator and again in the main parser. There must be a better way.
    def Validator.validate(file_content, type = :xml)
      errors = []

      # Currently the plugin only supports XML uploads, maybe more in the future ...
      case type
      when :xml
        # First, check if we can parse the file
        begin
          document = REXML::Document.new(file_content)

          unless document.elements['nmaprun']
            message =<<EOM
#[Title]#
The XML file uploaded doesn't seem to be a valid Nmap XML results file'

#[Error description]#
The root element of the XML document was not <nmaprun>. Maybe you uploaded the wrong file?

This plugin expects an Nmap XML results file that can be generated with the -oX <file>.xml Nmap argument.
EOM
            errors << message
          end

        rescue Exception => e
          message =<<EOM
#[Title]#
We couldn't parse the XML file. Did you upload an Nmap XML output file?

#[Error description]#
We couldn't parse the uploaded file as XML.

This plugin expects a well-formed Nmap XML results file that can be generated with the -oX <file>.xml Nmap argument.

Please verify the structure of the file you tried to upload.

#[Exception message]#
#{e.message}
EOM
          errors << message
        end
      end

      return errors
    end
  end
end