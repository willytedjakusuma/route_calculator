require 'time'

module Utils
  def self.format_date(date)
    Time.parse(date)
  end
end