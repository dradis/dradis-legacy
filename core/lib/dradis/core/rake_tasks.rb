require 'rake'
require 'rake/tasklib'

module Dradis
  module Core
    class RakeTasks < ::Rake::TaskLib
      include ::Rake::DSL if defined?(::Rake::DSL)

      def initialize(*args)
        namespace :dradis do
          namespace :core do
            desc "Generates a dummy app for testing"
            task :test_app do
              puts "done."
            end
          end
        end
      end
    end
  end
end