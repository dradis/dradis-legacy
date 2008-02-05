class SOAPProtocol < ActionWebService::Struct
  member :uid, :integer
  member :name, :string
  
  def SOAPProtocol.from_protocol(protocol)
    return SOAPProtocol.new(
      :uid=>protocol.id, 
      :name=>protocol.name)
  end
end
