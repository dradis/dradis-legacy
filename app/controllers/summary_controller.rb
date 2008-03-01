class SummaryController < ApplicationController

  def index
    @hosts = Host.find(:all)
    @old_revision = @new_revision = Configuration.get_revision.value.to_i
  end

  def num
    render :text => Host.find(params[:id]).notes.size
  end

  def notes
    @parent_type = params[:parent_type]
    @parent_id = params[:parent_id]
    @position = params[:position]
    @view = 'short'
    @filter = params[:filter]

    filter_by = Category.find_by_name(@filter)
    notes = eval(@parent_type).find(@parent_id).notes
    @categories = {}
    @all_categories = {}

    notes.each do |note|
      @all_categories[note.category.name] = [] unless @all_categories.has_key?(note.category.name)
      next if ((filter_by != nil) && (note.category != filter_by))
      @categories[note.category.name] = [] unless @categories.has_key?(note.category.name)
      @categories[note.category.name] << note
    end

    #render_partial 'notes'
    render :update do |page|
      page.replace_html "summary_host_#{@position}_notes", :partial => 'notes'
      page.replace_html "#{@parent_type.downcase}_note_count_#{@parent_id}", :inline => notes.size.to_s
    end
  end

  def show
    @note = Note.find(params[:id])
    @view = params.fetch(:view, 'short')
    @previous = params.fetch(:previous, @view)
    @parent_type = params[:parent_type]
    @parent_id = params[:parent_id]
    @position = params[:position]

    render_partial 'note'
  end

  def update
    @parent_type = params[:parent_type]
    @parent_id = params[:parent_id]
    @position = params[:position]
    @note = Note.find(params[:id])
    if @note.update_attributes(params[:note])
      flash[:notice] = 'Note was successfully updated.'
    end
    @view = params.fetch(:view, 'short')
    render_partial 'note'
  end


  def add
    @parent_type = params[:parent_type]
    @parent_id = params[:parent_id]
    @position = params[:position]
    parent = eval(@parent_type).find(@parent_id)

    author = params[:note][:author]
    category = Category.find(params[:note][:category_id])
    text = params[:note][:text]

    Note.transaction do
      Note.new(
        :author => author,
        :text => text,
        :category => category,
        :annotatable => parent
        ).save!
      #update_revision
      Configuration.increment_revision
    end
    notes
  end

  def del
    Note.transaction do
      Note.find(params[:id]).destroy
      #update_revision
      Configuration.increment_revision
    end
    notes
  end

  def add_service
    host_id = params[:host_id]
    host = Host.find(host_id)
    service = params[:service].split('/')  
    protocol_id = Protocol.find(:first, :conditions => ["name = ?", service[0]]).id
    Service.transaction do
      Service.new(
        :protocol_id => protocol_id,
        :port => service[1],
        :host_id => host_id
      ).save!
      Configuration.increment_revision
    end
    
    render :update do |page|
      page.replace_html "summary_host_#{host.id}_services", :partial => 'services', :locals => {:host => host}
    end
  end

  def add_host
    address = params[:address]
    Host.transaction do 
      Host.new(:address => address).save!
      Configuration.increment_revision
    end
    host = Host.find(:first, :conditions => ["address = ?", address])
    
    render :update do |page|
      page.insert_html :before, 'place_holder', :partial => 'host', :locals => {:host => host}
    end
  end
  
  def add_category
    category = params[:category]
    Category.transaction do
      Category.new(:name => category).save!
      Configuration.increment_revision
    end
    
    render :nothing => true
  end
  
  def add_protocol
    protocol = params[:protocol]
    Protocol.transaction do
      Protocol.new(:name => protocol).save!
      Configuration.increment_revision
    end
    
    render :nothing => true
  end
  
  def revision_countdown
    @old_revision = params[:revision].to_i
    @new_revision = Configuration.get_revision.value.to_i
    render :partial => 'refresher'
  end
end
