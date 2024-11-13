require 'rails_helper'

RSpec.describe 'Events', type: :system do
  let!(:user) { create(:user) }
  let!(:event) { create(:event, user: user) }
  let!(:other_user) { create(:user) }
  let!(:group) { create(:group, user: other_user) }
  let!(:group_member) { create(:group_member, group: group, user: user) }
  let!(:closed_event) { create(:event, :closed, user: user) }
  let!(:general_event) { create(:event, user: other_user, visibility: 'general') }
  let!(:limited_event) { create(:event, user: other_user, visibility: 'limited', group: group) }
  let!(:other_event) { create(:event, user: other_user, visibility: 'limited') }
  let!(:closed_event) { create(:event, :closed, user: user) }
  let!(:past_event) { create(:event, :past, user: user) }

  before do
    driven_by(:rack_test)
  end

  describe 'ログイン前' do
    it 'イベント作成ページへのアクセスが失敗すること' do
      visit new_event_path
      expect(page).to have_content('ログインしてください')
      expect(current_path).to eq new_user_session_path
    end

    it 'イベント編集ページへのアクセスが失敗すること' do
      visit edit_event_path(event)
      expect(page).to have_content('ログインしてください')
      expect(current_path).to eq new_user_session_path
    end
  end

  describe 'ログイン後' do
    before { sign_in user }
    context 'イベント作成' do
      it '新しいイベントを作成できること' do
        visit new_event_path

        fill_in 'イベント名', with: 'New Event'
        fill_in '場所', with: 'New Location'
        select '2025', from: 'event_date_1i'
        select '11', from: 'event_date_2i'
        select '13', from: 'event_date_3i'
        select '14', from: 'event_date_4i'
        select '30', from: 'event_date_5i'
        fill_in '定員', with: 20
        fill_in '詳細', with: 'Event description'
        select '一般公開', from: 'event_visibility'
        click_button '作成'

        new_event = Event.last
        expect(current_path).to eq event_path(new_event)
        expect(page).to have_content('New Event')
      end

      it '名前が空の場合、イベントの作成に失敗すること' do
        visit new_event_path

        fill_in 'イベント名', with: ''
        fill_in '場所', with: 'New Location'
        select '2025', from: 'event_date_1i'
        select '11', from: 'event_date_2i'
        select '13', from: 'event_date_3i'
        select '14', from: 'event_date_4i'
        select '30', from: 'event_date_5i'
        fill_in '定員', with: 20
        fill_in '詳細', with: 'Event description'
        select '一般公開', from: 'event_visibility'
        click_button '作成'

        expect(current_path).to eq events_path
        expect(page).to have_content('1つのエラーがあります。')
        expect(page).to have_content('イベント名 を入力してください')
      end
    end

    context 'イベント編集' do
      it 'イベントを編集できること' do
        visit edit_event_path(event)

        fill_in 'イベント名', with: 'Update Event Name'
        fill_in '場所', with: 'Updated Location'
        select '2025', from: 'event_date_1i'
        select '11', from: 'event_date_2i'
        select '13', from: 'event_date_3i'
        select '14', from: 'event_date_4i'
        select '30', from: 'event_date_5i'
        fill_in '定員', with: 20
        fill_in '詳細', with: 'Updated Event description'
        select '一般公開', from: 'event_visibility'
        click_button '更新'

        expect(current_path).to eq event_path(event)
        expect(page).to have_content('イベントが更新されました')
      end

      it '名前が空の場合、イベントの編集に失敗すること' do
        visit edit_event_path(event)

        fill_in 'イベント名', with: ''
        fill_in '場所', with: 'Updated Location'
        select '2025', from: 'event_date_1i'
        select '11', from: 'event_date_2i'
        select '13', from: 'event_date_3i'
        select '14', from: 'event_date_4i'
        select '30', from: 'event_date_5i'
        fill_in '定員', with: 20
        fill_in '詳細', with: 'Updated Event description'
        select '一般公開', from: 'event_visibility'
        click_button '更新'

        expect(current_path).to eq event_path(event)
        expect(page).to have_content('1つのエラーがあります。')
        expect(page).to have_content('イベント名 を入力してください')
      end

      it '他のユーザーのイベント編集ページにアクセスできないこと' do
        visit edit_event_path(other_event)

        expect(page).to have_content('このイベントを編集・削除する権限がありません')
        expect(current_path).not_to eq edit_event_path(other_event)
        expect(current_path).to eq events_path
      end
    end

    context 'イベント一覧' do
      it '一般公開のイベントが表示され、限定公開は条件に基づき表示されること' do
        visit events_path

        # 一般公開のイベントは表示される
        expect(page).to have_content(general_event.name)

        # 限定公開のイベントで、条件を満たす場合表示される
        expect(page).to have_content(limited_event.name)

        # 限定公開で条件を満たさないイベントは表示されない
        expect(page).not_to have_content(other_event.name)

        # ステータスがclosedのイベントは表示されない
        expect(page).not_to have_content(closed_event.name)
      end
    end

    context '過去のイベント一覧' do
      it '過去の開催日時のイベントのみが表示されること' do
        visit past_events_path
        expect(page).to have_content(past_event.name)
        expect(page).not_to have_content(event.name)
      end
    end
  end
end
