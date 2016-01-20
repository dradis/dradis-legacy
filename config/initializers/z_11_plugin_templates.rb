# Unless the DB is already migrated, do nothing
if Dradis::Core::Configuration.table_exists?
  plugin_dir = nil
  source_dir = nil
  destination_dir = nil

  basename = nil
  source_file = nil
  destination_file = nil

  # --------------------------------------------- New-style Dradis::Plugin gems

  # ------------------------------------------------------------------ 1 Export
  template_dir = Dradis::Core::Configuration.paths_templates_reports

  Dradis::Plugins::with_feature(:export).each do |plugin|
    plugin_dir = File.join(template_dir, plugin.plugin_name.to_s)
    plugin.copy_templates(to: plugin_dir)
  end


  # ------------------------------------------------------------------ 2 Upload

  template_dir = Dradis::Core::Configuration.paths_templates_plugins

  Dradis::Plugins::with_feature(:upload).each do |plugin|
    # plugin_dir = File.join(template_dir, plugin.plugin_name.to_s)
    plugin.copy_templates(to: template_dir)
  end
end