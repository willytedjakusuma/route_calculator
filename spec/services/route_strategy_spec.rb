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

    describe "#cheapest" do

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

    describe "#cheapest_direct" do

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
      
      context "when given empty routes" do
        include_context "single route setup"

        let(:best) {
          {
            routes: [random_sailing],
            total_cost_in_idr: 50_000_000.00
          }
        }

        it "will return previous best routes" do
          result = subject.send(:build_cheapest, [], best)
          expect(result).to eq(best)
        end
      end

      context "when best is nil" do
        include_context "single route setup"

        it "will return given routes" do
          result = subject.send(:build_cheapest, [sailing_hash], nil)
          expect(result).to be_a(Hash)
          expect(result).to have_key(:routes)
          expect(result[:routes]).to be_an(Array)
          expect(result[:routes].size).to be > 0
          route_results_code = result[:routes].map {|r| r[:sailing_code] }
          expect(route_results_code).to include(sailing_hash[:sailing_code])
        end
      end

      context "when a routes cost is cheaper than best" do
        include_context "single route setup"

        let(:best) {
          {
            routes: [random_sailing],
            total_cost_in_idr: 50_000_000.00
          }
        }


        it "will return cheapest route data" do
          result = subject.send(:build_cheapest, [sailing_hash], best)
          route_results_code = result[:routes].map {|r| r[:sailing_code] }
          expect(route_results_code).to include(sailing.sailing_code)
          expect(result[:total_cost_in_idr]).to be < best[:total_cost_in_idr]
        end
      end

      context "when no routes cost is cheaper than best" do
        include_context "single route setup"

        let(:best) {
          {
            routes: [random_sailing.to_h],
            total_cost_in_idr: 0.00
          }
        }

        let(:result) { subject.send(:build_cheapest, [sailing], best) }

        it "will return previous best route" do
          result = subject.send(:build_cheapest, [sailing_hash], best)
          route_results_code = result[:routes].map {|r| r[:sailing_code] }
          expect(route_results_code).to include(random_sailing.sailing_code)
          expect(result).to eq(best)
        end
      end


    end

    describe ".rate_in_idr" do
      subject do
        described_class.new(routes: sailings, rates: rates, exchange_rates: exchange_rates) 
      end

      context "when given valid parameters" do
        let(:rate) { rates.find { |r| r.rate_currency != "IDR" } }
        let(:depart_date) { exchange_rates.sample.date }

        it "will return float with 2 decimal" do
          result = subject.send(:rate_in_idr, rate.rate, rate.rate_currency, depart_date)
          expect(result).to be_a(Float)
          expect(result.round(2)).to eq(result)
        end
      end

      context "when exchange_rate not found" do
        let(:rate) { rates.find { |r| r.rate_currency != "IDR" } }

        it "will return float with value 0.0" do
          result = subject.send(:rate_in_idr, rate.rate, rate.rate_currency, nil)
          expect(result).to be_a(Float)
          expect(result.round(2)).to eq(0.0)
        end
      end


    end

    describe ".attach_rate" do
      let(:sailings_with_matching_rates) do
        FactoryBot.build_list(:sailing, 5).map do |sailing, i|
          sailing[:sailing_code] = rates.sample.sailing_code
          Sailing.new(Utils.symbolize_to_string(sailing))
        end
      end
      
      subject do 
        described_class.new(routes: sailings_with_matching_rates, rates: rates, exchange_rates: exchange_rates)
      end

      context "when routes is exist" do
        let(:result) { subject.send(:attach_rate, sailings_with_matching_rates) }

        it "will return routes data in hash" do
          expect(result).to be_an(Array)
          result.each do |row|
            expect(row).to be_a(Hash)
            expect(row).to include(
              origin: a_kind_of(String),
              destination: a_kind_of(String),
              depart_date: a_kind_of(Time),
              arrive_date: a_kind_of(Time),
              sailing_code: a_kind_of(String)
            )
          end
        end

        it "will return routes data with rate and rate_currency keys" do
          expect(result).to be_an(Array)
          result.each do |row|
            expect(row).to be_a(Hash)
            expect(row).to include(
              rate: a_kind_of(Float),
              rate_currency: a_kind_of(String)
            )
          end
        end

        it "will matched first data with the example" do
          first_data = sailings_with_matching_rates.first
          rate = rates.find {|r| r.sailing_code == first_data.sailing_code }

          expect(result.first).to match(
            origin: first_data.origin,
            destination: first_data.destination,
            depart_date: first_data.depart_date,
            arrive_date: first_data.arrive_date,
            sailing_code: first_data.sailing_code,
            rate: rate.rate,
            rate_currency: rate.rate_currency
          )
        end
      end

      context "when routes is empty" do
        let(:result) { subject.send(:attach_rate, []) }

        it "will return empty array" do
          expect(result).to be_an(Array)
          expect(result.size).to eq(0)
        end
      end
    end
  end
end