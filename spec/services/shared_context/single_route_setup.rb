RSpec.shared_context "single route setup" do
  include_context "monetary based selection setup"

  let(:sailing_code_from_existing_rate) { idr_sailing_code.sample.sailing_code }
  let(:route_data) {
    {
      origin_port: random_sailing.origin,
      destination_port: random_sailing.destination,
      arrival_date: Utils.format_date_to_string(exchange_rate_for_current_sailing_date.date + Utils.days(3)),
      departure_date: Utils.format_date_to_string(exchange_rate_for_current_sailing_date.date),
      sailing_code: sailing_code_from_existing_rate,
    } 
  }

  let(:sailing) { Sailing.new(Utils.symbolize_to_string(route_data))}

  subject do
    described_class.new(routes: [sailing], rates: rates, exchange_rates: exchange_rates) 
  end

  before do
    allow(subject).to receive(:find_exchange_rate).and_return(exchange_rate_for_current_sailing_date)
  end
end