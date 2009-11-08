# ==Description
# Stubs out a new dradis export plugin. Pass the plugin name, either CamelCased or
# under_scored, as an argument. The plugin name will be extended with '_export'
# if this is not part of the plugin name argument.
#
# This creates a plugin in <tt>vendor/plugins/</tt> including an <tt>init.rb</tt> 
# and +README+ as well as standard <tt>lib/</tt>, <tt>task/</tt>, and 
# <tt>test/</tt> directories.
#
# ==Note
# The basic structure is exactly the same as a standard Rails plugin. With a the
# unneeded files and code removed and a bit of customisation to fit the dradis
# upload pugin requirements.
#
# ==Example
# This class is never instantiated programatically, it is rather used through 
# the <tt>./script/generate</tt> script:
#
#   $ ./script/generate export_plugin Word`
#
#   creates a standard export plugin:
#       vendor/plugins/word_export/README
#       vendor/plugins/word_export/init.rb
#       vendor/plugins/word_export/install.rb
#       vendor/plugins/word_export/lib/word_export.rb
#       vendor/plugins/word_export/test/word_export_test.rb
#       vendor/plugins/word_export/tasks/word_export_tasks.rake
class ExportPluginGenerator < Rails::Generator::NamedBase
  attr_reader :plugin_path # :nodoc:

  def initialize(runtime_args, runtime_options = {}) # :nodoc:
    runtime_args[0] = runtime_args[0].underscore + "_export" if runtime_args[0] && !(runtime_args[0].tableize =~ /.*_export/)
    super
    @plugin_path = "vendor/plugins/#{file_name}"
  end

  def manifest # :nodoc:
    record do |m|
      # Check for class naming collisions.
      m.class_collisions class_path, class_name

      m.directory "#{plugin_path}/lib"
      m.directory "#{plugin_path}/lib/#{file_name}"
      m.directory "#{plugin_path}/tasks"
      m.directory "#{plugin_path}/test"

      m.template 'README',        "#{plugin_path}/README"
      m.template 'MIT-LICENSE',   "#{plugin_path}/MIT-LICENSE"
      m.template 'Rakefile',      "#{plugin_path}/Rakefile"
      m.template 'init.rb',       "#{plugin_path}/init.rb"
      m.template 'install.rb',    "#{plugin_path}/install.rb"
      m.template 'uninstall.rb',  "#{plugin_path}/uninstall.rb"
      m.template 'plugin.rb',     "#{plugin_path}/lib/#{file_name}.rb"
      m.template 'tasks.rake',    "#{plugin_path}/tasks/#{file_name}_tasks.rake"
      m.template 'unit_test.rb',  "#{plugin_path}/test/#{file_name}_test.rb"
      m.template 'actions.rb',    "#{plugin_path}/lib/#{file_name}/actions.rb"
      m.template 'version.rb',    "#{plugin_path}/lib/#{file_name}/version.rb"
      m.template 'USAGE',         "#{plugin_path}/USAGE"

      m.readme "USAGE"

    end
  end
end
