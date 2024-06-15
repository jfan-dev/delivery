class StoresController < ApplicationController
  skip_forgery_protection only: %i[create update]
  before_action :authenticate!
  before_action :set_store, only: %i[ show edit update destroy ]

  # GET /stores or /stores.json
  def index
    if current_user.admin?
      @stores = Store.all
    else
      @stores = Store.where(user: current_user)
    end
  end

  # POST /stores or /stores.json
  def create
    @store = Store.new(store_params)
    @store.user = current_user unless current_user.admin?

    respond_to do |format|
      if @store.save
        format.html { redirect_to store_url(@store), notice: "Store was successfully created." }
        format.json { render :show, status: :created, location: @store }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_store
    @store = Store.find(params[:id])
  end

  def store_params
    required = params.require(:store)
    if current_user.admin?
      required.permit(:name, :user_id)
    else
      required.permit(:name)
    end
  end
end
