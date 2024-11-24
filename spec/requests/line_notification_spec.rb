require 'rails_helper'

RSpec.describe "LineNotifications", type: :request do
  describe "GET /send_notification" do
    it "returns http success" do
      get "/line_notification/send_notification"
      expect(response).to have_http_status(:success)
    end
  end

end
