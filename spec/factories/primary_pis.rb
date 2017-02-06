FactoryGirl.define do
  sequence :pi_email do |n|
    "person@#{n}@example.com"
  end
  factory :primary_pi do
    name "MyString"
    email :pi_email
    protocol nil
  end
end

