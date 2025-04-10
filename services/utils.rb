require 'time'

module Utils
  def self.format_string_to_date(date)
    Time.parse(date)
  end

  def self.format_date_to_string(date)
    date.strftime("%Y-%m-%d")
  end
end