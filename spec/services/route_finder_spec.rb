require 'spec_helper'
require_relative "../../services/route_finder.rb"

RSpec.describe RouteFinder do 
  it "can fetch sailings data from fake database.json" do
    sailings = RouteFinder.instance_variable_get(:@sailings)

    expect(sailings).not_to be_empty
  end
end
