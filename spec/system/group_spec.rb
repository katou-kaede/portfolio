require 'rails_helper'

RSpec.describe 'Groups', type: :system do
  let!(:user) { create(:user) }
  let!(:friend1) { create(:user) }
  let!(:friend2) { create(:user) }
  let!(:friendship1) { create(:friendship, user: user, friend: friend1) }
  let!(:friendship2) { create(:friendship, user: user, friend: friend2) }
  let!(:group) { create(:group, user: user) }
  let!(:group_member1) { create(:group_member, group: group, user: friend1) }
  let!(:other_user) { create(:user) }
  let!(:other_group) { create(:group, name: 'Other User Group', user: other_user) }

  before do
    driven_by(:rack_test)
    friend1.profile.update(name: 'Friend One')
    friend2.profile.update(name: 'Friend Two')
  end

  describe 'ログイン前' do
    it 'グループ作成ページへのアクセスが失敗すること' do
      visit new_group_path
      expect(page).to have_content('ログインしてください')
      expect(current_path).to eq new_user_session_path
    end

    it 'グループ編集ページへのアクセスが失敗すること' do
      visit edit_group_path(group)
      expect(page).to have_content('ログインしてください')
      expect(current_path).to eq new_user_session_path
    end
  end

  describe 'ログイン後' do
    before { sign_in user }
    context 'グループ作成' do
      it '新しいグループを作成できること' do
        visit new_group_path

        fill_in 'グループ名', with: 'Test Group'
        select 'Friend One', from: 'メンバーを追加'
        select 'Friend Two', from: 'メンバーを追加'
        click_button '作成'

        new_group = Group.last
        expect(current_path).to eq group_path(new_group)
        expect(page).to have_content('Test Group')
        expect(page).to have_content('Friend One')
        expect(page).to have_content('Friend Two')
        expect(page).to have_content('グループが作成されました')
      end

      it 'グループ名が空の場合、作成に失敗すること' do
        visit new_group_path

        fill_in 'グループ名', with: ''
        click_button '作成'

        expect(current_path).to eq groups_path
        expect(page).to have_content('1つのエラーがあります。')
        expect(page).to have_content('グループ名 を入力してください')
      end
    end

    context 'グループ編集' do
      it 'グループ情報を編集できること' do
        visit edit_group_path(group)

        fill_in 'グループ名', with: 'Updated Group Name'
        unselect 'Friend One', from: 'メンバーを追加'
        select 'Friend Two', from: 'メンバーを追加'
        click_button '更新'

        expect(current_path).to eq group_path(group)
        expect(page).to have_content('Updated Group Name')
        expect(page).not_to have_content('Friend One')
        expect(page).to have_content('Friend Two')
        expect(page).to have_content('グループが更新されました')
      end

      it 'グループ名が空の場合、編集に失敗すること' do
        visit edit_group_path(group)

        fill_in 'グループ名', with: ''
        click_button '更新'

        expect(current_path).to eq group_path(group)
        expect(page).to have_content('1つのエラーがあります。')
        expect(page).to have_content('グループ名 を入力してください')
      end

      it '他のユーザーが作成したグループの編集ページにアクセスできないこと' do
        visit edit_group_path(other_group)

        expect(current_path).not_to eq edit_group_path(other_group)
        expect(page).to have_content('このグループを編集・削除する権限がありません')
      end
    end

    context 'グループ一覧' do
      it '自分が作成したグループだけが表示されること' do
        visit groups_path

        expect(page).to have_content group.name
        expect(page).not_to have_content other_group.name
      end
    end
  end
end
