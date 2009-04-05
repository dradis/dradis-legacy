class ImportPluginGenerator < Rails::Generator::NamedBase
  attr_reader :plugin_path

  def initialize(runtime_args, runtime_options = {})
    runtime_args[0] = runtime_args[0].tableize + "_export" if !(runtime_args[0].tableize =~ /.*_import/)
    super
    @plugin_path = "vendor/plugins/#{file_name}"
  end

  def manifest
    record do |m|

      m.directory "#{plugin_path}/lib"
      m.directory "#{plugin_path}/lib/#{file_name}"
      m.directory "#{plugin_path}/tasks"
      m.directory "#{plugin_path}/test"

    end
  end
end
