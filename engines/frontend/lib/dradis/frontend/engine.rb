module Dradis
  module Frontend
    class Engine < ::Rails::Engine
      isolate_namespace Dradis::Frontend

      initializer 'frontend.append_migrations' do |app|
        unless app.root.to_s == root.to_s
          config.paths["db/migrate"].expanded.each do |path|
            app.config.paths["db/migrate"].push(path)
          end
        end
      end

      initializer 'frontend.asset_precompile_paths' do |app|
        app.config.assets.precompile += ["dradis/frontend/manifests/*"]
      end
  end
end