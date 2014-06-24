# Dradis::Frontend::WardenStrategy
#
# Shared password authentication strategy for Warden.
#
# See:
#   https://github.com/hassox/warden
#
module Dradis
  module Frontend
    class WardenStrategy < ::Warden::Strategies::Base

      # This strategy should be applied when we've got either of these fields,
      # if not both are present, we'll error in the authenticate! stage though.
      def valid?
        params['username'] || params['password']
      end

      def authenticate!
        username = params.fetch('username', nil)
        password = params.fetch('password', nil)

        if not ( username.blank? || password.nil? || ::BCrypt::Password.new(Dradis::Core::Configuration.password) != password )
          success!(username)
        else
          fail 'Try again.'
        end
      end
    end
  end
end
