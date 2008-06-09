class NotesController < ApplicationController
  before_filter :find_or_initialize_node
  before_filter :find_or_initialize_note, :except => [ :index ]
  
  after_filter :update_revision_if_modified, :except => [ :index , :show]

  # GET /nodes
  # Formats: xml
  def index
    @notes = Note.find(:all)
    respond_to do |format|
      format.html { head :method_not_allowed }
      
      format.xml { render :xml => @notes.to_xml}
    end
  end

  # POST /notes
  # Formats: xml
  def create
    respond_to do |format|
      format.html { head :method_not_allowed }
      
      if @note.save
        @modified = true
        format.xml { 
          headers['Location'] = node_notes_url(@note.id)
          render :xml => @note.to_xml, :status => :created 
        }
      else
        format.xml { 
          render :xml => @note.errors.to_xml, 
          :status => :unprocessable_entity 
        }
      end
    end
  end
  
  # GET /note/<id>
  # Formats: xml
  def show
    respond_to do |format|
      format.html { head :method_not_allowed }
      format.xml { render :xml => @note.to_xml}
    end
  end
  
  # PUT /note/<id>
  # Formats: xml
  def update
    respond_to do |format|
      format.html { head :method_not_allowed }

      if @note.update_attributes(params[:note])
        @modified = true
        format.xml { render :xml => @note.to_xml }
      else
        format.xml { render :xml => @note.errors.to_xml, :status => :unprocessable_entity }
      end
    end
  end
  
  # DELETE /notes/<id>
  # Formats: xml
  def destroy
    respond_to do |format|
      format.html { head :method_not_allowed }
      
      if @note.destroy
        @modified = true
        format.xml { head :ok }
      else
        format.xml { render :xml => @note.errors.to_xml, :status => :unprocessable_entity }
      end
    end
  end
  
  def find_or_initialize_node
    if params[:node_id]
      unless @node = Node.find_by_id(params[:node_id])
        render_optional_error_file :not_found
      end
    else
      render_optional_error_file :not_found
    end
  end
  def find_or_initialize_note
    if params[:id]
      unless @note = Note.find_by_id(params[:id])
        render_optional_error_file :not_found
      end
    else
      @note = Note.new(params[:note])
      @note.node = @node
    end
  end

  def update_revision_if_modified
    return unless @modified
    Configuration.increment_revision
  end
end
