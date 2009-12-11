# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.

ActionController::Base.session = {
  :key         => '_server_session',
  :secret      => '7736b5ea69b312cf739522d19ccce037e1dc567bc9b79148f035ea674e676e4ade6754b615a138b459e4a3339837436af0c8d5faa4a42f041073c7fe63c05b29'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
