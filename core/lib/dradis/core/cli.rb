require 'rails/generators'
require 'rails/generators/rails/app/app_generator'

require 'thor'
require 'thor/group'

module Dradis
  module Core
    class CLI < Thor
      desc 'new [PATH]', 'create a new Dradis Framework forlder in the specified directory'
      method_option :path, :type => :string, :desc => 'the folder in which a Dradis Framework instance will be created', :default => '.'
      def new(application_name = 'dradisfw')
        template_path = File.expand_path('../../../templates/installer.rb', __FILE__)

        # Run the Rails app generator:
        #   * We define our own app template to customize the generated app
        #   * No need to worry about testing frameworks
        #   * Ask Rails not to run `bundle install`, we'll run it from our template
        result = Rails::Generators::AppGenerator.start [application_name, '-m', template_path, '--skip-test-unit', '--skip-bundle'] | ARGV
        if result && result.include?('Gemfile')
          note = ["\n=== ACTION REQUIRED ==="]
          note << "Now you can launch your Dradis webserver using:"
          note << "\ncd #{application_name}"
          note << "rails server"
          note << "\nThis will launch the built-in webserver at port 3004."
          note << "You can now see Dradis running in your browser at https://localhost:3004/"
          puts note
        end
      end

      desc 'version', 'display Dradis Framework version'
      def version
      	puts Gem.loaded_specs['dradis_core'].version
      end
    end
  end
end