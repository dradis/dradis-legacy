# Each Note belongs to a Category. This controller exposes the REST operations
# required to manage the Category resource. 
class CategoriesController < ApplicationController
  before_filter :login_required
  before_filter :find_or_initialize_category, :except => [:index]

  private
  def find_or_initialize_category
    if params[:id]
      unless( @category = Category.find_by_id(params[:id]) )
        render_optional_error_file :not_found
      end
    else
      @category = Category.new(params[:category] || ActiveSupport::JSON.decode(params[:data]))
      @category.updated_by = current_user
    end
  end

  public
  def index
    @categories = Category.all

    respond_to do |format|
      format.html{ head :method_not_allowed }
      format.xml{ render :xml => @categories.to_xml }
      format.json{ render :json => {:data => @categories}  }
    end
  end
  
  def create
    respond_to do |format|
      format.html{ head :method_not_allowed }

      if @category.save
        format.xml{ 
          headers['Location'] = category_url(@category)
          render :xml => @category.to_xml, :status => :created 
        }
        format.json{ render :json => {:success => true} }
      else
        format.json{ 
          render :json => { :success => false, :errors => @category.errors }
        }
      end

    end
  end
  
  def update
    respond_to do |format|
      format.html { head :method_not_allowed }

      if @category.update_attributes(params[:category] || ActiveSupport::JSON.decode(params[:data]) )
        format.json{ render :json => {:success => true} } 
      else
        format.json{ 
          render :json => {:success => false, :errors => @category.errors}
        }
      end
    end
  end
  
  def destroy
    respond_to do |format|
      format.html { head :method_not_allowed }

      if @category.destroy
        format.json{ render :json => {:success => true} } 
      else
        format.json{ 
          render :json => {:success => false, :errors => @category.errors}
        }
      end
    end
  end
end
