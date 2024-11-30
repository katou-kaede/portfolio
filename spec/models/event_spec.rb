require 'rails_helper'

RSpec.describe Event, type: :model do
  let (:user) { create(:user) }
  let (:event) { create(:event, user: user) }

  describe 'アソシエーション' do
    it 'Userモデルに所属していること' do
      expect(Event.reflect_on_association(:user).macro).to eq(:belongs_to)
    end

    it 'Groupモデルに所属していること（任意）' do
      expect(Event.reflect_on_association(:group).macro).to eq(:belongs_to)
      expect(Event.reflect_on_association(:group).options[:optional]).to be true
    end

    it 'Participantモデルを複数持つこと' do
      expect(Event.reflect_on_association(:participants).macro).to eq(:has_many)
    end

    it 'Userモデルを通してParticipantsを持つこと' do
      expect(Event.reflect_on_association(:users).macro).to eq(:has_many)
      expect(Event.reflect_on_association(:users).options[:through]).to eq(:participants)
    end
  end

  describe 'バリデーション' do
    it '名前がない場合バリデーションが機能するか' do
      event_without_name = build(:event, name: nil)
      expect(event_without_name).to be_invalid
      expect(event_without_name.errors[:name]).to include('を入力してください')
    end

    it 'visibility（公開範囲）が必須であり、特定の値のみ許可されること' do
      expect(event).to validate_inclusion_of(:visibility).in_array(['general', 'limited'])
    end

    it 'status（状態）が特定の値のみ許可されること' do
      expect(event).to validate_inclusion_of(:status).in_array(%w[open closed])
    end
  end

  describe 'コールバック' do
    it '作成時にホストを参加者として追加すること' do
      event = create(:event, user: user)
      expect(event.participants.exists?(user_id: user.id)).to be true
    end
  end

  describe '#hosted_by?' do
    it '指定されたユーザーがイベントのホストである場合、trueを返すこと' do
      expect(event.hosted_by?(user)).to be true
    end

    it '指定されたユーザーがイベントのホストでない場合、falseを返すこと' do
      another_user = create(:user)
      expect(event.hosted_by?(another_user)).to be false
    end
  end

  describe '#open_registration' do
    it 'ステータスを"open"に設定すること' do
      event.close_registration
      event.open_registration
      expect(event.status).to eq("open")
    end
  end

  describe '#close_registration' do
    it 'ステータスを"closed"に設定すること' do
      event.close_registration
      expect(event.status).to eq("closed")
    end
  end

  describe '#update_registration_status' do
    it 'イベントの日付が過去の場合、募集を終了すること' do
      past_event = create(:event, user: user, date: 1.day.ago)
      past_event.update_registration_status
      expect(past_event.status).to eq("closed")
    end

    it '定員に達している場合、募集を終了すること' do
      event.capacity = 1
      event.save
      create(:participant, event: event, user: create(:user))
      event.update_registration_status
      expect(event.status).to eq("closed")
    end

    it '条件が満たされている場合、募集を開始すること' do
      event.update_registration_status
      expect(event.status).to eq("open")
    end
  end

  describe '#registration_open?' do
    it 'ステータスが"closed"の場合、falseを返すこと' do
      event.close_registration
      expect(event.registration_open?).to be false
    end

    it '日付が過去の場合、falseを返すこと' do
      past_event = create(:event, user: user, date: 1.day.ago)
      expect(past_event.registration_open?).to be false
    end

    it '定員に達している場合、falseを返すこと' do
      event.capacity = 1
      event.save
      create(:participant, event: event, user: create(:user))
      expect(event.registration_open?).to be false
    end

    it 'それ以外の場合、trueを返すこと' do
      expect(event.registration_open?).to be true
    end
  end

  describe 'スコープ' do
    describe '.viewable_by' do
      let(:user) { create(:user) }
      let(:group) { create(:group) }
      let!(:event1) { create(:event, visibility: 'general') }
      let!(:event2) { create(:event, visibility: 'limited', user: user, group: group) }
      let!(:event3) { create(:event, visibility: 'limited', group: group) }

      it 'ユーザーが見られるイベントを返すこと' do
        expect(Event.viewable_by(user)).to include(event1, event2)
        expect(Event.viewable_by(user)).not_to include(event3)
      end

      it 'ゲストユーザーの場合、一般公開のイベントのみ返すこと' do
        expect(Event.viewable_by(nil)).to eq([ event1 ])
      end
    end

    describe '.search' do
      let!(:event1) { create(:event, name: 'Birthday Party', location: 'New York', date: '2024-11-12') }
      let!(:event2) { create(:event, name: 'Conference', location: 'San Francisco', date: '2024-11-13') }
      let!(:event3) { create(:event, name: 'Workshop', location: 'New York', date: '2024-11-12') }

      it '名前でイベントをフィルタリングすること' do
        results = Event.search({ search: 'Birthday' }, nil)
        expect(results).to contain_exactly(event1)
      end

      it '場所でイベントをフィルタリングすること' do
        results = Event.search({ location: 'New York' }, nil)
        expect(results).to contain_exactly(event1, event3)
      end

      it '日付でイベントをフィルタリングすること' do
        results = Event.search({ date: '2024-11-12' }, nil)
        expect(results).to contain_exactly(event1, event3)
      end

      it '複数の条件でイベントをフィルタリングすること' do
        results = Event.search({ search: 'Workshop', location: 'New York', date: '2024-11-12' }, nil)
        expect(results).to contain_exactly(event3)
      end

      it '検索条件がない場合にすべてのイベントを返すこと' do
        results = Event.search({}, nil)
        expect(results).to contain_exactly(event1, event2, event3)
      end
    end

    describe '.participating' do
      let(:user) { create(:user) }
      let(:event) { create(:event) }
      it 'ユーザーが参加中のイベントを返すこと' do
        participant = create(:participant, event: event, user: user)
        expect(Event.participating(user)).to include(event)
      end
    end
  end
end
