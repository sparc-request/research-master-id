class User < ApplicationRecord
  audited
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:shibboleth]


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
    ldap_search = LdapSearch.new
    email       = auth.info.email.blank? ? auth.uid : auth.info.email

    where(email: email).first_or_create! do |user|
      user.password = Devise.friendly_token[0,20]
      user.net_id   = auth.uid
      user.name     = [auth.info.first_name, auth.info.last_name].join(' ')
    end
  end

  def research_masters
    ResearchMaster.where("creator_id = ? OR pi_id = ?", self.id, self.id)
  end

  def prism_user?
    LdapSearch.prism_users.any?{ |u| u['netid'] == self.net_id }
  end
end
