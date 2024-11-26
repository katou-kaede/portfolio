class LineNotificationController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [ :send_notification ]
  before_action :authenticate_request, only: [ :send_notification ]
  require "net/http"
  require "uri"

  def send_notification
    users = User.joins(participants: :event)
                .where(events: { date: Time.zone.tomorrow.all_day })
                .distinct

    if users.any?
      users.each do |user|
        events = Event.joins(:participants)
                      .where(participants: { user_id: user.id })
                      .where("date >= ? AND date <= ?", Time.zone.tomorrow.beginning_of_day, Time.zone.tomorrow.end_of_day)

        if events.any?
          events.each do |event|
            send_line_notification(event, user.uid) if user.uid.present?
          end
        end
      end
    end

    head :ok # 処理が正常に終わったらHTTPステータス200を返す
  end

  private

  def send_line_notification(event, recipient_uid)
    uri = URI.parse("https://api.line.me/v2/bot/message/push")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path, {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['LINE_CHANNEL_TOKEN']}"
    })

    event_url = Rails.application.routes.url_helpers.event_url(event, host: "https://event-station.onrender.com")

    message = {
      to: recipient_uid,
      messages: [
        {
          type: "text",
          text: "明日開催予定のイベント「#{event.name}」に参加予定です！お忘れなく。\n#{event_url}"
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
