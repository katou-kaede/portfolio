require 'rails_helper'

RSpec.describe Group, type: :model do
  let(:user) { create(:user) }
  let(:friend) { create(:user) }
  let(:group) { create(:group, user: user) }

  describe 'バリデーション' do
    it 'グループ名が必須であること' do
      group.name = nil
      expect(group).to be_invalid
      expect(group.errors[:name]).to include('を入力してください')
    end
  end

  describe '#add_member' do
    it 'メンバーが追加されること' do
      group.add_member(friend)
      expect(group.members).to include(friend)
    end

    it '同じメンバーが重複して追加されないこと' do
      group.add_member(friend)
      group.add_member(friend)
      expect(group.members.count).to eq(1)
    end
  end

  context '関連' do
    it 'グループ作成者がユーザーであること' do
      expect(group.user).to eq(user)
    end

    it 'グループにメンバーが追加できること' do
      group.members << friend
      expect(group.members).to include(friend)
    end

    it 'グループが削除されると関連するイベントのgroup_idがnilに更新されること' do
      event = create(:event, group: group)
      expect(event.group_id).to eq(group.id)

      group.destroy
      event.reload
      expect(event.group_id).to be_nil
    end
  end
end
