class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  has_many :friends, dependent: :destroy

  has_many :musics, dependent: :destroy
  has_many :sources,
    through: :musics

  has_many :categories

  has_many :categorizations,
    through: :categories

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  # Following line makes your model fb-omniauthable
  devise :omniauthable, :omniauth_providers => [:facebook]

  def self.find_for_facebook_oauth(auth)
    where(auth.slice(:provider, :uid)).first_or_create do |user|
        user.provider = auth.provider
        user.uid = auth.uid
        user.email = auth.info.email
        user.password = Devise.friendly_token[0,20]
        user.first_name = auth.info.first_name
        user.name = auth.info.name   # assuming the user model has a name
        user.picture = auth.info.image # assuming the user model has an image
        user.token = auth.credentials.token
        user.token_expiry = Time.at(auth.credentials.expires_at)
    end
  end

end
