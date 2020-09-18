class MissionsController < ApplicationController
  before_action :authenticate_user!, except: [:index]
  before_action :only_for_client, only: [:new]

  def new
    @mission = Mission.new
  end

  def index
    @missions = Mission.where(user_id: current_user.id)
    @pending_missions = Mission.where(statut: nil)
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js {}
    end
  end

  def show 
    @mission = mission_finder
  end

  def create
    @mission = Mission.new(mission_params)
    @mission.user_id = current_user.id
    @mission.category = Category.last
    if @mission.save
      @amount = 1000
      customer = Stripe::Customer.create({
        email: params[:stripeEmail],
        source: params[:stripeToken],
      })

      charge = Stripe::Charge.create({
        customer: customer.id,
        amount: @amount,
        description: 'Rails Stripe customer',
        currency: 'chf',
      })
      redirect_to root_path
    end
    rescue Stripe::CardError => e
      flash[:error] = e.message
      redirect_to new_mission_path
  end

  def destroy
    @mission = mission_finder
    puts @mission
    respond_to do |format|
      format.html { redirect_to root_path }
      format.js {}
    end
    @mission.delete
  end

  def update
    @mission = mission_finder
    respond_to do |format|
      format.html {}
      format.js {}
    end
    @mission.update(statut: true)
  end

  private

  def mission_finder
    Mission.find(params[:id])
  end

  def only_for_client
    redirect_to root_path if current_user && (current_user.is_admin || current_user.employed)
  end

  def mission_params
    params.require(:mission).permit(:title, :start_date, :description)
  end
end