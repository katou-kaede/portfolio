FactoryBot.define do
  factory :event do
    association :user
    name { Faker::Lorem.sentence(word_count: 3) }
    date { 1.week.from_now }
    location { "Sample Location" }
    capacity { 10 }
    visibility { "general" }
    status { "open" }

    trait :limited do
      visibility { "limited" }
    end

    trait :closed do
      status { "closed" }
    end

    trait :past do
      date { 1.week.ago }
    end
  end
end
