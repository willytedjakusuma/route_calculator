require_relative "models/sailing"
require_relative "models/exchange_rate"
require_relative "models/rate"
require_relative "services/route_finder"
require "pry"

sailings = Sailing.all()
exchange_rates = ExchangeRate.all()
rates = Rate.all()
p "Hello friends, welcome to Sail to Anywhere"

p "Where do you want to go ?"
# destination_code = gets.chomp.upcase
destination_code = "GBLON"

p "Okay, where do you traveling from ?"
# origin_code = gets.chomp.upcase
origin_code = "IDBTM"

p "Nice, which sailing type do you prefer ?"
# sailing_type = gets.chomp.upcase
sailing_type = "fastest"



case sailing_type
when "fastest"
  puts RouteFinder.find_fastest(sailings, origin_code, destination_code).inspect
end


exit!