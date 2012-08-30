require 'rbconfig'

module Dradis
  module Core
    module CLI
      class New < Thor::Group
        include Thor::Actions
      end
    end
  end
end