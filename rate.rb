require "./record.rb"
require "./utils.rb"
require "pry"

class Rate < Record

  attr_accessor :sailing_code, :rate, :rate_currency

  def initialize(*args)
    data = args.first
    @sailing_code = data["sailing_code"]
    @rate = data["rate"]
    @rate_currency = data["rate_currency"]
  end

  def self.all
    super
  end
end