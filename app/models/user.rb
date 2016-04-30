class User < ActiveRecord::Base
  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      name = auth['info']['name']
      nickname = auth['info']['nickname']
      access_token_key = auth['extra']['access_token'].params[:oauth_token]
      access_token_secret = auth['extra']['access_token'].params[:oauth_token_secret]
    end
  end
end
