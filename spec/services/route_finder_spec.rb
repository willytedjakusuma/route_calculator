require 'spec_helper'
require_relative "../../services/route_finder.rb"

RSpec.describe RouteFinder do 
  let(:sailings) { RouteFinder.instance_variable_get(:@sailings) }
  let(:origin_port) { sailings.sample.origin }
  let(:destination_port) { sailings.sample.destination }

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
          RouteFinder.find_best_routes(origin_port,destination_port, "invalid_sailing_type")
        }.to output("Your sailing type is incorrect, please select between fastest, cheapest, or cheapest-direct").to_stdout
      end
    end

    describe "with missing origin_port" do
      it "will raise error with correct message" do
        results = RouteFinder.find_best_routes(nil, destination_port, "fastest")
        expect(results).to eq([])
      end
    end

    describe "with missing destination_port" do
      it "will raise error with correct message" do
        results = RouteFinder.find_best_routes(origin_port, nil, "cheapest-direct")
        expect(results).to eq([])
      end
    end

    describe "with cheapest-direct" do
      it "will still return results" do
        results = RouteFinder.find_best_routes(origin_port, destination_port, "cheapest-direct")
        expect(results).to be_an(Array)
        expect(results).not_to be_empty
      end
    end
  end

  describe "Flow checking" do
    describe "with no available connection" do
      let(:sailings) { [build(:sailing, :no_connection)] }

      it "will return empty array as results" do
        allow(RouteFinder).to receive(:instance_variable_get).with(@sailings).and_return(sailings) # Manipulate route finder to get sailings with no connection

        results = RouteFinder.find_best_routes("port of origin", "port of destination but never connect here", "fastest")
        expect(results).to eq([])
      end
    end

    describe "with isolated route, no next sailing" do
      let(:sailings) { [build(:sailing, :isolated)] }

      it "will return only 1 route" do
        allow(RouteFinder).to receive(:instance_variable_get).with(@sailings).and_return(sailings) # Manipulate route finder to get isolated sailing

        results = RouteFinder.find_best_routes("isolated origin", "isolated destination", "fastest")

        print results
        expect(results.size).to eq(1)
        expect(results.first[:origin]).to eq("isolated origin")
        expect(results.first[:destination]).to eq("isolated destination")
      end
    end
  end
end
