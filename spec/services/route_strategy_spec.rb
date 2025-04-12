require 'spec_helper'

require_relative "../../services/route_strategy.rb"
require_relative "../../services/route_finder.rb"
require_relative "../../services/utils.rb"

require_relative "../../models/sailing.rb"
require_relative "../../models/rate.rb"
require_relative "../../models/exchange_rate.rb"

require_relative "../fake_database/fake_database_helper.rb"

RSpec.describe RouteStrategy do 
  let(:database) { FakeDatabaseHelper.generate }
  let(:sailings) { database[:sailings].map {|sailing| Sailing.new(Utils.symbolize_to_string(sailing))} } 
  let(:rates) { database[:rates].map {|rate| Rate.new(Utils.symbolize_to_string(rate))} } 
  let(:exchange_rates) { database[:exchange_rates].map {|date, xrate| ExchangeRate.new([date, Utils.symbolize_to_string(xrate)])} } 

  
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
      let(:random_sailing) { sailings.sample }
      let(:best) {
        {
          routes: [random_sailing],
          time: random_sailing.arrive_date - random_sailing.depart_date
        }
      }
      let(:fastest_route_data) { 
        {
          origin_port: random_sailing.origin,
          destination_port: random_sailing.destination,
          arrival_date: Utils.format_date_to_string(random_sailing.arrive_date - Utils.days(3)),
          departure_date: Utils.format_date_to_string(random_sailing.depart_date),
          sailing_code: sailings.sample.sailing_code,
        } 
      }
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
          routes: [Sailing.new(Utils.symbolize_to_string(fastest_route_data))]
        ) 
      end

      let(:result) { subject.fastest(best) }

      it "will return data with correct format" do
        expect(result).to be_a(Hash)
        expect(result).to have_key(:routes)
        expect(result).to have_key(:time)
      end

      describe "time comparison" do
        describe "better time" do
          subject do
            described_class.new(
              routes: [Sailing.new(Utils.symbolize_to_string(fastest_route_data))]
            ) 
          end

          let(:result) { subject.fastest(best) }

          it "will return faster routes code and time" do
            route_results_code = result[:routes].map {|r| r[:sailing_code] }
            expect(route_results_code).to include(fastest_route_data[:sailing_code])
            expect(result[:time]).to be < best[:time]
          end
        end

        describe "worse time" do
          subject do
            described_class.new(
              routes: [Sailing.new(Utils.symbolize_to_string(slower_route_data))]
            ) 
          end

          let(:result) { subject.fastest(best) }

          it "will return best routes code and time" do
            route_results_code = result[:routes].map {|r| r.to_h[:sailing_code] }
            expect(route_results_code).to include(random_sailing.sailing_code)
            expect(result[:time]).to eq(best[:time])
          end
        end
      end

    end
    describe ".cheapest" do
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