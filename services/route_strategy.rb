class RouteStrategy
  class << self

    def fastest(routes, best)
      return best unless routes.any?

      travel_time = routes.last.arrive_date - routes.first.depart_date
      best.nil? || travel_time < best[:time] ? { routes: routes, time: travel_time } : best
    end
  end
end