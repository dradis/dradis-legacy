module WordExport
  # The methods defined in the Actions module will be included in the 
  # ExportController so the user can seamlessly access the functionality
  # provided by this plugin through the /export/<method> path.
  module Actions

    # This method will process the template, fill in the placeholders and send
    # the resulting Word XML document using rails' send_data function.
    def generate_report(params={})
      doc = Processor.generate() 
      send_data(doc, :filename => 'report.xml', :type => :xml)
    end

    def usage_instructions(params={})
      send_file( './vendor/plugins/word_export/instructions.xml' )
    end
  end
end
