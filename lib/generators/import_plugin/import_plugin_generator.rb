class ImportPluginGenerator < Rails::Generator::NamedBase
  attr_reader :plugin_path

  def initialize(runtime_args, runtime_options = {})
    runtime_args[0] = runtime_args[0].tableize + "_export" if !(runtime_args[0].tableize =~ /.*_import/)
    super
    @plugin_path = "vendor/plugins/#{file_name}"
  end

  def manifest
    record do |m|

    end
  end
end
