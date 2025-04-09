require_relative 'route_strategy'

class RouteFinder
  SAILING_TYPE = %w[fastest cheapest cheapest_direct].freeze

  class << self
    def find_best_routes(sailings, origin, destination, sailing_type)
      raise "Invalid sailing type" unless SAILING_TYPE.include?(sailing_type)
      
      grouped_sailings = 
        sailings
          .select {|sailing| sailing.origin == origin || sailing.destination == destination }
          .group_by {|sailing| sailing.origin == origin ? :from : :to }

      return [] unless grouped_sailings[:from] && grouped_sailings[:to]

      result = grouped_sailings[:from].reduce(nil) do |best, sailing_from|
        sailings_to_destination = available_connections(grouped_sailings[:to], sailing_from)
        current_routes = find_routes(sailing_from, sailings_to_destination, destination)
        RouteStrategy.public_send(sailing_type, current_routes, best)
      end

      result&.dig(:routes)&.map(&:to_h)
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