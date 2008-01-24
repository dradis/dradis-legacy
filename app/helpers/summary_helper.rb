module SummaryHelper
  def link_for_action(title, action, opt={}, update_note=false, confirm=false)
    default = { 
	       :action => action, 
	       :id => @note.id, 
	       :parent_type => @parent_type, 
	       :parent_id => @parent_id, 
	       :position => @position
	      }

    if update_note
      if confirm
        link_to_remote( title, { :url => default.merge(opt), :update => "note_#{@note.id}", :confirm => 'Sure?' } )
      else
        link_to_remote( title, { :url => default.merge(opt), :update => "note_#{@note.id}" } )
      end
    else
      if confirm
        link_to_remote( title, { :url => default.merge(opt), :confirm => 'Sure?'} )
      else
        link_to_remote( title, :url => default.merge(opt) )
      end
    end
  end

  def link_bar
    links = [link_for_action( 'remove', :del, {}, false, true )]
    
    if @view == 'edit'
      links.unshift( link_for_action( 'back', :show, {:view => @previous}, true ) )
    else
      links.unshift( link_for_action( 'edit', :show, {:view => 'edit', :previous => @view }, true ) )
      if @view == 'full'
        links.unshift( link_for_action( 'back', :show, {:view => 'short'}, true ) )
      else
        if @cropped
          links.unshift( link_for_action( 'details', :show, { :view => 'full'}, true ) )
        end
      end
    end

    links.collect do |l| " [#{l}]" end.join
  end
end
