require_relative "record"
require_relative "../services/utils"
require "pry"

class ExchangeRate < Record

  attr_accessor :date, :usd, :idr

  def initialize(data)
    @date = Utils.format_date(data.first)
    @usd = data.last["usd"]
    @idr = data.last["idr"]
    @eur = data.last["eur"]
  end
end