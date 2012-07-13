module Dradis
  module Core
    class Engine < ::Rails::Engine
      isolate_namespace Dradis
    end
  end
end