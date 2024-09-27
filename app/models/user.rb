# Copyright © 2020 MUSC Foundation for Research Development~
# All rights reserved.~

# Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:~

# 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.~

# 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following~
# disclaimer in the documentation and/or other materials provided with the distribution.~

# 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products~
# derived from this software without specific prior written permission.~

# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,~
# BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT~
# SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL~
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS~
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR~
# TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.~

class User < ApplicationRecord
  include DateFormatHelper

  audited
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:shibboleth]

  has_many :deleted_rmids
  has_many :protocols, foreign_key: :primary_pi_id

  attr_accessor :login

  ransacker :sort_name do |parent|
    Arel.sql("COALESCE(NULLIF(users.last_name, ''), NULLIF(users.name, ''), users.email)")
  end

  ransacker :combined_search do |parent|
    Arel::Nodes::NamedFunction.new(
      'CONCAT_WS',
      [
        Arel::Nodes.build_quoted(' '),
        Arel::Nodes::SqlLiteral.new("CAST(#{parent.table[:email].name} AS CHAR)"),
        Arel::Nodes::SqlLiteral.new("CAST(#{parent.table[:net_id].name} AS CHAR)"),
        Arel::Nodes::SqlLiteral.new("CAST(#{parent.table[:name].name} AS CHAR)"),
        Arel::Nodes::SqlLiteral.new("CAST(#{parent.table[:department].name} AS CHAR)"),
        Arel::Nodes::SqlLiteral.new("CAST(#{parent.table[:created_at].name} AS CHAR)"),
        Arel::Nodes::SqlLiteral.new("CAST(#{parent.table[:current_sign_in_at].name} AS CHAR)")
      ]
    )
  end

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

  def interfolio_user?
    LdapSearch.interfolio_users.any?{ |u| u['netid'] == self.net_id }
  end
end
