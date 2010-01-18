module HTMLExport
  module Actions

    # This method cycles throw the notes in the reporting category and creates
    # a simple HTML report with them. 
    #
    # It uses the template at: ./vendor/plugins/html_export/template.html.erb
    def to_html(params={})
      title = "Dradis Framework - v#{Core::VERSION::STRING}"
      notes = Note.all 
      erb = ERB.new( File.read(HTMLExport::CONF[:template]) )
      #send( erb.result(),  :filename => 'report.html', :type => 'text/html') 
      render :type => 'text/html', 
              :text => erb.result( binding ) 

    end
  end
end
