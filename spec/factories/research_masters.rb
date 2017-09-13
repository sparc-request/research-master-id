FactoryGirl.define do
  sequence :department do |n|
    "department-#{n}"
  end
  sequence :long_title do |n|
    "long_title - #{n}"
  end
  sequence :short_title do |n|
    "short_title - #{n}"
  end
  factory :research_master do
    pi_name "ooga bo"
    department
    long_title
    short_title "short title bra"
    funding_source "who knows"
    research_type 'clinical_something'
    user
  end
end

