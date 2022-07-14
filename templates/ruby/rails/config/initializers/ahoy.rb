class Ahoy::Store < Ahoy::DatabaseStore
end

# set to true for JavaScript tracking
Ahoy.api = true

# better user agent parsing
Ahoy.user_agent_parser = :device_detector
Ahoy.server_side_visits = :when_needed

# delete ahoy records more than 1 year
# begin
#   ActiveRecord::Base.connection.query('delete from ahoy_events where DATE(time) <= DATE(DATE_SUB(NOW(),INTERVAL 1 year));')
#   ActiveRecord::Base.connection.query('delete from ahoy_visits where DATE(started_at) <= DATE(DATE_SUB(NOW(),INTERVAL 1 year));')
# rescue => exception
#   Rails.logger.error("delete ahoy_events error");
# end
