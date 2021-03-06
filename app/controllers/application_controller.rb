class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  before_filter :get_coin_value
    
  def get_coin_value
    blockr = BigEarth::Blockchain::Blockr.new
    coin_info = blockr.coin
    @exchange_rate = coin_info['data']['markets']['coinbase']['value']
  end
  
  def after_sign_in_path_for user
    user_path user
  end
end
