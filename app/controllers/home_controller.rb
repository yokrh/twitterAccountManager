require 'twitter'

class HomeController < ApplicationController
  helper_method :client, :user, :favos, :favorares, :rts, :rtrares

  def index
    return unless current_user
    fetch_user_datas
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
    @client ||= Twitter::REST::Client.new do |config|
      config.consumer_key = Settings.twitter.consumer_key
      config.consumer_secret = Settings.twitter.consumer_secret
      config.access_token = current_user.access_token_key
      config.access_token_secret = current_user.access_token_secret
    end
  end
  def user
    @user ||= @client.user
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


  # 最初のfetch
  def fetch_user_datas
    count = 100
    @tweets = client.user_timeline count: count
    @favos = client.favorites count: count
    @favorares = @tweets.select{ |t| t.favorite_count > 0 }
    @rts_by_me = client.retweeted_by_me count: count
    @rts = @rts_by_me.map{ |r| r.retweeted_status }
    @rtrares = client.retweets_of_me count:count
  end
end
