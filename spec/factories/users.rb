FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "user#{n}@example.com" }
    password { "password123" }
    password_confirmation { "password123" }

    # プロフィールを作成
    after(:create) do |user|
      create(:profile, user: user)
    end
  end
end
