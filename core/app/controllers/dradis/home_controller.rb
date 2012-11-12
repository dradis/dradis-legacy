module Dradis
  class HomeController < AuthenticatedController
    respond_to :html
    def index
      node = Dradis::Node.create(label: 'Root node')
      redirect_to node_path(node)
      # @nodes = Dradis::Node.all
      # @notes = Dradis::Note.all
      # @categories = Dradis::Category.all
    end
  end
end