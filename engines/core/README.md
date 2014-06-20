# Dradis::Core library

This gem contains the core models that the Dradis Framework relies on.

If you are a Dradis plugin developer you'll want to add this gem to your plugin's .gemspec like this:

```ruby
Gem::Specification.new do |s|
  //...
  s.add_dependency 'dradis_core', '~> 3.0'
  //...
end
```