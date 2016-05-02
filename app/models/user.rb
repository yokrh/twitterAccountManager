class User < ActiveRecord::Base
  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      user.name = auth['info']['name']
      user.nickname = auth['info']['nickname']
    end
  end
  
  def add_access_token_data(auth)
    self.access_token_key = auth['extra']['access_token'].params[:oauth_token]
    self.access_token_secret = auth['extra']['access_token'].params[:oauth_token_secret]
    self.save
  end
  
  def delete_access_token_data
    self.access_token_key = nil
    self.access_token_secret = nil
    self.save
  end
end
