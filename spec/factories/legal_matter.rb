FactoryBot.define do
  factory :legal_matter, class: LegalMatter do
    initialize_with { new(attributes.stringify_keys) }

    matter_number { "2024-#{rand(1000..9999)}" }
    title { "#{Faker::Company.name} Legal Matter" }
    client_name { Faker::Company.name }
    client_type { ["Individual", "Corporation", "LLC", "Trust"].sample }
    practice_area { "Corporate Law" }
    matter_type { "Contract Dispute" }
    status { "Active" }
    opened_date { "2024-01-01" }
    closed_date { nil }
    adverse_parties { [] }
    related_parties { [] }
    assigned_attorney { "Test Attorney" }
    description { "Legal matter description" }

    trait :active do
      status { "Active" }
      closed_date { nil }
    end

    trait :closed do
      status { "Closed" }
      closed_date { "2024-03-01" }
    end

    trait :with_related_party do
      related_parties { ["Related Party (Role)"] }
    end

    trait :with_adverse_party do
      adverse_parties { ["Adverse Party"] }
    end

    trait :with_specific_client do
      client_name { "Test Company Inc" }
    end

    trait :with_specific_matter_number do
      matter_number { "2024-9999" }
    end
  end
end
