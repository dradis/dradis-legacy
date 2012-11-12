module ConfigurationsHelper

  # collects all configurations from registered configurators, including ones set
  # in the database, default values (as new Configuration objects) and ad-hoc
  # values that do not exist in the definition
  def all_configurations
    Core::Configurator.configurables.collect(&:settings).flatten.sort_by(&:name)
  end

  # collects all plugins that appear to use the old method of configuration, using
  # a yaml file
  def deprecated_configurations
    (Plugins::Export.included_modules +
      Plugins::Import.included_modules +
      Plugins::Upload.included_modules).select(&:uses_deprecated_config?).sort_by(&:to_s)
  end

end
