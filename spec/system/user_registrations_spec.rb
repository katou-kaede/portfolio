require 'rails_helper'

RSpec.describe 'UserRegistrations', type: :system do
  let(:user) { create(:user) }

  before do
    driven_by(:rack_test)
  end

  describe 'ログイン前' do
    context 'フォームの入力値が正常' do
      it 'ユーザーの新規作成が成功すること' do
        visit new_user_registration_path
        fill_in 'メールアドレス', with: 'newuser@example.com'
        fill_in 'パスワード', with: 'password123'
        fill_in 'パスワード確認', with: 'password123'
        fill_in '名前', with: 'New User'
        click_button '登録'

        expect(page).to have_current_path(root_path)
        expect(page).to have_content('ユーザー登録が完了しました')
      end
    end

    context 'フォームの入力値が異常' do
      it 'メールアドレスが空の場合、新規登録に失敗すること' do
        visit new_user_registration_path
        fill_in 'パスワード', with: 'password123'
        fill_in 'パスワード確認', with: 'password123'
        fill_in '名前', with: 'New User'
        click_button '登録'

        expect(page).to have_content('1つのエラーがあります。')
        expect(page).to have_content('メールアドレス を入力してください')
        expect(current_path).to eq users_path
      end

      it 'メールアドレスがすでに使用されている場合、新規登録に失敗すること' do
        existed_user = create(:user)
        visit new_user_registration_path
        fill_in 'メールアドレス', with: existed_user.email
        fill_in 'パスワード', with: 'password123'
        fill_in 'パスワード確認', with: 'password123'
        fill_in '名前', with: 'New User'
        click_button '登録'

        expect(page).to have_content('1つのエラーがあります。')
        expect(page).to have_content('メールアドレス がすでに使用されています')
        expect(current_path).to eq users_path
        expect(page).to have_field 'メールアドレス', with: existed_user.email
      end

      it '名前が空の場合、新規登録に失敗すること' do
        visit new_user_registration_path
        fill_in 'メールアドレス', with: 'newuser@example.com'
        fill_in 'パスワード', with: 'password123'
        fill_in 'パスワード確認', with: 'password123'
        fill_in '名前', with: ''
        click_button '登録'

        expect(page).to have_content('1つのエラーがあります。')
        expect(page).to have_content('名前 を入力してください')
        expect(current_path).to eq users_path
      end
    end
  end

  describe 'ログイン後' do
    before { sign_in user }
    context 'フォームの入力値が正常' do
      it 'ユーザーが自分のアカウント情報を編集できること' do
        visit edit_user_registration_path
        fill_in 'メールアドレス', with: 'updateduser@example.com'
        fill_in '新しいパスワード', with: 'newpassword123'
        fill_in '新しいパスワード(確認)', with: 'newpassword123'
        fill_in '現在のパスワード', with: 'password123'
        click_button '更新'

        expect(page).to have_current_path(user_path(user))
        expect(page).to have_content('アカウント情報が更新されました')
      end
    end

    context 'フォームの入力値が異常' do
      it 'メールアドレスが空の場合、アカウント編集に失敗すること' do
        visit edit_user_registration_path
        fill_in 'メールアドレス', with: ''
        click_button '更新'

        expect(page).to have_content('1つのエラーがあります。')
        expect(page).to have_content('メールアドレス を入力してください')
        expect(current_path).to eq users_path
      end

      it 'メールアドレスがすでに使用されている場合、アカウント編集に失敗すること' do
        existed_user = create(:user)
        visit edit_user_registration_path
        fill_in 'メールアドレス', with: existed_user.email
        click_button '更新'

        expect(page).to have_content('1つのエラーがあります。')
        expect(page).to have_content('メールアドレス がすでに使用されています')
        expect(current_path).to eq users_path
        expect(page).to have_field 'メールアドレス', with: existed_user.email
      end

      it '現在のパスワードが誤っている場合、アカウント編集に失敗すること' do
        visit edit_user_registration_path
        fill_in '新しいパスワード', with: 'newpassword123'
        fill_in '新しいパスワード(確認)', with: 'newpassword123'
        fill_in '現在のパスワード', with: 'incorrectpassword'
        click_button '更新'

        expect(current_path).to eq users_path
        expect(page).to have_content('現在のパスワード が正しくありません')
      end
    end
  end
end
