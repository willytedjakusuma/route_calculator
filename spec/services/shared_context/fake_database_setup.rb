RSpec.shared_context "fake database setup" do
  let(:database) { FakeDatabaseHelper.generate }
  let(:sailings) { database[:sailings].map {|sailing| Sailing.new(Utils.symbolize_to_string(sailing))} } 
  let(:rates) { database[:rates].map {|rate| Rate.new(Utils.symbolize_to_string(rate))} } 
  let(:exchange_rates) { database[:exchange_rates].map {|date, xrate| ExchangeRate.new([date, Utils.symbolize_to_string(xrate)])} } 
  let(:random_sailing) { sailings.sample }
end