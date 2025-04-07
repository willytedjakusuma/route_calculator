require './record.rb'
require "./utils.rb"
require 'pry'

class Sailing < Record

  attr_accessor :origin, :destination, :depart, :arrive, :sailing_code

  def initialize(*args)
    data = args.first
    @origin = data["origin_port"]
    @destination = data["destination_port"]
    @depart_date = Utils.format_date(data["departure_date"])
    @arrive_date = Utils.format_date(data["arrival_date"])
    @sailing_code = data["sailing_code"]
  end

  def self.all
    super
  end
end