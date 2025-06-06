RSpec.shared_context "fake database setup" do
  let(:database) { FakeDatabaseHelper.generate }
  let(:sailings) { database[:sailings].map {|sailing| Sailing.new(Utils.symbolize_to_string(sailing))} } 
  let(:rates) { database[:rates].map {|rate| Rate.new(Utils.symbolize_to_string(rate))} } 
  let(:exchange_rates) { database[:exchange_rates].map {|date, xrate| ExchangeRate.new([date, Utils.symbolize_to_string(xrate)])} } 
  let(:random_sailing) { sailings.sample }
  let(:idr_sailing_code) { rates.select { |r| r.rate_currency == "IDR" }}
  let(:exchange_rate_for_current_sailing_date) { exchange_rates.sample }
end