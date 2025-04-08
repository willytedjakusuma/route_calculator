require_relative 'record'
require_relative "../services/utils"
require 'pry'

class Sailing < Record

  attr_accessor :origin, :destination, :depart_date, :arrive_date, :sailing_code

  def initialize(data)
    @origin = data["origin_port"]
    @destination = data["destination_port"]
    @depart_date = Utils.format_date(data["departure_date"])
    @arrive_date = Utils.format_date(data["arrival_date"])
    @sailing_code = data["sailing_code"]
  end
end