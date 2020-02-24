FactoryBot.define do
  factory :protocol do
    type { Faker::Lorem.word }
    long_title { Faker::Lorem.sentence(word_count: 3) }
    sparc_id { 1 }
    coeus_id { 1 }
    eirb_id { 1 }
  end
end
