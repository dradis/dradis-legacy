class JsonController < ApplicationController
  before_filter :login_required

  def nodes
    parent_id = params[:node] == 'root-node' ? nil : params[:node].to_i
    nodes = Node.find(:all, :conditions => {:parent_id => parent_id})
    render :text => nodes.to_json
  end

  def note_create  
    # TODO: validation!!
    note = Note.new( 
      :text => params[:text],
      :author => params[:author],
      :node_id => params[:node],
      :category_id => params[:category] 
    )
    note.save
    render :text => note.id
  end

  def note_update
    begin
      note = Note.find(params[:id].to_i)
   rescue
      render :text => 'note not found' 
      return
    end

    note.update_attributes({
      :text => params[:text],
      :author => params[:author],
      :node_id => params[:node],
      :category_id => params[:category] 
    })
    note.save
    render :text => 'noerror'
  end

  def note_delete
    begin
      note = Note.find(params[:id].to_i)
      note.destroy
      render :text => 'noerror'
    rescue
      render :text => 'note not found'
      return
    end
  end



  def node_create
    node = Node.new({
      :label => params[:label],
      :parent_id => params[:parent_id]
    })
    node.save
    render :text => node.id
  end
  def node_update
    begin
      node = Node.find(params[:id].to_i)
    rescue
      render :text => 'node not found'
      return
    end
    node.update_attributes({
      :label => params[:label],
      :parent_id => params[:parent_id]
    })
    node.save
    render :text => 'noerror'
  end

  def node_delete
    begin
      node = Node.find(params[:id].to_i)
      node.destroy
      render :text => 'noerror'
    rescue
      render :text => 'node not found'
      return
    end
  end

  def category_create
    category = Category.new(:name => params[:name])
    category.save
    render :text => category.id
  end
  def category_update
    begin
      category = Category.find(params[:id].to_i)
    rescue
      render :text => 'category not found'
      return
    end
    category.update_attributes({ :name => params[:name] })
    category.save
    render :text => 'noerror'
  end
  def category_delete
    begin
      cat_id = params[:id].to_i
      p cat_id
      if (cat_id == 1)
        render :text => 'Default category can\'t be removed.'
        return
      end
      # TODO: this should be done at model level
      associated_notes = Category.count_by_sql( "SELECT COUNT(*) FROM notes where \"category_id\" = #{cat_id}" )
      p associated_notes
      if (associated_notes > 0)
        render :text => 'There are notes associated with this category!'
        return
      end
      category = Category.find(cat_id)
      category.destroy
      render :text => 'noerror'
    rescue e
      p e
      render :text => 'category not found'
      return
    end
  end
end
