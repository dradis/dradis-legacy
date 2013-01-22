# Kudos for the dummy app tasks to:
#   https://coderwall.com/p/743kfg
#   https://gist.github.com/4131823

require 'rails/generators'
require 'rails/generators/rails/plugin_new/plugin_new_generator'
 
module Dradis
  class DummyGenerator < Rails::Generators::PluginNewGenerator
    class_option :lib_name, type: :string, default: "dradis-newgem",
                            desc: "Name of the gem you are testing"
 
    def self.default_source_root
      Rails::Generators::PluginNewGenerator.default_source_root
    end
 
    def do_nothing
    end
 
    alias :create_root :do_nothing
    alias :create_root_files :do_nothing
    alias :create_app_files :do_nothing
    alias :create_config_files :do_nothing
    alias :create_lib_files :do_nothing
    alias :create_public_stylesheets_files :do_nothing
    alias :create_javascript_files :do_nothing
    alias :create_script_files :do_nothing
    alias :update_gemfile :do_nothing
    alias :create_test_files :do_nothing
    alias :finish_template :do_nothing
  end
end