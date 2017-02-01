require 'rails_helper'

describe LdapSearch do

  describe '#email_query' do
    it 'should return my email' do
      ldap_search = LdapSearch.new

      result = ldap_search.email_query('wih205')

      expect(result).to eq 'holtw@musc.edu'
    end

    it 'should return Jays email' do
      ldap_search = LdapSearch.new

      result = ldap_search.email_query('jjh200')

      expect(result).to eq 'hardeeje@musc.edu'
    end

    it 'should fail if invalid uid' do
      ldap_search = LdapSearch.new

      result = ldap_search.email_query('dfahlkfhdal')

      expect(result).to eq []
    end
  end

  describe '#info_query' do
    it 'should return my name' do
      ldap_search = LdapSearch.new

      result = ldap_search.info_query('will')

      expect(result).to include ['William Holt', 'holtw@musc.edu']
    end

    it 'should return my email' do
      ldap_search = LdapSearch.new

      result = ldap_search.info_query('will')

      expect(result).to include ['William Holt', 'holtw@musc.edu']
    end

    it 'should not return my name' do
      ldap_search = LdapSearch.new

      result = ldap_search.info_query('jer')

      expect(result).not_to include ['William Holt', 'holtw@musc.edu']
    end

    it 'should return Jays name' do
      ldap_search = LdapSearch.new

      result = ldap_search.info_query('jer')

      expect(result).to include ['Jerry Hardee', 'hardeeje@musc.edu']
    end
  end
end

