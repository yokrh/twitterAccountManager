require 'twitter'

class HomeController < ApplicationController
  helper_method :client, :user, :favos

  def index
    return unless current_user

    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = Settings.twitter.consumer_key
      config.consumer_secret = Settings.twitter.consumer_secret
      config.access_token = current_user.access_token_key
      config.access_token_secret = current_user.access_token_secret
    end
    @user = @client.user
    @favos = @client.favorites count: 200
  end

  private
  def client
    @client
  end
  def user
    @user
  end
  def favos
    @favos
  end
end
