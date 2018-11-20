class DirectoriesController < ApplicationController

  def show
    ldap_search = LdapSearch.new
    prism_users = HTTParty.get("#{ENV.fetch("COEUS_API")}/prism", timeout: 500, headers: {'Content-Type' => 'application/json'})
    @user_info = ldap_search.info_query(params[:name], prism_users)
  end
end

