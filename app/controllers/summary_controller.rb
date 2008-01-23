class SummaryController < ApplicationController

def index
  @hosts = Host.find(:all)
end

end
