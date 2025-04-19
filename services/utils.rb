require 'time'

module Utils
  def self.format_string_to_date(date)
    Time.parse(date)
  end

  def self.format_date_to_string(date)
    date.strftime("%Y-%m-%d")
  end

  def self.symbolize_to_string(hash)
    # manipulate keys from string to symbol
    hash.transform_keys(&:to_s)
  end

  def self.days(day)
    day * 86_400
  end
end