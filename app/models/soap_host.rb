class SOAPHost < ActionWebService::Struct
  member :uid, :integer
  member :address, :string
  member :services, [SOAPService]
  member :notes, [SOAPNote]
  
  def SOAPHost.from_host(host)
    return SOAPHost.new(
      :uid=>host.id, 
      :address=>host.address, 
      :services=>host.services.collect! do |srv| SOAPService.from_service(srv) end,
      :notes=>host.notes.collect! do |note| SOAPNote.from_note(note) end)
  end
end
