require_relative "record"
require_relative "../services/utils"

class ExchangeRate < Record

  attr_accessor :date, :usd, :idr, :eur

  def initialize(data)
    @date = Utils.format_string_to_date(data.first)
    @usd = data.last["usd"]
    @idr = data.last["idr"]
    @eur = data.last["eur"]
  end
end