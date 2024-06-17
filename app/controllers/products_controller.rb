class ProductsController < ApplicationController
  before_action :authenticate!
  before_action :set_locale!

  def listing
    unless current_user.admin?
      redirect_to root_path, notice: "No permission for you! 🤪"
    end
    
    @products = Product.includes(:store)
  end

  def index
    respond_to do |format|
      
      format.html do
        @products = fetch_products
        render :index
      end
      format.json do
        if authorized_user?
          @store = Store.find(params[:store_id])
          @products = fetch_products
          @disabled_products = fetch_disabled_products if current_user.seller?
          render :index
        else
          render json: { message: "Not authorized" }, status: 401
        end
      end
    end
  end

  def create
    if authorized_seller?
      @store = Store.find(params[:store_id])
      @product = @store.products.new(product_params)

      if @product.save
        render json: { message: "Product created successfully" }, status: :created
      else
        render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def enable
    if authorized_seller?
      @product = Product.find(params[:id])
      if @product.update(enabled: true)
        render json: { message: "Product enabled successfully" }, status: :ok
      else
        render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def disable
    if authorized_seller?
      @product = Product.find(params[:id])
      if @product.update(enabled: false)
        render json: { message: "Product disabled successfully" }, status: :ok
      else
        render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  def destroy
    if authorized_seller?
      @product = Product.find(params[:id])
      if @product.destroy
        render json: { message: "Product deleted successfully" }, status: :ok
      else
        render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
      end
    end
  end

  private

  def fetch_products
    Product.where(store_id: params[:store_id]).order(:title).page(params.fetch(:page, 1))
  end

  def fetch_disabled_products
    Product.where(store_id: params[:store_id], enabled: false).order(:title).page(params.fetch(:page, 1))
  end

  def product_params
    params.require(:product).permit(:title, :price)
  end

  def authorized_user?
    buyer? || authorized_seller?
  end

  def buyer?
    (current_user && current_user.buyer?) && current_credential.buyer?
  end

  def authorized_seller?
    (current_user && current_user.seller?) && current_credential.seller?
  end
end
