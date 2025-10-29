FactoryBot.define do
  factory :attorney, class: Attorney do
    initialize_with { new(attributes.stringify_keys) }

    name { Faker::Name.name }
    business_interests { [ Faker::Company.name, Faker::Company.name ] }

    trait :with_specific_business_interest do
      business_interests { [ "Test Company Inc" ] }
    end

    trait :with_multiple_interests do
      business_interests { [ "Company A", "Company B", "Company C" ] }
    end
  end
end
