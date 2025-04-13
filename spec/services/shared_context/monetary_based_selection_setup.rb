RSpec.shared_context "monetary based selection setup" do
  let(:idr_sailing_code) { rates.select { |r| r.rate_currency == "IDR" }}
  let(:exchange_rate_for_current_sailing_date) { exchange_rates.sample }
end