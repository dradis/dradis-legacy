=begin
**
** attachment.rb
** 7 March 2009
**
** Desc:
** This class in an abstraction layer to the attachments folder. It allows
** access to the folder content in a way that mimics the working of ActiveRecord
**
** The Attachment class inherits from the ruby core File class
**
** License:
**   See LICENSE.txt for copyright and licensing information.
**
=end


# Folder structure
# The attachement folder structure example:
# AttachmentPWD
#    |
#    - 1     - this directory level represents the nodes, folder name = node id
#    |   |
#    |   - 3.image.gif
#    |   - 4.another_image.gif
#    |
#    - 2
#        |
#        - 1.icon.gif
#        - 2.another_icon.gif
#
# General usage:
# attachment = Attachment.new("images/my_image.gif", :node_id => 1)
# This will create an instance of an attachment that belongs to node with ID = 0
# Nothing has bee saved yet
#
# attachment.save
# This will save the attachment in the attachment directory structure
#
# You can inspect the saved instance:
#   attachment.node_id
#   attachment.id
#   attachment.filename
#   attachment.fullpath
#
# attachments = Attachment.find(:all)
# Creates an array instance that contains all the attachments
#
# Attachment.find(:all, :conditions => {:node_id => 1})
# Creates an array instance that contains all the attachments for node with ID=1
#
# Attachment.find('test.gif', :conditions => {:node_id => 1})
# Retrieves the test.gif image that is associated with node 1

class Attachment < File

  require 'fileutils'
  # Set the path to the attachment storage
  AttachmentPwd = "#{RAILS_ROOT}/attachments/"
  FileUtils.mkdir(File.dirname(AttachmentPwd)) unless File.exists?(File.dirname(AttachmentPwd))

  attr_accessor :filename, :node_id, :tempfile
  attr_reader :id

  # Initializes the attachment instance 
  def initialize(*args)
    options = args.extract_options!
    @filename = options[:filename]
    @node_id = options[:node_id]
    @id = options[:id]
    @tempfile = args[0] || options[:tempfile]

    if File.exists?(fullpath) && File.file?(fullpath)
      super(fullpath, 'r+')
      @initialfile = fullpath.clone
    elsif @tempfile && File.exists?(@tempfile)
      super(@tempfile, 'r+')
    elsif @tempfile && File.basename(@tempfile) != ''
      super("#{RAILS_ROOT}/tmp/" + File.basename(@tempfile), 'w+')
      @initialfile = "#{RAILS_ROOT}/tmp/" + File.basename(@tempfile)
    else
      raise "No physical file available"
    end

  end

  # Closes the current file handle, this writes the content to the file system
  def save
    if File.exists?(fullpath) && File.file?(fullpath)
      self.close
    else
      raise "Node with ID=#{@node_id} does not exist" unless @node_id && Node.exists?(@node_id)
      self.rewind
      file_content = self.read
      @id = Attachment.find(:all).last ? (Attachment.find(:all).last.id.to_i + 1) : 1
      @filename ||= File.basename(@tempfile)
      FileUtils.mkdir(File.dirname(fullpath)) unless File.exists?(File.dirname(fullpath))
      file_handle = File.new(fullpath, 'w')
      file_handle << file_content
      file_handle.close
      FileUtils.rm(@initialfile) if @initialfile && @initialfile != fullpath
      @initialfile = fullpath.clone
    end
  end

  # Return the attachment instance(s) based on the find parameters
  def self.find(*args)
    options = args.extract_options!
    dir = Dir.new(AttachmentPwd)

    # makes the find request and stores it to resources
    return_value = case args.first
    when :all, :first, :last
      attachments = []
      if options[:conditions] && options[:conditions][:node_id]
        node_id = options[:conditions][:node_id].to_s
        raise "Node with ID=#{node_id} does not exist" unless Node.exists?(node_id)
        node_dir = Dir.new(AttachmentPwd + node_id)
        node_dir.each do |attachment|
          next unless (attachment =~ /^(\d+)\.(.+)$/) == 0
          attachments << Attachment.new(:filename => $2, :id => $1.to_i, :node_id => node_id.to_i)
        end
      else
        dir.each do |node|
          next unless node =~ /^\d*$/
          node_dir = Dir.new(AttachmentPwd + node)
          node_dir.each do |attachment|
            next unless (attachment =~ /^(\d+)\.(.+)$/) == 0
            attachments << Attachment.new(:filename => $2, :id => $1.to_i, :node_id => node.to_i)
          end
        end
        attachments.sort! {|a,b| a.id <=> b.id }
      end

      # return based on the request arguments
      case args.first
      when :first
        attachments.first
      when :last
        attachments.last
      else
        attachments
      end
    else
      # in this routine we find the attachment by file name and node id
      filename = args.first
      attachments = []
      raise "You need to supply a node id in the condition parameter" unless options[:conditions][:node_id]
      node_id = options[:conditions][:node_id].to_s
      raise "Node with ID=#{node_id} does not exist" unless Node.exists?(node_id)
      node_dir = Dir.new(AttachmentPwd + node_id)
      node_dir.each do |attachment|
        next unless ((attachment =~ /^(\d+)\.(.+)$/) == 0 && $2 == filename)
        attachments << Attachment.new(:filename => $2, :id => $1.to_i, :node_id => node_id.to_i)
      end
      attachments.first
    end
    return return_value
  end

  # Class method that returns the path to the attachment storage
  def self.pwd
    AttachmentPwd
  end

  # Retruns the full path of an attachment on the file system
  def fullpath
    AttachmentPwd + @node_id.to_s + "/" + @id.to_s + "." + @filename.to_s
  end

end