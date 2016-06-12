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

  # 検索の絞り込み
  def index_ajax
    index # @favosが空になっているので。何かうまい方法ないのかな。dbに@xxx入れとく？

    unless params[:username].nil? || params[:username] == ""
      eval("@#{params[:object]}").select!{ |o| o.user.name == params[:username] }
    end
    unless params[:time_from].nil? || params[:time_from] == ""
      eval("@#{params[:object]}").select! do |o|
        params[:time_from] <= o.created_at.in_time_zone(user.time_zone)
      end
    end
    unless params[:time_to].nil? || params[:time_to] == ""
      eval("@#{params[:object]}").select! do |o|
        o.created_at.in_time_zone(user.time_zone) <= params[:time_to]
      end
    end
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
