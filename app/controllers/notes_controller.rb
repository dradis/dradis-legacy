# This controller exposes the REST operations required to manage the Note
# resource.
class NotesController < ApplicationController
  before_filter :login_required
  before_filter :find_or_initialize_node
  before_filter :find_or_initialize_note, :except => [ :index ]
  
  after_filter :update_revision_if_modified, :except => [ :index , :show]

  # Retrieve the list of Note objects associated with a given Node.
  # Formats supported: XML, JSON
  def index
    @notes = Note.find(:all, :conditions => {:node_id => @node.id})
    respond_to do |format|
      format.html { }
      
      format.xml { render :xml => @notes.to_xml}
      format.json { 
        render :json => { :success => true,
                          :data => @notes#.to_json(:include => :category)
                        }
      }
    end
  end

  # Create a new Note for the associated Node.
  # Formats supported: XML
  def create
    respond_to do |format|
      format.html { head :method_not_allowed }
      
      if @note.save
        @modified = true
        format.xml { 
          headers['Location'] = node_notes_url(@note.id)
          render :xml => @note.to_xml, :status => :created 
        }
        format.json {
          render :json => { :success => true, :data => @note }
        }
      else
        format.xml { 
          render :xml => @note.errors.to_xml, 
          :status => :unprocessable_entity 
        }
        format.json{ 
          render :json => { :succes => false, :errors => @note.errors }, 
            :status => :unprocessable_entity 
        }
      end
    end
  end
  
  # Retrieve a Note given its :id
  # Formats supported: XML
  def show
    respond_to do |format|
      format.html { head :method_not_allowed }
      format.xml { render :xml => @note.to_xml}
    end
  end
  
  # Update the attributes of a Note
  # Formats supported: XML
  def update
    respond_to do |format|
      format.html { head :method_not_allowed }

      if @note.update_attributes(params[:note] || ActiveSupport::JSON.decode(params[:data]) )
        @modified = true
        format.xml { render :xml => @note.to_xml }
        format.json{ render :json => { :success => true }.to_json }
      else
        format.xml { render :xml => @note.errors.to_xml, :status => :unprocessable_entity }
        format.json{ render :json => @note.errors.to_json, :status => :unprocessable_entity }
      end
    end
  end
  
  # Remove a Note from the back-end database.
  # Formats supported: XML
  def destroy
    respond_to do |format|
      format.html { head :method_not_allowed }
      
      if @note.destroy
        @modified = true
        format.xml { head :ok }
        format.json{ render :json => {:success => true} }
      else
        format.xml { render :xml => @note.errors.to_xml, :status => :unprocessable_entity }
        format.json{ render :json => { :success => false, :errors => @note.errors } }
      end
    end
  end
  
  private
  # For most of the operations of this controller we need to identify the Node
  # we are working with. This filter sets the @node instance variable if the 
  # give :node_id is valid.
  def find_or_initialize_node
    begin 
      @node = Node.find(params[:node_id])
    rescue
      flash[:error] = 'Node not found'
      redirect_to root_path
    end
  end

  # Once a valid @node is set by the previous filter we look for the Note we
  # are going to be working with based on the :id passed by the user.
  def find_or_initialize_note
    if params[:id]
      unless @note = Note.find(params[:id])
        render_optional_error_file :not_found
      end
    else
      @note = Note.new(params[:note] || ActiveSupport::JSON.decode(params[:data]))
      @note.node = @node
    end
    @note.updated_by = current_user
  end

  # This is an after_filter that increments the current revision if a note was
  # modified as a result of any of the operations exposed by this controller.
  def update_revision_if_modified
    return unless @modified
    ::Configuration.increment_revision
  end
end
