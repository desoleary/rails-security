FactoryGirl.define do
  factory :user do
    sequence(:real_name ) { |n| "Real Name ##{n}" }
    sequence(:email ) { |n| "some-email-#{n}@email.com" }
    sequence(:username)   { |n| "some-username ##{n}" }
    admin false
  end

  factory :admin, parent: :user do
    admin true
  end
end

