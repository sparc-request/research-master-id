class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:shibboleth]
  has_many :research_masters

  attr_accessor :login

  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions.to_hash).where(["lower(email) = :value", { value: login.downcase }]).first
    elsif conditions.has_key?(:email)
      where(conditions.to_hash).first
    end
  end

  def self.from_omniauth(auth)
    where(email: auth.uid).first_or_create! do |user|
      user.email = auth.uid
      user.password = Devise.friendly_token[0,20]
      user.name = "#{auth.info.first_name} #{auth.info.last_name}"
    end
  end
end

