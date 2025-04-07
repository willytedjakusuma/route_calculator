require 'json'

class Record
  def self.all
    begin
      db = File.read("database.json")
      db = JSON.parse(db)
      
      accessor_class = self.name

      case accessor_class
      when "Sailing"
        accessor_class = "sailings"
      when "ExchangeRate"
        accessor_class = "exchange_rates"
      when "Rate"
        accessor_class = "rates"
      end

      if db[accessor_class] && db[accessor_class].length > 0
        db[accessor_class].map {|data| self.new(data)} 
      else
        []
      end
    rescue Errno::ENOENT => error
      p "File error, database.json is not exist"
    rescue JSON::ParserError => error
      p "JSON File cannot be parsed, check file used"
    end
  end

end