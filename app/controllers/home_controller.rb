require 'twitter'

class HomeController < ApplicationController
  helper_method :client, :user, :favos, :favorares, :rts, :rtrares

  def index
    return unless current_user
    fetch_user_datas
  end

  # 検索の絞り込み
  def index_ajax
    return unless current_user

    fetch_user_favos_all if params[:object] == 'favos'
    fetch_user_favorares_all if params[:object] == 'favorares'
    #fetch_user_rts_all if params[:object] == 'rts'
    #fetch_user_rtrares_all if params[:object] == 'rtrares'

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

  # 可能な限りのfetch
  # favo
  def fetch_user_favos_all
    count = 200
    @favos = client.favorites(count: count)
    20.times do
      max_id = @favos.last.id 
      res = client.favorites(max_id: max_id, count: count)
      @favos.concat(res).uniq!
    end
  end
  # favorare
  def fetch_user_favorares_all
    count = 200
    @tweets = client.user_timeline(count: count)
    20.times do
      max_id = @tweets.last.id unless @tweets.empty?
      res = client.user_timeline(max_id: max_id, count: count)
      @tweets.concat(res).uniq!
    end
    @favorares = @tweets.select{ |t| t.favorite_count > 0 }
  end
  # rt
  def fetch_user_rts_all
    count = 200
    @rts_by_me = client.retweeted_by_me(count: count)
    20.times do
      max_id = @rts_by_me.last.id unless @rts_by_me.empty?
      res = client.retweeted_by_me(max_id: max_id, count: count)
      @rts_by_me.concat(res).uniq!
    end
    @rts = @rts_by_me.map{ |r| r.retweeted_status }
  end
  # rts
  def fetch_user_rtrares_all
    count = 200
    @rtrares = client.retweets_of_me(count: count)
    20.times do
      max_id = @rtrares.last.id unless @rtrares.empty?
      res = client.retweets_of_me(max_id: max_id, count: count)
      @rtrares.concat(res).uniq!
    end
  end
end
