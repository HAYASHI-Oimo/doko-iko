class Spot < ApplicationRecord
  require "httparty"
  require "cgi"

  with_options presence: true do
    validates :name, length: { maximum: 50, message: "スポット名は50文字以下にしてください" }
    validates :address, length: { maximum: 100, message: "住所は100文字以下にしてください" }
    validates :rating, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 5, message: "評価は1から5の間で指定してください" }
    validates :description, length: { maximum: 500, message: "説明文は500文字以内で入力してください" }
    validates :image_url, format: { with: /\Ahttps?:\/\/.+\z/, message: "有効なURLを入力してください" }
  end


  scope :search_by_name, ->(query) { where("name ILIKE ?", "%#{query}%") }




  def self.fetch_spots(query)
    api_key = ENV["GOOGLE_API_KEY"]
    url = "https://maps.googleapis.com/maps/api/place/textsearch/json?query=#{CGI.escape(query)}&key=#{api_key}"
    response = HTTParty.get(url, timeout: 5)

    if response.success?
      results = JSON.parse(response.body)["results"] # 検索結果
      { success: true, results: results }
    else
      { success: false, error: "APIリクエストに失敗しました: #{response.code}" }
    end
  end

  def self.fetch_place_details(place_id)
    api_key = ENV["GOOGLE_API_KEY"]
    url = "https://maps.googleapis.com/maps/api/place/details/json?place_id=#{place_id}&key=#{api_key}"
    response = HTTParty.get(url, timeout: 5)

    if response.success?
      details = JSON.parse(response.body)["result"] # 場所の詳細情報
      { success: true, details: details }
    else
      { success: false, error: "APIリクエストに失敗しました: #{response.code}" }
    end
  end

  def self.save_spot_details(place_details)
    return if place_details.nil?

    spot = Spot.find_or_initialize_by(place_id: place_details["place_id"])
    spot.name = place_details["name"]
    spot.address = place_details["formatted_address"]
    spot.rating = place_details["rating"]
    spot.image_url = place_details["icon"]
    spot.description = place_details["adr_address"].presence || "説明がありません"

    # 緯度経度を保存
    if place_details["geometry"].present? && place_details["geometry"]["location"].present?
      spot.latitude = place_details["geometry"]["location"]["lat"]
      spot.longitude = place_details["geometry"]["location"]["lng"]
    else
      Rails.logger.error("緯度経度情報が不足しています: #{place_details.inspect}")
    end

    # 写真を取得
    if place_details["photos"].present?
      photo_reference = place_details["photos"][0]["photo_reference"]
      spot.image_url = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=#{photo_reference}&key=#{ENV['GOOGLE_API_KEY']}"
    end

    spot.save!
  end

  def self.fetch_weather(latitude, longitude)
    api_key = ENV["WEATHER_API_KEY"]
    url = "https://api.openweathermap.org/data/2.5/weather?lat=#{latitude}&lon=#{longitude}&appid=#{api_key}&units=metric"
    response = HTTParty.get(url, timeout: 5)

    if response.success?
      JSON.parse(response.body)
    else
      { "error" => "気象情報の取得に失敗しました: #{response.code}" }
    end
  end
end
