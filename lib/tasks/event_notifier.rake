namespace :event_notifier do
  desc "Send LINE notifications for tomorrow's events"
  task send_notifications: :environment do
    require 'line/bot'

    events = Event.where("date >= ? AND date <= ?", Time.zone.tomorrow.beginning_of_day, Time.zone.tomorrow.end_of_day)
    events.each do |event|
      event.participants.each do |participant|
        send_line_message(participant.user.uid, event)
      end
    end
  end

  def send_line_message(user_id, event)
    client = Line::Bot::Client.new { |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    }

    message = {
      type: 'text',
      text: "明日開催予定のイベント「#{event.name}」に参加予定です！お忘れなく。"
    }

    response = client.push_message(user_id, message)
    puts response.inspect
  end
end
