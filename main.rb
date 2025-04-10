require_relative "services/route_finder"

p "Hello friends, welcome to Sail to Anywhere"
p "Where do you want to go ?"
# destination_code = gets.chomp.upcase
destination_code = "GBLON"

p "Okay, where do you traveling from ?"
# origin_code = gets.chomp.upcase
origin_code = "IDBTM"

p "Nice, which sailing type do you prefer ?"
# sailing_type = gets.chomp.upcase
# sailing_type = "fastest"
sailing_type = "cheapest"
# sailing_type = "cheapest-direct"


puts RouteFinder.find_best_routes(origin_code, destination_code, sailing_type).inspect