require 'net/ldap'
require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable
      def authenticate!
        if params[:user]
          ldap = Net::LDAP.new(host: 'authldap.musc.edu',
                               port: 636,
                               encryption: 'simple_tls',
                               base: 'ou=people,dc=musc,dc=edu')
          ldap.auth "uid=#{login},ou=people,dc=musc,dc=edu", password
          if ldap.bind
            pwd = Devise.friendly_token
            user = User.create_with(password: pwd, password_confirmation: pwd).find_or_create_by(email: "#{login}@musc.edu")
            success!(user)
          else
            fail(:invalid_login)
          end
        end
      end

      def login
        params[:user][:login]
      end

      def password
        params[:user][:password]
      end
    end
  end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)
