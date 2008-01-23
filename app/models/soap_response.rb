require 'error'
class SOAPResponse < ActionWebService::Struct
    member :code, :integer
    member :value, :string
    
    def initialize(code=nil)
      return unless code != nil
      @code = code
      @value = Dradis::Error.msg(code)
    end
end