class EditNoteRequest < ActionWebService::Struct
  member :ticket, :string
  member :uid, :integer
  member :author, :string
  member :category, :string
  member :text, :string  
end