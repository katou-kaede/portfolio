require 'rails_helper'

RSpec.describe "Profiles", type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:rack_test)
  end

  describe 'ログイン前' do
    it 'マイページへのアクセスが失敗すること' do
      visit user_path(user)
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content('ログインしてください')
    end

    it 'プロフィール編集ページへのアクセスが失敗すること' do
      visit edit_user_path(user)
      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content('ログインしてください')
    end
  end

  describe 'ログイン後' do
    before { sign_in user }
    it 'プロフィールの情報を編集できること' do
      visit edit_user_path(user)

      select 'うさぎ', from: 'avatar-select'
      fill_in '名前', with: 'New Name'
      fill_in 'ひとこと', with: 'New bio'
      select '2000', from: 'BirthdayYear'
      select '1', from: 'BirthdayMonth'
      select '1', from: 'BirthdayDay'
      click_button '更新'

      expect(page).to have_current_path(user_path(user))
      expect(page).to have_content('プロフィールが更新されました')
      expect(page).to have_content('New Name')
    end

    it "名前がない場合に編集に失敗すること" do
      visit edit_user_path(user)

      fill_in "名前", with: ""
      click_button "更新"

      expect(page).to have_content('1つのエラーがあります。')
      expect(page).to have_content('名前 を入力してください')
      expect(page).to have_current_path(user_path(user))
    end
  end
end
