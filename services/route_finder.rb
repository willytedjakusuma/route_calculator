require_relative 'route_strategy'
require_relative '../models/sailing'

class RouteFinder
  SAILING_TYPE = %w[fastest cheapest cheapest_direct].freeze
  @sailings = Sailing.all.freeze

  class << self
    def find_best_routes(origin, destination, sailing_type)
      begin
        sailing_type = "cheapest_direct" if sailing_type == "cheapest-direct"
        raise "Invalid sailing type" unless SAILING_TYPE.include?(sailing_type)
        
        grouped_sailings = 
          @sailings
            .select {|sailing| sailing.origin == origin || sailing.destination == destination }
            .group_by {|sailing| sailing.origin == origin ? :from : :to }

        return [] unless grouped_sailings[:from] && grouped_sailings[:to]

        result = grouped_sailings[:from].reduce(nil) do |best, sailing_from|
          current_routes = find_routes(sailing_from, available_connections(grouped_sailings[:to], sailing_from), destination)

          next best unless current_routes.any?
          RouteStrategy.new(routes: current_routes).public_send(sailing_type, best)
        end

        result&.dig(:routes) || []
      rescue RuntimeError => error
        case error.message
        when "Invalid sailing type"
          print "Your sailing type is incorrect, please select between fastest, cheapest, or cheapest-direct"
        end
      end
      
    end

    private

    def find_routes(sailing_from, sailings_to, destination, routes = [])
      routes += [sailing_from]
      return routes if sailing_from.destination == destination

      next_route, *rest_of_the_routes = sailings_to
      return routes unless next_route
      
      find_routes(next_route, rest_of_the_routes, destination, routes)
    end

    def available_connections(grouped_sailings_to, from)
      grouped_sailings_to
        .select { |sailing_to| sailing_to.origin == from.destination }
        .sort_by { |route| route.arrive_date - route.depart_date }
    end
  end
end