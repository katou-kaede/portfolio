set :environment, "development"
set :output, "log/cron.log"

# every 1.day, at: '12:00 pm' do
every 1.minute do
  rake "event_notifier:send_notifications", environment: "development"
  # runner "EventNotifier.send_line_notifications", environment: "development"
end
