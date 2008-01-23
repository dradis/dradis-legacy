class AddServiceRequest < ActionWebService::Struct
  member :ticket, :string
  member :name, :string
  member :host, :string
  member :port, :integer
  member :protocol, :string  
end