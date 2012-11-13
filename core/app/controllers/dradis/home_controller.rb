module Dradis
  class HomeController < AuthenticatedController
    respond_to :html
    def index
      @last_audit = 0
      if Dradis::Log.where(:uid=>0).count > 0
        @last_audit = Dradis::Log.where(:uid => 0).order('created_at desc').limit(1)[0].id
      end
    end
  end
end