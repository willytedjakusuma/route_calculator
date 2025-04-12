require 'spec_helper'
require_relative "../../services/route_finder.rb"

RSpec.describe RouteFinder do 
  let(:sailings) { RouteFinder.instance_variable_get(:@sailings) }
  let(:direct_sailing) { sailings.sample }

  describe "Fetch fake data" do
    describe "with fake_database.json exist" do
      it "can fetch sailings data from fake database.json" do
        sailings = RouteFinder.instance_variable_get(:@sailings)
    
        expect(sailings).to be_an(Array)
        expect(sailings).not_to be_empty
      end
    end
  end

  describe "Input checking" do
    describe "with incorrect sailing_type" do
      it "will raise error with correct message" do
        expect{
          RouteFinder.find_best_routes(direct_sailing.origin, direct_sailing.destination, "invalid_sailing_type")
        }.to output("Your sailing type is incorrect, please select between fastest, cheapest, or cheapest-direct").to_stdout
      end
    end

    describe "with missing origin_port" do
      it "will raise error with correct message" do
        results = RouteFinder.find_best_routes(nil, direct_sailing.destination, "fastest")
        expect(results).to eq([])
      end
    end

    describe "with missing destination_port" do
      it "will raise error with correct message" do
        results = RouteFinder.find_best_routes(direct_sailing.origin, nil, "cheapest-direct")
        expect(results).to eq([])
      end
    end

    describe "with cheapest-direct" do
      it "will not raise invalid sailing type error" do
        
        expect{
          results = RouteFinder.find_best_routes(direct_sailing.origin, direct_sailing.destination, "fastest")

          expect(results).to be_an(Array)
          expect(results).not_to be_empty
        }.not_to raise_error
      end
    end

    describe "with correct sailing_type" do
      it "will not raise error" do
        expect { 
          RouteFinder.find_best_routes(direct_sailing.origin, direct_sailing.destination, "fastest") 
        }.not_to raise_error
      end
    end

    # WIP, test unknown error
    # describe "with unknown error" do
    #   it "will print error message" do
    #     allow(RouteFinder).to receive(:send).with(:available_connections, [], nil).and_raise(StandardError, "Unknown Error")

    #     expect {
    #       RouteFinder.find_best_routes(direct_sailing.origin, direct_sailing.destination, "fastest")
    #     }.to output("Unknown Error").to_stdout
    #   end
    # end
  end

  describe "Flow checking" do
    let(:isolated_sailings) { [Sailing.new(Utils.symbolize_to_string(build(:sailing, :isolated)))] }
    let(:no_connection_sailings) { [Sailing.new(Utils.symbolize_to_string(build(:sailing, :no_connection)))] }

    describe "with no available connection" do
      before do
        RouteFinder.instance_variable_set(:@sailings, no_connection_sailings)
      end

      it "will return empty array as results" do
        results = RouteFinder.find_best_routes("NCOR", "UNKN", "fastest")
        expect(results).to eq([])
      end
    end

    describe "with isolated route, no next sailing" do
      before do
        RouteFinder.instance_variable_set(:@sailings, isolated_sailings)
      end

      it "will return only 1 route" do
        results = RouteFinder.find_best_routes("IORI", "IDES", "fastest")

        expect(results.size).to eq(1)
        expect(results.first[:origin]).to eq("IORI")
        expect(results.first[:destination]).to eq("IDES")
      end
    end

    describe "with missing grouped_sailings[:to]" do
      before do
        RouteFinder.instance_variable_set(:@sailings, isolated_sailings)
      end
      
      it "will still return isolated sailing" do
        results = RouteFinder.find_best_routes("IORI", "IDES", "fastest")

        expect(results.size).to eq(1)
        expect(results.first[:origin]).to eq("IORI")
      end
    end

    describe "with connected routes" do
      let(:connected_sailings) {
        [
          Sailing.new(Utils.symbolize_to_string(build(:sailing, :connected_origin))),
          Sailing.new(Utils.symbolize_to_string(build(:sailing, :connected_destination))),
        ]
      }

      before do
        RouteFinder.instance_variable_set(:@sailings, connected_sailings)
      end

      it "will return multiple routes" do
        results = RouteFinder.find_best_routes("CORI", "CDES", "fastest")

        expect(results.size).to eq(2)
      end
    end
  end
end
