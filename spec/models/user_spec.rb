require 'rails_helper'

RSpec.describe User, type: :model do
  let(:user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:event) { create(:event, user: other_user) }

  describe 'バリデーション' do
    it '有効なユーザーを作成できること' do
      expect(user).to be_valid
    end

    it 'メールアドレスが存在しない場合は無効であること' do
      user.email = nil
      expect(user).to be_invalid
    end

    it 'パスワードが存在しない場合は無効であること' do
      user.password = nil
      expect(user).to be_invalid
    end
  end

  describe 'アソシエーション' do
    it '1つのプロフィールを持つこと' do
      expect(user).to have_one(:profile).dependent(:destroy)
    end

    it '複数のイベントを持つこと' do
      expect(user).to have_many(:events)
    end

    it '複数の参加イベントを持つこと' do
      expect(user).to have_many(:participated_events).through(:participants)
    end

    it '複数の友達を持つこと' do
      expect(user).to have_many(:friends).through(:friendships)
    end
  end

  describe 'インスタンスメソッド' do
    context 'イベント参加関連のメソッド' do
      it 'イベントに参加しているか確認すること' do
        user.join_event(event)
        expect(user.participating?(event)).to be true
      end

      it 'イベントから離れることができること' do
        user.join_event(event)
        user.leave_event(event)
        expect(user.participating?(event)).to be false
      end
    end

    context '友達関連のメソッド' do
      it '他のユーザーと友達であるかを確認すること' do
        user.follow(other_user)
        expect(user.friends_with?(other_user)).to be true
      end

      it 'フォローすることができること' do
        expect { user.follow(other_user) }.to change { user.friends.count }.by(1)
      end

      it 'フォロー解除できること' do
        user.follow(other_user)
        expect { user.unfollow(other_user) }.to change { user.friends.count }.by(-1)
      end
    end
  end
end
