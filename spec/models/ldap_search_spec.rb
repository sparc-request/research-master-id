require 'rails_helper'

describe LdapSearch do

  describe '#info_query' do
    it 'should return a users info' do
      ldap_search = LdapSearch.new

      result = ldap_search.info_query('cates')

      expect(result).to include({name: "Andrew M. Cates", first_name: "Andrew", last_name: "Cates", middle_initial: "M.", email: "catesa@musc.edu", netid: "anc63", pvid: "900098838", active: true, affiliate: false})
    end

    it 'should not return a non-matching users info' do
      ldap_search = LdapSearch.new

      result = ldap_search.info_query('holt')

      expect(result).not_to include({name: "Andrew M. Cates", first_name: "Andrew", last_name: "Cates", middle_initial: "M.", email: "catesa@musc.edu", netid: "anc63", pvid: "900098838", active: true, affiliate: false})
    end
  end
end

