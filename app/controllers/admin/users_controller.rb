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

class Admin::UsersController < ApplicationController
  def index
    if params[:q] && params[:q][:combined_search_cont]
      params[:q][:combined_search_cont] = User.reformat_to_match_db(params[:q][:combined_search_cont])
    end
    @q = User.ransack(params[:q])

    if params[:q] && params[:q][:s]
      if params[:q][:s].include?('desc')
        @q.sorts = ['sort_name desc', 'first_name desc']
      else
        @q.sorts = ['sort_name asc', 'first_name asc']
      end
    else
      @q.sorts = ['sort_name asc', 'first_name asc']
    end

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
