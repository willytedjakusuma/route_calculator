require_relative "record"
require_relative "../services/utils"
require "pry"

class ExchangeRate < Record

  attr_accessor :date, :usd, :idr, :eur

  def initialize(data)
    date_key = data.keys.first
    @date = Utils.format_string_to_date(data.keys.first)
    @usd = data[date_key]["usd"]
    @idr = data[date_key]["idr"]
    @eur = data[date_key]["eur"]
  end
end