class DirectoriesController < ApplicationController

  def show
    ldap_search = LdapSearch.new
    @user_info = ldap_search.info_query(params[:name].chomp(" "))
  end
end

