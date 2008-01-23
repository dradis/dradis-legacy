require 'error'
class KnowledgeBaseResponse < ActionWebService::Struct
    member :revision, :integer
    member :hosts, [SOAPHost]
end