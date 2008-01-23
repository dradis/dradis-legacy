class SOAPNote < ActionWebService::Struct
  member :uid, :integer
  member :author, :string
  member :category, :string
  member :text, :string
  
  def SOAPNote.from_note(note)
    return SOAPNote.new(
      :uid=>note.id, 
      :author=>note.author, 
      :category=>note.category.name,
      :text=>note.text)
  end
end
