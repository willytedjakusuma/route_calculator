require "./record.rb"
require "./utils.rb"
require "pry"

class ExchangeRate < Record

  attr_accessor :date, :usd, :idr

  def initialize(*args)
    data = args.first
    @date = Utils.format_date(data.first)
    @usd = data.last["usd"]
    @idr = data.last["idr"]
  end

  def self.all
    super
  end
end