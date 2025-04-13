RSpec.shared_context "slower route setup" do
  let(:slower_route_data) { 
    {
      origin_port: random_sailing.origin,
      destination_port: random_sailing.destination,
      arrival_date: Utils.format_date_to_string(random_sailing.arrive_date + Utils.days(3)),
      departure_date: Utils.format_date_to_string(random_sailing.depart_date),
      sailing_code: sailings.sample.sailing_code,
    } 
  }

  subject do
    described_class.new(
      routes: [Sailing.new(Utils.symbolize_to_string(slower_route_data))]
    ) 
  end
end