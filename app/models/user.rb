class User < ApplicationRecord
  audited
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:shibboleth]

  has_many :deleted_rmids

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
    user = ldap_search.employee_number_query(auth.info.employeeNumber)
    where(email: user[:mail]).first_or_create(password: Devise.friendly_token[0,20], net_id: user[:netid], name: [user[:first_name], user[:last_name]].join(' '), first_name: user[:first_name],
                                             last_name: user[:last_name], middle_initial: user[:middle_initial], pvid: user[:pvid])
  end

  def research_masters
    ResearchMaster.where("creator_id = ? OR pi_id = ?", self.id, self.id)
  end

  def prism_user?
    LdapSearch.prism_users.any?{ |u| u['netid'] == self.net_id }
  end
end
