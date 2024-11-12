FactoryBot.define do
  factory :profile do
    name { Faker::Name.name }
    bio { Faker::Lorem.sentence(word_count: 10) }
    avatar { nil }
    association :user
  end
end
