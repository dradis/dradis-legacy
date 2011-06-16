module HTMLExport
  module Actions

    # This method cycles throw the notes in the reporting category and creates
    # a simple HTML report with them. 
    #
    # It uses the template at: ./vendor/plugins/html_export/template.html.erb
    def to_html(params={})
      doc = Processor.generate(params)
      render :type => 'text/html', :text => doc
    end
  end
end
