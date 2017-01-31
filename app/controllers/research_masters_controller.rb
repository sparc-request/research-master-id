class ResearchMastersController < ApplicationController
  layout 'main'
  before_action :find_rm_records, only: [:index, :create, :update]

  def index
    respond_to do |format|
      format.html
    end
  end

  def show
    research_master = ResearchMaster.find(params[:id])
    associated_record = research_master.associated_record
    if associated_record.sparc_id?
      @sparc_protocol = Protocol.find(associated_record.sparc_id)
    end
    if associated_record.eirb_id?
      @eirb_protocol = Protocol.find(associated_record.eirb_id)
    end
    respond_to do |format|
      format.js
    end
  end

  def new
    @research_master = ResearchMaster.new
    @research_master.build_associated_record
    respond_to do |format|
      format.js
    end
  end

  def edit
    @research_master = ResearchMaster.find(params[:id])
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
    @research_master.user = current_user
    respond_to do |format|
      if @research_master.save
        rm_pi = create_rm_pi(params[:pi_name],
                             params[:pi_email],
                             params[:pi_department],
                             @research_master
                            )
        rm_notifier = ResearchMasterNotifier.new(rm_pi,
                                                 @research_master.user.email,
                                                 @research_master
                                                )
        rm_notifier.send_mail
        format.js
      else
        format.json { render json: { error: @research_master.errors }, status: 400 }
      end
    end
  end

  def destroy
    @research_master = ResearchMaster.find(params[:id])
    @research_master.destroy
  end

  def about
  end
  
  private

  def find_rm_records
    @q = ResearchMaster.ransack(params[:q])
    @research_masters = @q.result(distinct: true)
  end

  def create_rm_pi(name, email, department, rm_id)
    if name.present? && email.present?
      ResearchMasterPi.create(
        name: name,
        email: email,
        department: department,
        research_master: rm_id
      )
    end
  end

  def research_master_params
    params.require(:research_master).permit!
  end
end
