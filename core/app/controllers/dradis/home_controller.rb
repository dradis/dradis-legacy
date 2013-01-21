module Dradis
  class HomeController < AuthenticatedController
    respond_to :html
    def index
      @last_audit = 0
      if Dradis::Log.where(:uid=>0).count > 0
        @last_audit = Dradis::Log.where(:uid => 0).order('created_at desc').limit(1)[0].id
      end
    end

    def preview
      respond_to do |format|
        format.json {
          # gracefully handle RedCloth absence
          output = ''
          begin
            output = params[:text]
            Hash[ *params[:text].scan(/#\[(.+?)\]#[\r|\n](.*?)(?=#\[|\z)/m).flatten.collect{ |str| str.strip } ].keys.each do |field|
              output.gsub!(/#\[#{field}\]#[\r|\n]/, "h1. #{field}\n\n")
            end

            output = RedCloth.new(output, [:filter_html]).to_html
          rescue Exception
            output = "<pre>#{ CGI::escapeHTML(params[:text]) }</pre>"
          end

          render :json => {
            :html => output
          }
        }
      end
    end
  end
end