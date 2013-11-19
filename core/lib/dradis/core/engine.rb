module Dradis
  module Core
    class Engine < ::Rails::Engine
      isolate_namespace Dradis
      engine_name 'dradis'

      # This ensure that new models are generated using :rspec and :factory_girl
      config.generators do |g|
        g.test_framework      :rspec,        :fixture => false
        g.fixture_replacement :factory_girl, :dir => 'spec/factories'
        g.assets false
        g.helper false
      end

      initializer 'clear_transient_data' do |app|
        # # It is fair to assume that once the server goes down, past activity is no
        # # longer useful and can be disposed of.
        # Rails.logger.info "Clearing old Logs and Feeds..."
        # 
        # Log.destroy_all if Log.table_exists?
        # Feed.destroy_all if Feed.table_exists?
      end
      initializer 'extjs_json' do
        ActiveRecord::Base.include_root_in_json = false
      end
    end
  end
end