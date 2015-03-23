# This controller can be a handy one to inherit from if we are building
# functionality that requires the user to be authenticated.
#
# It isolates the code from the authentication implementation as we will be able
# to change the details of the filter without the inheriting classes noticing.
#
# Any third-party code (e.g. plugins) should inherit from this class instead of
# calling the authentication filters directly
#

module Dradis
  module Frontend
    class AuthenticatedController < Dradis::Frontend::ApplicationController
      # FIXME: HARD-CODING WARNING #1
      helper Dradis::Themes::Snowcrash::Engine.helpers

      before_filter :login_required
      before_filter :find_nodes

      private
      def find_nodes
        @nodes = Dradis::Core::Node.in_tree
        @new_node = Dradis::Core::Node.new
      end
    end
  end
end
