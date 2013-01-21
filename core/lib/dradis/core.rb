require 'acts_as_tree'
# require 'bootstrap-sass'
require 'rails/all'

require 'dradis/core/engine'

require 'dradis/core/cli'
require 'dradis/core/configurator'
require 'dradis/core/plugins'
require 'dradis/core/version'

module Dradis
  module Core
  end

  # Used to configure Dradis.
  #
  # Example:
  #
  # Dradis.config do |config|
  #   config.site_name = "An awesome Dradis site"
  # end
  #
  # This method is defined within the core gem on purpose.
  # Some people may only wish to use the Core part of Dradis.
  def self.config(&block)
    # yield(Dradis::Config)
  end
end