FactoryBot.define do
  factory :profile do
    name { Faker::Name.name }
    bio { Faker::Lorem.sentence(word_count: 10) }
    birthday { Faker::Date.birthday(min_age: 18, max_age: 65) }
    # avatar { nil }
    association :user
  end
end
