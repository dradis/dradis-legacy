module WordExport
  # The methods defined in the Actions module will be included in the 
  # ExportController so the user can seamlessly access the functionality
  # provided by this plugin through the /export/<method> path.
  module Actions

    # This method will process the template, fill in the placeholders and send
    # the resulting Word XML document using rails' send_data function.
    def generate_report(params={})
      doc = Processor.generate() 
      send_data(doc.to_s, :filename => 'report.xml', :type => :xml)
    end

    # Provide this action so users can download the instructions and get to know
    # how to use the plugin, create a template, etc.
    def usage_instructions(params={})
      send_file( './vendor/plugins/word_export/instructions.xml' )
    end

    # Use this option to download the current template so you can hopefully see
    # where your report and results are coming from.
    def view_template(params={})
      send_file( WordExport::Processor::OPTIONS[:template] )
    end
  end
end
