class DelServiceRequest < ActionWebService::Struct
  member :ticket, :string
  member :id, :integer
end