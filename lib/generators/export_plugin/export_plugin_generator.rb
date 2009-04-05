class ExportPluginGenerator < Rails::Generator::NamedBase
  attr_reader :plugin_path

  def initialize(runtime_args, runtime_options = {})
    runtime_args[0] = runtime_args[0].underscore + "_export" if runtime_args[0] && !(runtime_args[0].tableize =~ /.*_export/)
    super
    @plugin_path = "vendor/plugins/#{file_name}"
  end

  def manifest
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

    end
  end
end
