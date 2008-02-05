require 'error'
class KnowledgeBaseResponse < ActionWebService::Struct
    member :revision, :integer
    member :hosts, [SOAPHost]
    member :categories, [SOAPCategory]
    member :protocols, [SOAPProtocol]
end