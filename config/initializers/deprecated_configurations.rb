
# Checks for old-style plugin configuration, using YAML files rather than the
# new Configurator, and displays a deprecation warning.

module DeprecatedConfigurationDetector

  def uses_deprecated_config?
    self.constants.any? { |c| c =~ /conf/i && !self.const_get(c).is_a?(Class) }
  end

end

unless %w{ rake thor }.include?(File.basename($0))
  (Plugins::Export.included_modules +
      Plugins::Import.included_modules +
      Plugins::Upload.included_modules).sort_by(&:to_s).each do |plugin|
    plugin.send(:extend, DeprecatedConfigurationDetector) unless plugin.respond_to?(:uses_deprecated_config?)

    puts "DEPRECATION WARNING: the #{plugin} plugin seems to load configuration information without using " +
          "Core::Configurator, the preferred method since dradis v2.7.0. You should update the plugin " +
          "so it can be configured using the Configuration Manager interface." if plugin.uses_deprecated_config?
  end
end
