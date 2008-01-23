class AddNoteRequest < ActionWebService::Struct
  member :ticket, :string
  member :annotatable_type, :string
  member :annotatable_id, :integer
  member :author, :string
  member :category, :string
  member :text, :string  
end