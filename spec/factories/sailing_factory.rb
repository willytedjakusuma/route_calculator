FactoryBot.define do
  factory :sailing, class: Hash do
    transient do 
      rate { build(:rate) }
    end
    
    origin_port { Faker::Alphanumeric.alphanumeric(number: 4).upcase }
    destination_port { Faker::Alphanumeric.alphanumeric(number: 4).upcase }
    departure_date { Faker::Date.forward(days: rand(1..30)).to_s }
    arrival_date { Faker::Date.forward(days: rand(31..60)).to_s }
    sailing_code { rate[:sailing_code] }

    initialize_with { attributes }
  end
end