require_relative "record"
require_relative "../services/utils"
require "pry"

class Rate < Record

  attr_accessor :sailing_code, :rate, :rate_currency

  def initialize(data)
    @sailing_code = data["sailing_code"]
    @rate = data["rate"]
    @rate_currency = data["rate_currency"]
  end
end