class TicketResponse < SOAPResponse
  def initialize(value)
    @code = Dradis::Error::SUCCESS
    @value = value
  end
end