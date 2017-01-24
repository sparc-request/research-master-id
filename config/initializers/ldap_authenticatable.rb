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
            admins = ENV.fetch('ADMINS').split(',')
            devs = ENV.fetch('DEVELOPERS').split(',')
            pwd = Devise.friendly_token
            user = User.create_with(password: pwd, password_confirmation: pwd, admin: false).find_or_create_by(email: "#{login}@musc.edu")
            if admins.any? { |word| login.include?(word) }
              user.update_attribute(:admin, true)
            end
            if devs.any? { |word| login.include?(word) }
              user.update_attribute(:developer, true)
            end
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
