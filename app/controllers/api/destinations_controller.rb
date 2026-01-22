module Api
  class DestinationsController < ApplicationController
    def index
      requested_month = params[:month].to_i
      month = (1..12).include?(requested_month) ? requested_month : Date.current.month
      month_label = (1..12).include?(requested_month) ? month_name_for(month) : "a melhor epoca do ano"

      cache_key = "destinations:#{current_user.id}:#{month_label}"
      cached = Rails.cache.read(cache_key)
      if cached.present?
        render json: cached and return
      end

      destinations = SeasonalDestinations.for_month(month)
      items = UnsplashClient.search_images(destinations)
      used_descriptions = []

      items.each do |item|
        description = nil

        3.times do |attempt|
          description = OpenaiClient.generate_destination_text(
            destination: item[:name],
            month: month_label,
            avoid: used_descriptions
          )

          break if description.present? && !used_descriptions.include?(description)
          sleep(0.2) if attempt < 2
        end

        description ||= "#{item[:name]} e uma otima escolha para #{month_label}."
        item[:description] = description
        used_descriptions << description
      end

      payload = { month: month, items: items }
      Rails.cache.write(cache_key, payload, expires_in: 6.hours)
      render json: payload
    end

    private

    def month_name_for(month)
      {
        1 => "janeiro",
        2 => "fevereiro",
        3 => "marco",
        4 => "abril",
        5 => "maio",
        6 => "junho",
        7 => "julho",
        8 => "agosto",
        9 => "setembro",
        10 => "outubro",
        11 => "novembro",
        12 => "dezembro"
      }[month]
    end
  end
end
