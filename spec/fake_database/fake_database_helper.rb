require "factory_bot"
require "faker"
require "json"

module FakeDatabaseHelper
  def generate(
    sailing_count: 10, 
    rate_count: 8, 
    exchange_rate_count: 8
  )
  {
    sailings: FactoryBot.build_list(:sailing, sailing_count),
    rates: FactoryBot.build_list(:rate, rate_count),
    exchange_rates: FactoryBot.build_list(:exchange_rate, exchange_rate_count)
  }
  end

  def write_fake_database_json(file_path)
    File.open(file_path, "w") do |file|
      file.write(JSON.pretty_generate(generate))
    end
  end
end