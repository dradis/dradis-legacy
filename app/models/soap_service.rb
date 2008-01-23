class SOAPService < ActionWebService::Struct
  member :uid, :integer
  member :name, :string
  member :port, :integer
  member :protocol, :string
  member :notes, [SOAPNote]
  
  def SOAPService.from_service(service)
    return SOAPService.new(
      :uid=>service.id, 
      :name=>service.name, 
      :port=>service.port,
      :protocol=>service.protocol.name,
      :notes=>service.notes.collect! do |note| SOAPNote.from_note(note) end)
  end
end
