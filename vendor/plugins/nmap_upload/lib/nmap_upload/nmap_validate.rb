# The NmapValidate module provides methods that allow the nmap upload plugin to
# validate a file before it is passed to the nmap parser. It would allow the
# plugin to give better feedback to the user if a wrong file is uploaded

module NmapValidate
  require 'rexml/document'

  class NmapValidationError < StandardError; end;

  def NmapValidate.validate(file, type = :xml)
    # Currently the plugin only supports XML uploads, maybe more in the future ...
    case type
    when :xml
      # Do a very, very basic validation. Just checking that there is a nmaprun XML node in the file
      raise NmapValidationError, "The uploaded file does not appear to be a valid Nmap XML results file." \
        unless REXML::Document.new(file).elements['nmaprun']
    end
    return true
  end

end