require 'twitter'

class HomeController < ApplicationController
  helper_method :client, :user, :favos, :favorares

  def index
    return unless current_user

    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = Settings.twitter.consumer_key
      config.consumer_secret = Settings.twitter.consumer_secret
      config.access_token = current_user.access_token_key
      config.access_token_secret = current_user.access_token_secret
    end
    @user = @client.user
    @tweets = @client.user_timeline count: 200
    @favos = @client.favorites count: 200
    @favorares = @tweets.select{ |t| t.favorited? }
  end

  private
  def client
    @client
  end
  def user
    @user
  end
  def tweets
    @tweets
  end
  def favos
    @favos
  end
  def favorares
    @favorares
  end
end
