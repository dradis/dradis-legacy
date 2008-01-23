class DelCategoryRequest < ActionWebService::Struct
  member :ticket, :string
  member :name, :string
end
