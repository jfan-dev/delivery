# app/controllers/products_controller.rb
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
          render json: { 
            result: {
              products: @products, 
              disabled_products: @disabled_products, 
              store: @store,
              pagination: {
                current: @products.current_page,
                per_page: @products.limit_value,
                pages: @products.total_pages,
                count: @products.total_count,
                previous: @products.current_page > 1 ? (@products.current_page - 1) : nil,
                next: @products.current_page == @products.total_pages ? nil : (@products.current_page + 1)
              },
              disabled_pagination: @disabled_products ? {
                current: @disabled_products.current_page,
                per_page: @disabled_products.limit_value,
                pages: @disabled_products.total_pages,
                count: @disabled_products.total_count,
                previous: @disabled_products.current_page > 1 ? (@disabled_products.current_page - 1) : nil,
                next: @disabled_products.current_page == @disabled_products.total_pages ? nil : (@disabled_products.current_page + 1)
              } : nil
            }
          }
        else
          render json: { message: "Not authorized" }, status: 401
        end
      end
    end
  end

  def create
    @store = Store.find(params[:store_id])
    @product = @store.products.new(product_params)

    if @product.save
      render json: { message: "Product created successfully" }, status: :created
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def update
    @product = Product.find(params[:id])
    if @product.update(product_params)
      render json: { message: "Product updated successfully" }, status: :ok
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  def destroy
    @product = Product.find(params[:id])
    if @product.destroy
      render json: { message: "Product deleted successfully" }, status: :ok
    else
      render json: { errors: @product.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def fetch_products
    Product.where(store_id: params[:store_id], enabled: true).order(:title).page(params.fetch(:page, 1))
  end

  def fetch_disabled_products
    Product.where(store_id: params[:store_id], enabled: false).order(:title).page(params.fetch(:disabled_page, 1)).per(4)
  end

  def authorized_user?
    buyer? || seller?
  end

  def buyer?
    (current_user && current_user.buyer?) && current_credential.buyer?
  end

  def seller?
    (current_user && current_user.seller?) && current_credential.seller?
  end

  def product_params
    params.require(:product).permit(:title, :price, :enabled)
  end
end
