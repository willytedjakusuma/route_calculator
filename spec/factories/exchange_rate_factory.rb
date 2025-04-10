FactoryBot.define do
  factory :exchange_rate, class: Hash do
    transient do 
      date { Faker::Date.backward(days: rand(1..30)).to_s}
    end
    
    initialize_with do 
      {
        date => {
          eur: Faker::Number.decimal(l_digits: 3, r_digits: 2),
          usd: Faker::Number.decimal(l_digits: 3, r_digits: 2),
          idr: Faker::Number.decimal(l_digits: 6, r_digits: 2)
        }
      }
    end
  end
end