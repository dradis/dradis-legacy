# Be sure to restart your server when you modify this file.

# Version of your assets, change this if you want to expire all your assets.
Rails.application.config.assets.version = '1.0'

# Precompile additional assets.
# application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
Rails.application.config.assets.precompile += %w( banner.css dradis3.js dradis3.css OpenSans-Regular.eot OpenSans-Regular.woff OpenSans-Regular.ttf OpenSans-Regular.svg jquery.textile.loading.gif )
