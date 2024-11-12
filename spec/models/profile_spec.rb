require 'rails_helper'

RSpec.describe Profile, type: :model do
  let(:user) { create(:user) }
  let(:profile) { build(:profile, user: user) }

  describe 'バリデーション' do
    it '有効なプロフィールが作成されること' do
      expect(profile).to be_valid
    end

    it '名前が必須であること' do
      profile.name = nil
      expect(profile).to be_invalid
      expect(profile.errors[:name]).to include('を入力してください')
    end

    it 'bioが500文字以内であること' do
      profile.bio = 'a' * 501
      expect(profile).to be_invalid
      expect(profile.errors[:bio]).to include('が長すぎます')
    end
  end

  describe 'アソシエーション' do
    it 'ユーザーに属していること' do
      expect(profile).to belong_to(:user)
    end
  end

  describe 'コールバック' do
    it 'デフォルトアバターが設定されること' do
      profile.avatar = nil
      profile.save
      expect(profile.avatar).to eq('default_avatar.png')
    end
  end
end
