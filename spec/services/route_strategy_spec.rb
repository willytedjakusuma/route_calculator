require 'spec_helper'

RSpec.describe RouteStrategy do 
  include_context "fake database setup"

  describe "Method test" do 
    describe ".initialize" do
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

    describe ".fastest" do
      include_context "fastest route setup"

      it "will return data with correct format" do
        expect(result).to be_a(Hash)
        expect(result).to have_key(:routes)
        expect(result).to have_key(:time)
      end

      describe "time comparison" do
        context "better time" do
          it "will return faster routes code and time" do
            route_results_code = result[:routes].map {|r| r[:sailing_code] }
            expect(route_results_code).to include(fastest_route_data[:sailing_code])
            expect(result[:time]).to be < best[:time]
          end
        end

        context "worse time" do
          include_context "slower route setup"

          it "will return best routes code and time" do
            route_results_code = result[:routes].map {|r| r.to_h[:sailing_code] }
            expect(route_results_code).to include(random_sailing.sailing_code)
            expect(result[:time]).to eq(best[:time])
          end
        end
      end
    end

    describe ".cheapest" do
      include_context "cheapest single route setup"
      it "will return correct data format" do
        expect(result).to be_a(Hash)
        expect(result).to have_key(:routes)
        expect(result[:routes]).to be_an(Array)
        expect(result[:routes].size).to be > 0
        expect(result).to have_key(:total_cost_in_idr)
      end

      describe "price comparison" do
        context "lower price" do
          it "will return cheaper routes code and total_cost_in_idr" do
            route_results_code = result[:routes].map {|r| r[:sailing_code] }
            expect(route_results_code).to include(cheaper_route_data[:sailing_code])
            expect(result[:total_cost_in_idr]).to be < best[:total_cost_in_idr]
          end
        end

        context "higher price" do
          include_context "expensive route setup"

          it "will return best routes code and time" do
            route_results_code = result[:routes].map {|r| r.to_h[:sailing_code] }
            expect(route_results_code).to include(random_sailing.sailing_code)
            expect(result[:total_cost_in_idr]).to eq(best[:total_cost_in_idr])
          end

        end
      end
    end

    describe ".cheapest_direct" do
    end
    describe ".build_cheapest" do
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