set :environment, "production"
set :output, "log/cron.log"

# every 1.day, at: '12:00 pm' do
every 1.minute do
  runner "EventNotifier.send_line_notifications"
end
