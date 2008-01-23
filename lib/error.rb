module Dradis
  module Error
    SUCCESS = 0
    UNKNOWN = 1
    NO_TICKET = 2
    UPDATE_IN_PROGRESS = 4
    #8
    #16
    PARAMETER_MISSING = 32
    
    MSG = {
      SUCCESS => 'No error.',
      UNKNOWN => 'Unknown error.',
      NO_TICKET => 'Access denied without a valid ticket.',
      UPDATE_IN_PROGRESS => 'Update error, system is locked by other user. Try again in 1 minute.',
    }
    def Error.msg(code)
      MSG[code]
    end
  end
end