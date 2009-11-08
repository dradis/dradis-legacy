# ==Description
# Stubs out a new dradis upload plugin. Pass the plugin name, either CamelCased or
# under_scored, as an argument. The plugin name will be extended with '_upload'
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
#  $ ./script/generate upload_plugin Nessus
#
#  creates a standard upload plugin:
#      vendor/plugins/nessus_upload/README
#      vendor/plugins/nessus_upload/init.rb
#      vendor/plugins/nessus_upload/install.rb
#      vendor/plugins/nessus_upload/uninstall.rb
#      vendor/plugins/nessus_upload/Rakefile
#      vendor/plugins/nessus_upload/lib/nessus_upload.rb
#      vendor/plugins/nessus_upload/test/nessus_upload_test.rb
#      vendor/plugins/nessus_upload/tasks/nessus_upload_tasks.rake
class UploadPluginGenerator < Rails::Generator::NamedBase
  attr_reader :plugin_path # :nodoc:

  def initialize(runtime_args, runtime_options = {}) # :nodoc:
    runtime_args[0] = runtime_args[0].underscore + "_upload" if runtime_args[0] && !(runtime_args[0].tableize =~ /.*_upload/)
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
      m.template 'meta.rb',       "#{plugin_path}/lib/#{file_name}/meta.rb"
      m.template 'filters.rb',    "#{plugin_path}/lib/#{file_name}/filters.rb"

      m.readme "USAGE"
    end
  end
end
