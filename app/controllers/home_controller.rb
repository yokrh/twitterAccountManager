require 'twitter'

class HomeController < ApplicationController
  helper_method :client, :user, :favos, :favorares, :rts, :rtrares

  def index
    return unless current_user

    @client = Twitter::REST::Client.new do |config|
      config.consumer_key = Settings.twitter.consumer_key
      config.consumer_secret = Settings.twitter.consumer_secret
      config.access_token = current_user.access_token_key
      config.access_token_secret = current_user.access_token_secret
    end

    max_size = 200
    @user = @client.user
    @tweets = @client.user_timeline count: max_size
    @favos = @client.favorites count: max_size
    @favorares = @tweets.select{ |t| t.favorite_count > 0 }
    @rts_by_me = @client.retweeted_by_me count: max_size
    @rts = @rts_by_me.map{ |r| r.retweeted_status }
    @rtrares = @client.retweets_of_me count:max_size
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
  def rts
    @rts
  end
  def rtrares
    @rtrares
  end
end
