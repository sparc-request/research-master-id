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
    ldap_search = LdapSearch.new
    unless auth.uid.nil?
      email = auth.uid
    else
      email = ldap_search.employee_number_query(auth.info.employeeNumber)
    end
    where(email: email).first_or_create! do |user|
      user.password = Devise.friendly_token[0,20]
      user.net_id = email.split("@")[0]
    end
  end
end

