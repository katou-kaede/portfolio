require 'rails_helper'

RSpec.describe "UserSessions", type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:rack_test)
  end

  describe 'ログイン機能' do
    it '正しい情報でログインできること' do
      visit new_user_session_path
      fill_in 'メールアドレス', with: user.email
      fill_in 'パスワード', with: 'password123'
      click_button 'ログイン'
      expect(page).to have_content('ログインしました')
    end

    it '誤った情報でログインできないこと' do
      visit new_user_session_path
      fill_in 'メールアドレス', with: user.email
      fill_in 'パスワード', with: 'wrongpassword'
      click_button 'ログイン'
      expect(page).to have_content('ログインに失敗しました')
    end
  end

  describe 'ログアウト機能' do
    it 'ログアウトできること' do
      sign_in user
      visit root_path
      find('#userDropdown').click
      click_link 'ログアウト'
    end
  end
end
