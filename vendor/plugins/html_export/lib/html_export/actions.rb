module HTMLExport
  module Actions

    # This method cycles throw the notes in the reporting category and creates
    # a simple HTML report with them. 
    #
    # It uses the template at: ./vendor/plugins/html_export/template.html.erb
    def to_html(params={})
      category_name = params.fetch(:category_name, Configuration.category)
      reporting_cat = Category.find_by_name(category_name)
      reporting_notes_num = Note.count(:all, :conditions => {:category_id => reporting_cat})

      title = "Dradis Framework - v#{Core::VERSION::STRING}"
      notes = Note.find( :all, :conditions => {:category_id => reporting_cat} )
      erb = ERB.new( File.read(Configuration.template) )
      #send( erb.result(),  :filename => 'report.html', :type => 'text/html') 
      render :type => 'text/html', 
              :text => erb.result( binding ) 

    end
  end
end
