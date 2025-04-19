require_relative "services/route_finder"

p "Hello friends, welcome to Sail to Anywhere"
p "Where do you want to go ?"
destination_code = gets.chomp.upcase

p "Okay, where do you traveling from ?"
origin_code = gets.chomp.upcase

p "Nice, which sailing type do you prefer ? [fastest, cheapest, cheapest-direct]"
sailing_type = gets.chomp


p RouteFinder.find_best_routes(origin_code, destination_code, sailing_type).inspect