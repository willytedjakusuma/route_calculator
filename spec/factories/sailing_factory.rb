FactoryBot.define do
  factory :sailing, class: Hash do
    transient do 
      rate { build(:rate) }
    end
    
    origin_port { Faker::Alphanumeric.alphanumeric(number: 4).upcase }
    destination_port { Faker::Alphanumeric.alphanumeric(number: 4).upcase }
    departure_date { Faker::Date.forward(days: rand(1..30)).to_s }
    arrival_date { Faker::Date.forward(days: rand(60..90)).to_s }
    sailing_code { rate[:sailing_code] }

    initialize_with { attributes }

    trait :no_connection do 
      origin_port { "NCOR" }
      destination_port { "NCDE" }
      sailing_code { rate[:sailing_code] }
    end

    trait :isolated do 
      origin_port { "IORI" }
      destination_port { "IDES" }
      sailing_code { rate[:sailing_code] }
    end

    trait :connected_origin do
      origin_port { "CORI" }
      destination_port { "CDOR" }
      sailing_code { rate[:sailing_code] }
    end

    trait :connected_destination do 
      origin_port { "CDOR" }
      destination_port { "CDES" }
      sailing_code { rate[:sailing_code] }
    end

    trait :fastest_origin do
      origin_port { "FORI" }
      destination_port { "FDOR" }
      sailing_code { rate[:sailing_code] }
      departure_date { "2025-04-30" }
      arrival_date { "2025-04-30" }
    end

    trait :fastest_destination do
      origin_port { "FDOR" }
      destination_port { "FDES" }
      sailing_code { rate[:sailing_code] }
      departure_date { "2025-04-30" }
      arrival_date { "2025-04-31" }
    end
  end
end