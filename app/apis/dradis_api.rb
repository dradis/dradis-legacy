class DradisApi < ActionWebService::API::Base
  
  #------------------------------------------------ operations

  #service ticket handling: request a modification ticket
  api_method :requestticket,
    :returns => [ SOAPResponse ]

  api_method :changed,
    :expects => [{:udatenum => :integer}],
    :returns => [{:code => :boolean}]

  #bulk download of knowledge base
  api_method :refresh, 
    :returns => [ KnowledgeBaseResponse ]

  #------------------------------------------------ add
  #knowledge base modifications need to present a 'modification ticket'
  api_method :add_host,
    :expects => [ AddHostRequest ],
    :returns => [ SOAPResponse ]

  api_method :add_service,
    :expects => [ AddServiceRequest ],
    :returns => [ SOAPResponse ]

  api_method :add_protocol,
    :expects => [AddProtocolRequest],
    :returns => [ SOAPResponse ]

  api_method :add_note,
    :expects => [AddNoteRequest],
    :returns => [ SOAPResponse ]

  api_method :add_category,
    :expects => [AddCategoryRequest],
    :returns => [ SOAPResponse ]
  
  #------------------------------------------------ del
  api_method :del_host,
    :expects => [ DelHostRequest ],
    :returns => [ SOAPResponse ]

  api_method :del_service,
    :expects => [DelServiceRequest],
    :returns => [ SOAPResponse ]

  api_method :del_protocol,
    :expects => [DelProtocolRequest],
    :returns => [ SOAPResponse ]
  
  api_method :del_category,
    :expects => [ DelCategoryRequest ],
    :returns => [ SOAPResponse ]
  
  #------------------------------------------------ show
  api_method :show_protocols,
    :returns => [[:string]]
  api_method :show_categories,
    :returns => [[:string]]
    

  #------------------------------------------------ modify
  api_method :edit_note,
    :expects => [EditNoteRequest],
    :returns => [ SOAPResponse ]  
end
