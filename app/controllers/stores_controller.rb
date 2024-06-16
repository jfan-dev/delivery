class StoresController < ApplicationController
  include ActionController::Live

  skip_forgery_protection only: %i[create update]
  before_action :authenticate!
  before_action :set_store, only: %i[ show edit update destroy ]
  rescue_from User::InvalidToken, with: :not_authorized

  def index
    @stores = if current_user.seller?
                Store.where(user: current_user)
              else
                Store.joins(:user).where(users: { role: 'seller' })
              end
  end

  # GET /stores/1 or /stores/1.json
  def show
    @store = Store.find(params[:id])
    @products = @store.products.page(params[:page]).per(8)
  end

  # GET /stores/new
  def new
    @store = Store.new
    if current_user.admin?
      @sellers = User.where(role: :seller)
    end
  end

  # GET /stores/1/edit
  def edit
  end

  # POST /stores or /stores.json
  def create
    @store = Store.new(store_params)
    if !current_user.admin?
      @store.user = current_user
    end

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

  # PATCH/PUT /stores/1 or /stores/1.json
  def update
    respond_to do |format|
      if @store.update(store_params)
        format.html { redirect_to store_url(@store), notice: "Store was successfully updated." }
        format.json { render :show, status: :ok, location: @store }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @store.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stores/1 or /stores/1.json
  def destroy
    @store.destroy!

    respond_to do |format|
      format.html { redirect_to stores_url, notice: "Store was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def new_order
    response.headers["Content-Type"] = "text/event-stream"
    sse = SSE.new(response.stream, retry: 300, event: "waiting-orders")

    EventMachine.run do
      EventMachine::PeriodicTimer.new(3) do
        order = Order.last
        if order
          message = { time: Time.now, order: order }
          sse.write(message, event: "new-order")
        else
          sse.write({ message: "No new orders" }, event: "no-order")
        end
      end
    end
  rescue IOError, ActionController::Live::ClientDisconnected
    sse.close
  ensure
    sse.close
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
