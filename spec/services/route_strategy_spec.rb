require 'spec_helper'

RSpec.describe RouteStrategy do 
  include_context "fake database setup"

  describe "Method test" do 
    describe "#initialize" do
      subject do 
        described_class.new(routes: sailings, rates: rates, exchange_rates: exchange_rates)
      end

      it "store correct routes data" do
        routes = subject.instance_variable_get(:@routes)
        routes_code = routes.map {|r| r[:sailing_code]}
        sailing_codes = sailings.map(&:sailing_code)

        routes.each do |route|
          expect(route).to include(:rate, :rate_currency)
        end

        expect(sailing_codes).to eq(routes_code)
      end

      it "store correct rate data" do
        rates_data = subject.instance_variable_get(:@rates_by_sailing_code)
        rates_by_sailing_code = rates.to_h {|r| [r.sailing_code, r]}
        expect(rates_data).to eq(rates_by_sailing_code)
      end
      
      it "store correct exchange rate data" do
        exchange_rates_data = subject.instance_variable_get(:@exchange_rates_by_date)
        exchange_rates_by_sailing_code = exchange_rates.to_h {|xr| [xr.date, xr]}
        expect(exchange_rates_data).to eq(exchange_rates_by_sailing_code)
      end
    end

    describe "#fastest" do
      let(:best) {
          {
            routes: [random_sailing],
            time: random_sailing.arrive_date - random_sailing.depart_date
          }
        }

      let(:result) { subject.fastest(best) }

      context "when checking the output format" do
        include_context "fastest route setup"

        it "return hash with expected keys" do
          expect(result).to be_a(Hash)
          expect(result).to have_key(:routes)
          expect(result).to have_key(:time)
        end
      end

      context "when a faster route available" do
        include_context "fastest route setup"

        it "will return faster routes and time" do
          route_results_code = result[:routes].map {|r| r[:sailing_code] }
          expect(route_results_code).to include(fastest_route_data[:sailing_code])
          expect(result[:time]).to be < best[:time]
        end
      end

      context "when no faster route available" do
        include_context "slower route setup"

        it "will return best routes code and time" do
          route_results_code = result[:routes].map {|r| r.to_h[:sailing_code] }
          expect(route_results_code).to include(random_sailing.sailing_code)
          expect(result).to eq(best)
        end
      end
    end

    describe ".cheapest" do

      context "when checking output format" do
        include_context "multi route setup"

        let(:best) {
          {
            routes: [random_sailing],
            total_cost_in_idr: 50_000_000.00
          }
        }

        let(:result) { subject.cheapest(best) }

        it "will return a hash with expected keys" do
          expect(result).to be_a(Hash)
          expect(result).to have_key(:routes)
          expect(result[:routes]).to be_an(Array)
          expect(result[:routes].size).to be > 1
          expect(result).to have_key(:total_cost_in_idr)
        end
      end

      context "when a cheaper route available" do
        include_context "multi route setup"
        
        let(:best) {
          {
            routes: [random_sailing],
            total_cost_in_idr: 50_000_000.00
          }
        }

        let(:result) { subject.cheapest(best) }

        it "will return cheapest route" do
          route_results_code = result[:routes].map {|r| r[:sailing_code] }
          expect(route_results_code).to include(sailing_from_origin.sailing_code)
          expect(route_results_code).to include(sailing_to_destination.sailing_code)
          expect(result[:total_cost_in_idr]).to be < best[:total_cost_in_idr]
        end
      end

      context "when no cheaper route available" do
        include_context "multi route setup"

        let(:best) {
          {
            routes: [random_sailing],
            total_cost_in_idr: 10.00
          }
        }

        let(:result) { subject.cheapest(best) }

        it "will return previous best route" do
          route_results_code = result[:routes].map {|r| r.to_h[:sailing_code] }
          expect(route_results_code).to include(random_sailing.sailing_code)
          expect(result).to eq(best)
        end
      end
    end

    describe ".cheapest_direct" do

      context "when given cheaper route with more than 1 route" do
        include_context "multi route setup"

        let(:best) {
          {
            routes: [random_sailing],
            total_cost_in_idr: 50_000_000.00
          }
        }

        let(:result) { subject.cheapest_direct(best) }

        it "will return previous best single route" do
          expect(result).to eq(best)
        end
      end

      context "when a cheaper single route available" do
        include_context "single route setup"

        let(:best) {
          {
            routes: [random_sailing],
            total_cost_in_idr: 50_000_000.00
          }
        }

        let(:result) { subject.cheapest_direct(best) }

        it "will return cheapest single route" do 
          route_results_code = result[:routes].map {|r| r[:sailing_code] }
          expect(route_results_code.size).to eq(1)
          expect(route_results_code).to include(sailing.sailing_code)
          expect(result[:total_cost_in_idr]).to be < best[:total_cost_in_idr]
        end 
      end

      context "when no cheaper single route available" do
        include_context "single route setup"

        let(:best) {
          {
            routes: [random_sailing.to_h],
            total_cost_in_idr: 1.00
          }
        }

        let(:result) { subject.cheapest_direct(best) }

        it "will return previous best single route" do 
          route_results_code = result[:routes].map {|r| r[:sailing_code] }
          expect(route_results_code.size).to eq(1)
          expect(route_results_code).to include(random_sailing.sailing_code)
          expect(result).to eq(best)
        end
      end
    end

    describe ".build_cheapest" do
      include_context "single route setup"
      it "will return best if routes empty" do
        result = subject.send(:build_cheapest, [], best)
        expect(result).to eq(best)
      end

      it "will return correct data if best is nil" do
        result = subject.send(:build_cheapest, [cheaper_sailing_with_rate], nil)

        expect(result).to be_a(Hash)
        expect(result).to have_key(:routes)
        expect(result[:routes]).to be_an(Array)
        expect(result[:routes].size).to be > 0
      end

      it "will return cheapest route data if total_cost_in_idr is smaller" do
        pp cheaper_sailing_with_rate
        result = subject.send(:build_cheapest, [cheaper_sailing_with_rate], best)

        route_results_code = result[:routes].map {|r| r.sailing_code }
        binding.pry
        expect(route_results_code).to include(cheaper_route_data[:sailing_code])
        expect(result[:total_cost_in_idr]).to be < best_for_cheapest[:total_cost_in_idr]
      end

      include_context "expensive route setup"
      it "will return best route data if total_cost_in_idr is bigger" do
        result = subject.send(:build_cheapest, [expensive_sailing_with_rate], best)

        route_results_code = result[:routes].map {|r| r.to_h[:sailing_code] }
        expect(route_results_code).to include(random_sailing.sailing_code)
        expect(result[:total_cost_in_idr]).to eq(best[:total_cost_in_idr])
      end
    end
    describe ".rate_in_idr" do
    end
    describe ".attach_rate" do
    end
    describe ".find_rate" do
    end
    describe ".find_exchange_rate" do
    end
  end
end