RSpec.shared_context "multi route setup" do
  include_context "monetary based selection setup"

  let(:sailing_code_first_route) { idr_sailing_code.sample.sailing_code }
  let(:sailing_code_second_route) { idr_sailing_code.sample.sailing_code }
  let(:sailing_from_origin) do
    Sailing.new(Utils.symbolize_to_string(build(:sailing, :connected_origin, sailing_code: sailing_code_first_route)))
  end
  
  let(:sailing_to_destination) do
    Sailing.new(Utils.symbolize_to_string(build(:sailing, :connected_destination, sailing_code: sailing_code_second_route)))
  end

  subject do
    described_class.new(routes: [sailing_from_origin, sailing_to_destination], rates: rates, exchange_rates: exchange_rates) 
  end

  before do
    allow(subject).to receive(:find_exchange_rate).and_return(exchange_rate_for_current_sailing_date)
  end
end