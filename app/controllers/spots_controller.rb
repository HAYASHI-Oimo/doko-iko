class SpotsController < ApplicationController
  def index
    if params[:query].present?
      response = Spot.fetch_spots(params[:query])

      Rails.logger.debug("Fetched Spots Data: #{@spots.inspect}")

      if response[:success]
        @spots = response[:results] # ここでモデルの処理済データを受け取る
      else
        flash[:error] = response[:error]
        @spots = [] # エラー時は空にする
      end
    else
      @spots = [] # 初期状態
    end
  end

  def show
    # データベースからスポットを検索
    @spot = Spot.find_by(place_id: params[:id])

    # スポットが見つからない場合、APIから取得
    if @spot.nil?
      @spot_details = Spot.fetch_place_details(params[:id])

      if @spot_details && @spot_details[:success]
        Rails.logger.debug("Place Details: #{@spot_details[:details].inspect}") # ✅ 修正

        Spot.save_spot_details(@spot_details[:details])
        @spot = Spot.find_by(place_id: params[:id])
      else
        flash[:error] = @spot_details&.dig(:error) || "スポットの詳細情報が取得できませんでした。"
        redirect_to spots_path and return
      end
    end

    # ビュー用に安全にデータを整形
    @spot_details = (@spot_details && @spot_details[:details]) || {}

    if @spot.latitude.present? && @spot.longitude.present?
      @weather = Spot.fetch_weather(@spot.latitude, @spot.longitude)
      Rails.logger.debug("Weather Data: #{@weather.inspect}")
    else
      Rails.logger.error("緯度・経度が不足しているため天気情報を取得できません")
      @weather = { "error" => "位置情報が不足しているため天気情報を取得できません" }
    end
  end
end
