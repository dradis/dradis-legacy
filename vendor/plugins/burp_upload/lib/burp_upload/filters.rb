module BurpUpload  
  private
  @@logger=nil

  public
  
  # This method will be called by the framework when the user selects your 
  # plugin from the drop down list of the 'Import from file' dialog
  def self.import(params={})
    file_content = File.read( params[:file] )
    @@logger = params.fetch(:logger, Rails.logger)

    @@logger.info{ 'Parsing Burp Scanner output...' }
    burpscan = Burp::Parser.parsestring( file_content )
    @@logger.info{ 'Done.' }

    category = Category.find_or_create_by_name(Configuration.category)

    scan_node = Node.create( :label => "Burp Scanner results")

    issue_types = {}

    burpscan.issues.each do |issue|
      @@logger.info{ "Adding #{issue.name[:text]}" }

      issue_type = issue.type[:text].to_i


      # The first time a new issue type is created, a new sub-node is added and
      # a note with the issue background, description and recommendation is 
      # included.
      #
      # For subsequent instances of the same issue a note with the location,
      # request and response sections is included
      if !issue_types.key?( issue_type )
        issue_types[ issue_type ] =Node.create( :label => issue.name[:text], :parent => scan_node)
        type_processed = false


        issue_desc = "#[Name]#\n"
        issue_desc << issue.name[:text] if issue.name
        issue_desc << "\n\n#[Issue Background]#\n"
        issue_desc << issue.issueBackground[:text] if issue.issueBackground
        issue_desc << "\n\n#[Remediation Background]#\n"
        issue_desc << issue.remediationBackground[:text] if issue.remediationBackground
        issue_desc << "\n\n#[Issue Detail]#\n"
        issue_desc << issue.issueDetail[:text] if issue.issueDetail
        issue_desc << "\n\n#[Remediation Details]#\n"
        issue_desc << issue.remediationDetail[:text] if issue.remediationDetail
        
        Note.create(
          :node => issue_types[ issue_type ],
          :author => Configuration.author,
          :category => category,
          :text => issue_desc
        )
      end


      issue_detail = "#[Host]#\n"
      issue_detail << issue.host[:text] if issue.host
      issue_detail << "\n\n#[Path]#\n"
      issue_detail << issue.path[:text] if issue.path
      issue_detail << "\n\n#[Location]#\n"
      issue_detail << issue.location[:text] if issue.location
      issue_detail << "\n\n#[Severity]#\n"
      issue_detail << issue.severity[:text] if issue.severity
      issue_detail << "\n\n#[Confidence]#\n"
      issue_detail << issue.confidence[:text] if issue.confidence

      if issue.requestresponse
        parsed_request = issue.requestresponse[:kids].find_tag(:request)[:text].gsub(/\0/,'&#00;') 
        issue_detail << "\n\n#[Request]#\n"
        issue_detail << parsed_request
        issue_detail << "\n\n#[Response]#\n"
        if ( issue_type == 8389888 )
          # Content type is not specified
          issue_detail << "--Response not included. Issue Serial Number: "
          issue_detail << issue.serialNumber[:text] if issue.serialNumber
        else
          parsed_response = issue.requestresponse[:kids].find_tag(:response)[:text].gsub(/\0/,'&#00;')
          issue_detail << parsed_response 
        end
      end

      Note.create(
        :node => issue_types[issue_type],
        :author => Configuration.author,
        :category => category,
        :text => issue_detail
      )
    end

    @@logger.info{ 'Burp Scanner results successfully imported' }

    return true

  end
end
