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

class Admin::ResearchMastersController < ApplicationController
  before_action :set_research_master, only: [:show, :edit, :update, :destroy]

  def index
    if params[:q] && params[:q][:combined_search_cont]
      params[:q][:combined_search_cont] = ResearchMaster.reformat_to_match_db(params[:q][:combined_search_cont])
    end
    @q = ResearchMaster.with_associations_for_search.ransack(params[:q])
    @research_masters = @q.result
                          .includes(:creator, :pi, :sparc_protocol, :eirb_protocol, :coeus_protocols, :cayuse_protocols)
                          .page(params[:page])
                          .per(25)
    respond_to do |format|
      format.html
      format.json { render json: @research_masters }
    end
  end

  def show
    research_master = ResearchMaster.find(params[:id])
      if research_master.sparc_protocol_id?
        @sparc_protocol = Protocol.find(research_master.sparc_protocol_id)
      end
      if research_master.eirb_protocol_id?
        @eirb_protocol = Protocol.find(research_master.eirb_protocol_id)
      end
    @coeus_records = research_master.coeus_protocols
    @cayuse_records = research_master.cayuse_protocols
    respond_to do |format|
      format.js { render 'admin/research_masters/show' }
    end
  end

  private

  def set_research_master
    @research_master = ResearchMaster.find(params[:id])
  end
end
