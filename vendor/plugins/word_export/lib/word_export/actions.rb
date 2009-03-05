module WordExport
  # The methods defined in the Actions module will be included in the 
  # ExportController so the user can seamlessly access the functionality
  # provided by this plugin through the /export/<method> path.
  module Actions

    # This method will process the template, fill in the placeholders and send
    # the resulting Word XML document using rails' send_data function.
    def word(params={})
      doc = Processor.generate() 
      send_data(doc, :filename => 'report.xml', :type => :xml)
    end
  end
end
