module SurecheckUpload  
  private
  @@logger=nil

  public
  
  # This method will be called by the framework when the user selects your 
  # plugin from the drop down list of the 'Import from file' dialog
  def self.import(params={})
    @@logger = params.fetch(:logger, Rails.logger)

    @@logger.info{ 'Parsing SureCheck output...' }
    screport = Surecheck::Parser.parsefile( params[:file] )
    @@logger.info{ 'Done.' }

    category = Category.find_or_create_by_name(Configuration.category)

    sc_node = Node.create( :label => Configuration.node_label)

    screport.findings.each do |finding|
      @@logger.info{ "Adding SureCheck Finding \##{finding.id.to_s}" }
      finding_detail = ''

      if finding.title
        finding_detail << "#[Title]#\n"
        finding_detail << finding.title
        finding_detail << "\n\n"
      end
      
      if finding.severity
        finding_detail << "\n#[Severity]#\n"
        finding_detail << finding.severity_before_type_cast
        finding_detail << "\n\n"
      end
  
      #finding_detail << "\n#[Priority]#\n"
      #finding_detail << issue.priority.to_s if issue.priority
  
      #finding_detail << "\n#[Content]#\n" if finding.content
      if finding.content
        # Convert section headers (e.g. ==Description==) into the Dradis format
        # (e.g. #[Description]#)
        content = finding.content.gsub(/==[\s]?(\w+)[\s]?==/)  {|s| "\n#[" + $1.capitalize + "]#"} 

        # Remove hypelink markup
        content.gsub!(/:\[\[(.+?)\]\]/) { $1 }

        # Remove table markup
        content.gsub!(/<<table-columns 10,90>>/, '')
        content.gsub!(/\|=\s(\w+?)\s\|\s##([\w\s\\]+?)##/) { "#{$1}: #{$2}" }

        finding_detail << content 
      end

      Note.create(
        :node => sc_node,
        :author => Configuration.author,
        :category => category,
        :text => finding_detail.to_s
      )
    end
    
    @@logger.info{ 'SureCheck results successfully imported' }

    return true
  end
end

