require 'rails_helper'

RSpec.describe Participant, type: :model do
  let(:user) { create(:user) }
  let(:event) { create(:event) }

  context 'バリデーション' do
    it 'user_idとevent_idが必須であること' do
      participant = Participant.new(user: user, event: event)
      expect(participant).to be_valid
    end

    it 'user_idが重複しないこと（同じeventに対して同じuserが参加できないこと）' do
      create(:participant, user: user, event: event)
      duplicate_participant = Participant.new(user: user, event: event)
      expect(duplicate_participant).to be_invalid
      expect(duplicate_participant.errors[:user_id]).to include("がすでに使用されています")
    end

    it 'event_idが必須であること' do
      participant = Participant.new(user: user, event: nil)
      expect(participant).to be_invalid
      expect(participant.errors[:event_id]).to include("を入力してください")
    end

    it 'user_idが必須であること' do
      participant = Participant.new(user: nil, event: event)
      expect(participant).to be_invalid
      expect(participant.errors[:user_id]).to include("を入力してください")
    end
  end
end
