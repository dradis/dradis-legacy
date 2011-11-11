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
class UploadPluginGenerator < Rails::Generators::NamedBase
  source_root File.expand_path('../templates', __FILE__)

  def initialize(args, *options) # :nodoc:
    args[0] = args[0].underscore + "_upload" if args[0] && !(args[0].tableize =~ /.*_upload/)
    super

    #Set the destination root for the plugin
    self.destination_root=( File.join( Rails.root, 'vendor', 'plugins') )

    # Check for class naming collisions.
    class_collisions class_name
  end

  def generate_files # :nodoc:
    template 'README',        "#{file_name}/README"
    template 'MIT-LICENSE',   "#{file_name}/MIT-LICENSE"
    template 'Rakefile',      "#{file_name}/Rakefile"
    template 'init.rb',       "#{file_name}/init.rb"
    template 'install.rb',    "#{file_name}/install.rb"
    template 'uninstall.rb',  "#{file_name}/uninstall.rb"
    template 'plugin.rb',     "#{file_name}/lib/#{file_name}.rb"
    template 'thorfile.rb',   "#{file_name}/lib/tasks/thorfile.rb"
    template 'tasks.rake',    "#{file_name}/lib/tasks/#{file_name}_tasks.rake"
    template 'spec_helper.rb',  "#{file_name}/spec/spec_helper.rb"
    template 'plugin_spec.rb',  "#{file_name}/spec/#{file_name}_spec.rb"
    template 'meta.rb',       "#{file_name}/lib/#{file_name}/meta.rb"
    template 'filters.rb',    "#{file_name}/lib/#{file_name}/filters.rb"

    readme "USAGE"
  end
end
