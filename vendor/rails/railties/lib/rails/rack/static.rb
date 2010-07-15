require 'rack/utils'

module Rails
  module Rack
    class Static
      FILE_METHODS = %w(GET HEAD).freeze

      def initialize(app)
        @app = app
        @file_server = ::Rack::File.new(File.join(RAILS_ROOT, "public"))
        @cache_duration = 1
        @duration_in_seconds = self.duration_in_seconds
        @duration_in_words    = self.duration_in_words
      end

      def call(env)
        path        = env['PATH_INFO'].chomp('/')
        method      = env['REQUEST_METHOD']

        if FILE_METHODS.include?(method)
          if file_exist?(path)
            status, headers, body = @file_server.call(env)
            headers['Cache-Control'] ="max-age=#{@duration_in_seconds}, public"
            headers['Expires'] = @duration_in_words
            headers.delete 'Etag'
            headers.delete 'Pragma'
            headers.delete 'Last-Modified'
            return [status, headers, body]
          else
            cached_path = directory_exist?(path) ? "#{path}/index" : path
            cached_path += ::ActionController::Base.page_cache_extension

            if file_exist?(cached_path)
              env['PATH_INFO'] = cached_path
              return @file_server.call(env)
            end
          end
        end

        @app.call(env)
      end

      def duration_in_words
        (Time.now + self.duration_in_seconds).strftime '%a, %d %b %Y %H:%M:%S GMT'
      end

      def duration_in_seconds
        60 * 60 * 24 * 365 * @cache_duration
      end

      private
        def file_exist?(path)
          full_path = File.join(@file_server.root, ::Rack::Utils.unescape(path))
          File.file?(full_path) && File.readable?(full_path)
        end

        def directory_exist?(path)
          full_path = File.join(@file_server.root, ::Rack::Utils.unescape(path))
          File.directory?(full_path) && File.readable?(full_path)
        end

    end
  end
end
