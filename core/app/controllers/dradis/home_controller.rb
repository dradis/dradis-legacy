module Dradis
  class HomeController < AuthenticatedController
    respond_to :html
    def index
      @nodes = Dradis::Node.all
      @notes = Dradis::Note.all
      @categories = Dradis::Category.all
    end
  end
end