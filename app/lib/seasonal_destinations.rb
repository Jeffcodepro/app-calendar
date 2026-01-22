require "yaml"

class SeasonalDestinations
  DATA_PATH = Rails.root.join("config/seasonal_destinations.yml")

  def self.for_month(month)
    data = YAML.safe_load(File.read(DATA_PATH))
    month_data = data.fetch(month.to_s, {})

    brasil = Array(month_data["brasil"])
    exterior = Array(month_data["exterior"])

    (brasil + exterior).map { |name| { name: name } }
  end
end
