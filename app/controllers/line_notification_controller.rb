class LineNotificationController < ApplicationController
  before_action :authenticate_user!
  require "net/http"
  require "uri"

  def send_notification
    events = Event.viewable_by(current_user)
                  .joins(:participants)
                  .where(participants: { user_id: current_user.id })
                  .where("date >= ? AND date <= ?", Time.zone.tomorrow.beginning_of_day, Time.zone.tomorrow.end_of_day)

    if events.any?
      events.each do |event|
        send_line_notification(event)
      end
    end

    head :ok # 処理が正常に終わったらHTTPステータス200を返す
  end

  private

  def send_line_notification(event)
    if current_user.uid.blank?
      return # UIDがない場合は通知を送らない
    end

    uri = URI.parse("https://api.line.me/v2/bot/message/push")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['LINE_CHANNEL_TOKEN']}"
    })

    message = {
      to: current_user.uid,
      messages: [
        {
          type: "text",
          text: "明日開催予定のイベント「#{event.name}」に参加予定です！お忘れなく。#{event_path(event)}"
        }
      ]
    }

    request.body = message.to_json

    response = http.request(request)
  end

  def authenticate_request
    token = request.headers["Authorization"]&.split(" ")&.last
    unless token == ENV["API_TOKEN"]
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end
end
