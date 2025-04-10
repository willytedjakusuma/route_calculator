FactoryBot.define do
  factory :rate, class: Hash do
    sailing_code { Faker::Alphanumeric.alphanumeric(number: 4).upcase }
    rate { Faker::Number.decimal(l_digits: 4, r_digits: 2) }
    rate_currency { %i[eur usd idr].sample.to_s.upcase }

    initialize_with { attributes }
  end
end