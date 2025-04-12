RSpec.shared_context "cheapest single route setup" do
  include_context "monetary based selection setup"

  let(:cheapest_sailing_code) {idr_sailing_code.min_by(&:rate)}
  let(:cheaper_route_data) {
    {
      origin_port: random_sailing.origin,
      destination_port: random_sailing.destination,
      arrival_date: Utils.format_date_to_string(exchange_rate_for_current_sailing_date.date + Utils.days(3)),
      departure_date: Utils.format_date_to_string(exchange_rate_for_current_sailing_date.date),
      sailing_code: cheapest_sailing_code.sailing_code,
    } 
  }

  let(:cheaper_sailing) { Sailing.new(Utils.symbolize_to_string(cheaper_route_data))}

  subject do
    described_class.new(routes: [cheaper_sailing], rates: rates, exchange_rates: exchange_rates) 
  end

  before do
    allow(subject).to receive(:find_exchange_rate).and_return(exchange_rate_for_current_sailing_date)
  end

  let(:best) {
    {
      routes: [random_sailing],
      total_cost_in_idr: 50_000_000.00
    }
  }

  let(:result) { subject.cheapest(best)}
end