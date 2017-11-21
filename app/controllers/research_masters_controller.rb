class ResearchMastersController < ApplicationController
  layout 'main'
  protect_from_forgery except: [:show, :new, :edit]
  before_action :find_rm_records, only: [:index, :create, :update]

  def index
    respond_to do |format|
      format.html
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
    @coeus_records = research_master.protocols
    respond_to do |format|
      format.js
    end
  end

  def new
    @research_master = ResearchMaster.new
    respond_to do |format|
      format.js
    end
  end

  def edit
    @research_master = ResearchMaster.find(params[:id])
    authorize! :update, @research_master
    respond_to do |format|
      format.js
    end
  end

  def update
    @research_master = ResearchMaster.find(params[:id])
    @research_master.update_attributes(research_master_params)
    respond_to do |format|
      if @research_master.save
        format.js
      else
        format.json { render json: { error: @research_master.errors }, status: 400 }
      end
    end
  end

  def create
    @research_master = ResearchMaster.new(research_master_params)
    @research_master.creator = current_user
    @research_master.pi = find_or_create_pi(params[:pi_email],
                                            params[:pi_name],
                                            Devise.friendly_token,
                                           )
    respond_to do |format|
      if @research_master.save
        SendEmailsJob.perform_later(@research_master.pi,
                                    @research_master.creator.email,
                                    @research_master
                                   )
        format.js
      else
        format.json { render json: { error: @research_master.errors }, status: 400 }
      end
    end
  end

  def destroy
    @research_master = ResearchMaster.find(params[:id])
    authorize! :destroy, @research_master
    if @research_master.sparc_protocol_id
      HTTParty.patch(
        "#{ENV.fetch('SPARC_URL')}/protocols/#{Protocol.find(@research_master.sparc_protocol_id).sparc_id}/research_master?access_token=#{ApiKey.first.access_token}"
      )
    end
    @research_master.destroy
  end

  private

  def find_rm_records
    @q = ResearchMaster.ransack(params[:q])
    @research_masters = @q.result(distinct: true).page(params[:page])
  end

  def find_or_create_pi(email, name, password)
    if email.present?
      user = User.create_with(password: password, password_confirmation: password).
        find_or_create_by(email: email)
      user.update_attribute(:name, name)
      user
    end
  end


  def research_master_params
    params.require(:research_master).permit!
  end
end
