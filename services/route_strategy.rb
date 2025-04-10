require_relative '../models/rate'
require_relative '../models/exchange_rate'
require_relative "utils"

class RouteStrategy
  def initialize(routes:, rates: Rate.all.freeze, exchange_rates: ExchangeRate.all.freeze)
    @rates_by_sailing_code = rates.to_h {|r| [r.sailing_code, r]}
    @exchange_rates_by_date = exchange_rates.to_h {|xr| [xr.date, xr]}
    @routes = attach_rate(routes)
  end

  def fastest(best)
    travel_time = @routes.last.arrive_date - routes.first.depart_date
    return { routes: @routes, time: travel_time } if best.nil? || travel_time < best[:time]

    best
  end

  def cheapest(best)
    build_cheapest(@routes, best)
  end

  def cheapest_direct(best)
    return best if routes.length > 1

    build_cheapest(@routes, best)
  end

  private

  def build_cheapest(routes, best)
    return best if routes.empty?

    total_cost_in_idr = routes.sum {|route| rate_in_idr(route[:rate], route[:rate_currency], route[:depart_date]) }
    return { routes: routes, total_cost_in_idr: total_cost_in_idr } if best.nil? || total_cost_in_idr < best[:total_cost_in_idr]

    best
  end

  def rate_in_idr(rate, rate_currency, depart_date)
    exchange_rate = find_exchange_rate(depart_date)

    return 0.0 unless exchange_rate

    # Math equation
    # currency / idr = 1 / y
    # y = idr / currency
    
    idr_per_currency = (exchange_rate.idr / exchange_rate.public_send(rate_currency.downcase)).round(2)
    (rate.to_f * idr_per_currency).round(2)
  end

  def attach_rate(routes)
    return routes if routes.empty?

    routes.map do |route|
      rate = find_rate(route.sailing_code)
      route.to_h.merge(rate: rate&.rate, rate_currency: rate&.rate_currency)
    end
  end

  def find_rate(sailing_code)
    @rates_by_sailing_code[sailing_code]
  end

  def find_exchange_rate(depart_date)
    @exchange_rates_by_date[depart_date]
  end
end