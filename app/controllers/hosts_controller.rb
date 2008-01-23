require 'soap/marshal'

class HostsController < ApplicationController
  active_scaffold :host
  def xml
    render :xml => Host.find(:first, params[:id]).to_xml
  end
  def xml2
    render :xml => SOAP::Marshal.marshal( Host.find(:first, params[:id]) )
  end
end
