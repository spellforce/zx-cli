# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

ActiveRecord::ConnectionAdapters::Mysql2Adapter.emulate_booleans = false
