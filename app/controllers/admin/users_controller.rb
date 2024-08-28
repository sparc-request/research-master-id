class Admin::UsersController < ApplicationController
  def index
    @q = User.ransack(params[:q])
    @users = @q.result.page(params[:page]).per(25)
    respond_to do |format|
      format.html
      format.json { render json: @users }
    end
  end

  def show
    if params[:source] == 'pi_name'
      db_search = DatabaseSearch.new
      @user_info = db_search.user_query(params[:name].strip)
    else
      ldap_search = LdapSearch.new
      @user_info = ldap_search.info_query(params[:name].strip, true, false, params[:search_term])
    end
  end
end
