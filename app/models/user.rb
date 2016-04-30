class User < ActiveRecord::Base
  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      name = auth['info']['name']
      nickname = auth['info']['nickname']
    end
  end
end
