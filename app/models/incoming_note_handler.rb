class IncomingNoteHandler < ActionMailer::Base
  def receive(email)
    node = Node.find_or_create_by_label( Configuration.find_by_name('emails_node').value )
    category = Category.find_or_create_by_name( 'MagicMailer' )
    note = Note.new( :author => 'MagicMailer', :category => category , :node => node )

    note.text = '#[Email Headers]#'
    note.text << "\n"
    note.text << email.from[0]
    note.text << "\n\n"
    note.text << '#[Body]#'
    note.text << "\n"
    note.text << email.body

    note.save

    if email.has_attachments?
      email.attachments.each do |attachment|
        a = Attachment.new( attachment.original_filename, :node_id => node.id)
        a << attachment.read
        a.save
      end
    end
  end
end
