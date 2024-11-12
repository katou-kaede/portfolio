require 'rails_helper'

RSpec.describe Friendship, type: :model do
  let(:user) { create(:user) }
  let(:friend) { create(:user) }
  let(:friendship) { create(:friendship, user: user, friend: friend) }

  it 'ユーザーと友達が関連付けられていること' do
    expect(friendship.user).to eq(user)
    expect(friendship.friend).to eq(friend)
  end

  it '友達関係は一方向であること（user -> friend、friend -> user）' do
    create(:friendship, user: user, friend: friend)
    expect(user.friends).to include(friend)
    expect(friend.friends).not_to include(user)
  end

  it '同じユーザーと友達にならないこと' do
    same_user_friendship = build(:friendship, user: user, friend: user)
    expect(same_user_friendship).to be_invalid
  end
end
