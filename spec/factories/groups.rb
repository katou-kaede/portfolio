FactoryBot.define do
  factory :group do
    name { "Sample Group" }
    association :user
  end
end
