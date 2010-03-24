# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_dry-run_session',
  :secret      => 'c6e1530a6ecedf5d2bb645d35e65b5f1f04ac595b9274193fa819101d058c6cbb3d137c0b1997bea4e6f367eae6d56fc861a921f705252530b0fb788c86595b5'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
