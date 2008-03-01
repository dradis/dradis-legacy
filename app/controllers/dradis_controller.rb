#require 'transactions'

require 'error'

class DradisController < ApplicationController
  #session :disabled => true
  
  wsdl_service_name 'Dradis'

  #---------------------------------------------- ticketing system
  def clear_expired_tickets
    expired = Ticket.find(:all, :conditions => ['valid_until <= ?', DateTime.now.to_s] )
    if expired.size > 0
      expired.each do |ticket|
        ticket.destroy
      end
    end
  end

  def requestticket()
    # clear time outs
    clear_expired_tickets
    
    out = SOAPResponse.new(Dradis::Error::UNKNOWN)
    
    chars = ('a'..'z').to_a + ('1'..'9').to_a + ('A'..'Z').to_a
    value = Array.new(8, '').collect{chars[rand(chars.size)]}.join
    
    # check if there is any valid ticket left. If it is, abort. Otherwise,
    # create and save a new ticket.
    Ticket.transaction do
      t = Ticket.find(:first)
      if (t != nil)
        out = SOAPResponse.new(Dradis::Error::UPDATE_IN_PROGRESS)
      else
        # create new ticket
        t = Ticket.new(:ip=>request.env['REMOTE_ADDR'], :valid_until=>DateTime.now + 1.0/24/60, :value => value)
        t.save
        out = TicketResponse.new(value)
      end
      
    end
    
    return out    
  end

  def valid_ticket? (ticket)
    clear_expired_tickets
    
    @t = Ticket.find(:first, :conditions => {
      :value => ticket,
      :ip => request.env['REMOTE_ADDR']})

    @t == nil ? false : true      
  end

  #---------------------------------------------- /ticketing system
  
  
  #---------------------------------------------- hosts
  def add_host(req)
    return SOAPResponse.new(Dradis::Error::NO_TICKET) unless valid_ticket? req.ticket
  
    out = SOAPResponse.new(Dradis::Error::UNKNOWN)
    if req.address == nil
      out = SOAPResponse.new(Dradis::Error::PARAMETER_MISSING)
    else
      Host.transaction do
        Host.new(:address => req.address).save!
        Configuration.increment_revision
      end 
      out = SOAPResponse.new( Dradis::Error::SUCCESS )
    end
    @t.destroy
    return out
  end
  def del_host(req)
    return SOAPResponse.new(Dradis::Error::NO_TICKET) unless valid_ticket? req.ticket
  
    out = SOAPResponse.new(Dradis::Error::UNKNOWN)
    if req.id == nil
      out = SOAPResponse.new(Dradis::Error::PARAMETER_MISSING)
    else
      Host.transaction do
        Host.find_by_id(req.id).destroy
        Configuration.increment_revision
      end 
      out = SOAPResponse.new( Dradis::Error::SUCCESS )
    end
    @t.destroy
    return out
  end
  #---------------------------------------------- /hosts
  
  #---------------------------------------------- protocols
  def add_protocol(req)
    return SOAPResponse.new(Dradis::Error::NO_TICKET) unless valid_ticket? req.ticket
  
    out = SOAPResponse.new(Dradis::Error::UNKNOWN)
    if req.name == nil
      out = SOAPResponse.new(Dradis::Error::PARAMETER_MISSING)
    else
      Protocol.transaction do
        Protocol.new(:name => req.name).save!
        Configuration.increment_revision
      end 
      out = SOAPResponse.new( Dradis::Error::SUCCESS )
    end
    @t.destroy
    return out    
  end
  def del_protocol(req)
    return SOAPResponse.new(Dradis::Error::NO_TICKET) unless valid_ticket? req.ticket
  
    out = SOAPResponse.new(Dradis::Error::UNKNOWN)
    if req.name == nil
      out = SOAPResponse.new(Dradis::Error::PARAMETER_MISSING)
    else
      Protocol.transaction do
        Protocol.find_by_name(req.name).destroy
        Configuration.increment_revision
      end 
      out = SOAPResponse.new( Dradis::Error::SUCCESS )
    end
    @t.destroy
    return out    
  end
  def show_protocols
    list = []
    Protocol.find(:all).collect do |p| list << p.name end
    return list
  end
  
  #---------------------------------------------- /protocols
  
  #---------------------------------------------- services
  def add_service(req)
    return SOAPResponse.new(Dradis::Error::NO_TICKET) unless valid_ticket? req.ticket
  
    out = SOAPResponse.new(Dradis::Error::UNKNOWN)
    if req.host == nil || req.port == nil || req.protocol == nil || req.name == nil
      out = SOAPResponse.new(Dradis::Error::PARAMETER_MISSING)
    else
     
      host = Host.find(:first, :conditions=>{:address=>req.host})
      prot = Protocol.find(:first, :conditions=>{:name=>req.protocol})

      Service.transaction do
        Service.new(
          :host => host, 
          :protocol => prot, 
          :name => req.name, 
          :port => req.port).save!
        Configuration.increment_revision
      end 
      out = SOAPResponse.new( Dradis::Error::SUCCESS )
    end
    @t.destroy
    return out
  end  
  def del_service(req)
    return SOAPResponse.new(Dradis::Error::NO_TICKET) unless valid_ticket? req.ticket
  
    out = SOAPResponse.new(Dradis::Error::UNKNOWN)
    if req.id == nil
      out = SOAPResponse.new(Dradis::Error::PARAMETER_MISSING)
    else
      Service.transaction do
        Service.find_by_id(req.id).destroy
        Configuration.increment_revision
      end 
      out = SOAPResponse.new( Dradis::Error::SUCCESS )
    end
    @t.destroy
    return out    
  end  
  #---------------------------------------------- /services
  
  #---------------------------------------------- notes
  def add_note(req)
    return SOAPResponse.new(Dradis::Error::NO_TICKET) unless valid_ticket? req.ticket
  
    out = SOAPResponse.new(Dradis::Error::UNKNOWN)
    if req.annotatable_type == nil || req.annotatable_id == nil || req.author == nil || req.category == nil || req.text == nil
      out = SOAPResponse.new(Dradis::Error::PARAMETER_MISSING)
    else
      category = Category.find(:first, :conditions=>{:name=>req.category})
      
      #TODO: something cleaner is needed for the annotatable
      case req.annotatable_type
        when 'Host'
          parent = Host.find(:first, :conditions=>{:id=>req.annotatable_id})
        when 'Service'
          parent = Service.find(:first, :conditions=>{:id=>req.annotatable_id})
      end
      if parent == nil
       out = SOAPResponse.new(Dradis::Error::PARAMETER_MISSING)
      else
        Note.transaction do
          Note.new(
            :author => req.author,
            :text => req.text,
            :category => category,
            :annotatable => parent
            ).save!
          Configuration.increment_revision
        end 
        out = SOAPResponse.new( Dradis::Error::SUCCESS )
      end
    end
    @t.destroy
    return out
  end  
  def edit_note(req)
    return SOAPResponse.new(Dradis::Error::NO_TICKET) unless valid_ticket? req.ticket
  
    out = SOAPResponse.new(Dradis::Error::UNKNOWN)
    if req.uid == nil || req.author == nil || req.category == nil || req.text == nil
      out = SOAPResponse.new(Dradis::Error::PARAMETER_MISSING)
    else
      note = Note.find(req.uid)
      if note == nil
        out = SOAPResponse.new(Dradis::Error::PARAMETER_MISSING)
      else
        category = Category.find(:first, :conditions=>{:name=>req.category})
        
        note.author = req.author
        note.text = req.text
        note.category = category
          
        Note.transaction do
          note.save!
          Configuration.increment_revision
        end 
        out = SOAPResponse.new( Dradis::Error::SUCCESS )
      end
    end
    @t.destroy
    return out
  end    
  
  #---------------------------------------------- /notes

  #---------------------------------------------- categories     
  
  def add_category(req)
    return SOAPResponse.new(Dradis::Error::NO_TICKET) unless valid_ticket? req.ticket

    out = SOAPResponse.new(Dradis::Error::UNKNOWN)
    if req.name == nil
      out = SOAPResponse.new(Dradis::Error::PARAMETER_MISSING)
    else
      Category.transaction do
        Category.new(:name => req.name).save!
        Configuration.increment_revision
      end 
      out = SOAPResponse.new( Dradis::Error::SUCCESS )
    end
    @t.destroy
    return out    
  end
  def del_category(req)
    return SOAPResponse.new(Dradis::Error::NO_TICKET) unless valid_ticket? req.ticket
  
    out = SOAPResponse.new(Dradis::Error::UNKNOWN)
    if req.id == nil
      out = SOAPResponse.new(Dradis::Error::PARAMETER_MISSING)
    else
      Category.transaction do
        Category.find_by_name(req.name).destroy
        Configuration.increment_revision
      end 
      out = SOAPResponse.new( Dradis::Error::SUCCESS )
    end
    @t.destroy
    return out
  end
  def show_categories
    list = []
    Category.find(:all).collect do |c| list << c.name end
    return list
  end
  
  #---------------------------------------------- /categories
  
  #---------------------------------------------- other stuff  
  def refresh()
    KnowledgeBaseResponse.new(
      :revision=>Configuration.find(:first, :conditions=>{ :name=>'revision' }).value.to_i, 
      :hosts=>Host.find(:all,:order=>:address).collect! do |h| SOAPHost.from_host h end,
      :categories => Category.find(:all,:order=>:name).collect! do |c| SOAPCategory.from_category c end,
      :protocols => Protocol.find(:all,:order=>:name).collect! do |p| SOAPProtocol.from_protocol p end
      )
  end
  
  def changed(updatenum)
    rev = Configuration.find(:first, :conditions=>{ :name=>'revision' })
    rev = Configuration.new(:name=>'revision', :value=>0).save if rev == nil
    rev.value.to_i > updatenum
  end
  #---------------------------------------------- /other stuff  
end
