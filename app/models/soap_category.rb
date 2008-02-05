class SOAPCategory < ActionWebService::Struct
  member :uid, :integer
  member :name, :string
  
  def SOAPCategory.from_category(category)
    return SOAPCategory.new(
      :uid=>category.id, 
      :name=>category.name)
  end
end
