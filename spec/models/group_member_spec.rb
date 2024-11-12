require 'rails_helper'

RSpec.describe GroupMember, type: :model do
  let(:user) { create(:user) }
  let(:friend) { create(:user) }
  let(:group) { create(:group, user: user) }

  context '関連性' do
    it 'グループとユーザーが正しく関連付けられていること' do
      group_member = create(:group_member, group: group, user: friend)
      expect(group_member.group).to eq(group)
      expect(group_member.user).to eq(friend)
      expect(group.members).to include(friend)
    end
  end
end
