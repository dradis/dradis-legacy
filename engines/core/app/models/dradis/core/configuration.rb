# This class is used to store configuration options in the back-end database.
# Each Configuraiton object has a :name and a :value. Some configuration 
# parameters can be accessed through the helper methods provided in this class.
module Dradis
  module Core
    class Configuration < ActiveRecord::Base
      self.table_name = 'dradis_configurations'

      # -- Relationships --------------------------------------------------------

      # -- Callbacks ------------------------------------------------------------

      # -- Validations ----------------------------------------------------------
      validates :name,
        presence: true,
        uniqueness: true

      validates :value,
        presence: true

      # -- Scopes ---------------------------------------------------------------

      # -- Class Methods --------------------------------------------------------
      def self.exists?(*attrs)
        self.table_exists? && super(*attrs)
      end

      # Retrieve the value of the configuration setting whose name is 'revision'
      def self.revision
        Configuration.find_or_create_by(name: 'admin:revision') do |c|
          c.value = '0'
        end.value
      end
  
      # Helper method to retrieve the value of the 'revision' setting and increment
      # it by one.
      def self.increment_revision
        revision = Configuration.create_with(value: 0).find_or_create_by(name: 'admin:revision')
        revision.value = revision.value.to_i + 1
        revision.save
      end
  
      # Retrieves the current password (stored in the 'password' setting)
      def self.password
        Configuration.exists?(name: 'password') ? Configuration.find_by_name('password').value : nil
      end


      # --------------------------------------------------------------- admin:paths
      def Configuration.paths_templates_plugins
        Configuration.find_or_create_by(name: 'admin:paths:templates:plugins') do |c|
          c.value = Rails.root.join('templates', 'plugins').to_s
        end.value
      end

      def Configuration.paths_templates_reports
        Configuration.find_or_create_by(name: 'admin:paths:templates:reports') do |c|
          c.value = Rails.root.join('templates', 'reports').to_s
        end.value
      end


      # ------------------------------------------------------------- admin:plugins

      # This setting is used by the plugins as the root of all the content the add.
      def self.plugin_parent_node
        Configuration.find_or_create_by(name: 'admin:plugins:parent_node') do |c|
          c.value = 'plugin.output'
        end.value
      end

      # Retrieve the name of the Node used to associate file uploads.
      def self.plugin_uploads_node
        Configuration.find_or_create_by(name: 'admin:plugins:uploads_node') do |c|
          c.value = 'Uploaded files'
        end.value
      end

      # -- Instance Methods -----------------------------------------------------

    end
  end
end