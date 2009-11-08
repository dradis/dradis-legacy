# This class can be used to process e-mail messages sent to the Dradis server.
# It uses the ActionMailer module to parse incoming messages that it stores as
# Note objects in the back-end database.
#
# It also supports attachments (which are parsed as Attachment objects).
#
# An example <tt>.procmailrc</tt> configuration file could be:
#   LOGFILE=procmaillog
#   VERBOSE=yes
#   GEM_HOME=/usr/local/stow/rubygems/lib/site_ruby/
#   RUBYLIB=/usr/local/stow/rubygems/lib/:/usr/local/stow/rubygems/lib/site_ruby/
#   RUBY=/usr/bin/ruby
#   DRADIS_DIR=/var/data/dradis/dradis-v2.x/server/
#   HANDLER='IncomingNoteHandler.receive(STDIN.read)'
#   :0 c
#   * ^Subject:.*dradis note.*
#   | cd $DRADIS_DIR && $RUBY script/runner $HANDLER
class IncomingNoteHandler < ActionMailer::Base

  # This method is invoked by the external MTA that wants to deliver a message
  # to this Dradis instance.
  #
  # It parses the incoming e-mail message and creates a Note with its contents.
  # If the email contains attachments, they are uploaded as Attachment objects 
  # to the corresponding Node.
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
