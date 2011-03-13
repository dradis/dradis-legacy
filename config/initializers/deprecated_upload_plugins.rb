# Starting with Dradis 2.7 the UploadController will pass a string with the path
# of the uploaded file instead of an Attachment object.
Plugins::Upload::included_modules.each do |plugin|
  if plugin::Meta::VERSION::MINOR < 7
    warn "[DEPRECATION] review your #{plugin}::import() method to ensure it expects " + 
      "a String in the :file parameter instead of an Attachment object (calls to " +
      "`fullpath` on a String object will fail. If the plugin does expect a string " +
      "please bump its version number to 2.7.0 in " +
      Rails.root.join('vendor','plugins', plugin.to_s.underscore, 'lib', plugin.to_s.underscore, 'meta.rb').to_s + 
      " to avoid this warning."
  end
end
