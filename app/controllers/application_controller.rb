class ApplicationController < ActionController::Base
  # モジュールをインクルード
  include ActionController::AllowBrowser

  # モダンブラウザのみ許可（indexアクションを除外）
  before_action -> { allow_browser(versions: :modern) }, except: [ :index, :show ]
end
