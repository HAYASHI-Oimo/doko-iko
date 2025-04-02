class ApplicationController < ActionController::Base
  # モジュールをインクルード
  include ActionController::AllowBrowser

  # モダンブラウザのみを許可する設定を適用
  before_action -> { allow_browser versions: :modern }, except: [ :index ]
end
