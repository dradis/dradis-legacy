# This mixing provides REST operations for a given resource. When the mixin is
# included, the ClassMethods module is added to the class that includes it.
module RESTOperations

  # React to the event of this mixin being included. The including (base) class
  # will be extended with the methods defined in the ClassMethod module.
  def self.included(base)
    base.extend(ClassMethods)
  end

  # This module provides a number of REST methods to handle the 
  # show/create/update/destroy operations associated with a REST resource.
  module ClassMethods

    # When the base class calls this method, a series of code templates are 
    # applied and new instance methods for show/create/update/destroy operations
    # are added to it.
    #
    # Base classes include: NotesController and CategoriesController
    def rest_operations_for(model_symbol, options={})
      # The Class of the model we are RESTing
      model_klass = eval(model_symbol.to_s.capitalize)

      # if the model wants to include some child in the xml
      include_str = options.key?(:include) ? "{ :include => :#{options[:include]} }" : ''
      # nested resources need a reference to their parents for redirections: parent_child_url(@object)
      redirect_url = options.key?(:parent) ? "#{options[:parent]}_#{model_symbol}_url" : "#{model_symbol}_url"
  
      if options.key?(:parent)
        class_eval %(
          before_filter :find_parent, :except => [ :index ]
          def find_parent
            if params[:node_id]
              unless @node = Node.find_by_id(params[:node_id])
                render_optional_error_file :not_found
              end
            else
              render_optional_error_file :not_found
            end
          end        
        )
      end
      
      
      class_eval %(
        before_filter :login_required
        before_filter :find_or_initialize_model, :except => [ :index ]
        def find_or_initialize_model
          if params[:id]
            unless @model = #{model_klass}.find_by_id(params[:id])
              render_optional_error_file :not_found
            end
          else
            @model = #{model_klass}.new(params[:#{model_symbol}])
          end
        end
  
        # GET /nodes
        # Formats: xml
        def index
          @models = #{model_klass}.find(:all)
          respond_to do |format|
            format.html { head :method_not_allowed }

            format.xml { render :xml => @models.to_xml(#{include_str})}
          end
        end        

        # POST /nodes
        # Formats: xml
        def create
          respond_to do |format|
            format.html { head :method_not_allowed }

            if @model.save
              @modified = true
              format.xml { 
                headers['Location'] = #{redirect_url}(@model)
                render :xml => @model.to_xml(#{include_str}), :status => :created 
              }
            else
              format.xml { 
                render :xml => @model.errors.to_xml, 
                :status => :unprocessable_entity 
              }
            end
          end
        end        


        # GET /node/<id>
        # Formats: xml
        def show
          respond_to do |format|
            format.html { head :method_not_allowed }
            format.xml { render :xml => @model.to_xml(#{include_str}) }
          end
        end

        # PUT /node/<id>
        # Formats: xml
        def update
          respond_to do |format|
            format.html { head :method_not_allowed }

            if @model.update_attributes(params[:#{model_symbol}])
              @modified = true
              format.xml { render :xml => @model.to_xml(#{include_str}) }
            else
              format.xml { render :xml => @model.errors.to_xml, :status => :unprocessable_entity }
            end
          end
        end

        # DELETE /nodes/<id>
        # Formats: xml
        def destroy
          respond_to do |format|
            format.html { head :method_not_allowed }

            if @model.destroy
              @modified = true
              format.xml { head :ok }
            else
              format.xml { render :xml => @model.errors.to_xml, :status => :unprocessable_entity }
            end
          end
        end

      )
    end

  end
end

# A sub-class that includes the RESTOperations mixin by default
class RestfulController < ApplicationController
  after_filter :update_revision_if_modified, :except => [ :index , :show]
  include RESTOperations  
  
  # If as the result of any operation in this controller an object was modified,
  # ensure that the current revision number is incremented.
  def update_revision_if_modified
    return unless @modified
    Configuration.increment_revision
  end  
end
