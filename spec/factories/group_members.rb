FactoryBot.define do
  factory :group_member do
    association :group
    association :user
  end
end
