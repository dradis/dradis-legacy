module Dradis
  module Frontend
    class Engine < ::Rails::Engine
      isolate_namespace Dradis
      engine_name 'dradis_frontend'
    end
  end
end