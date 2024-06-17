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
          render :index
        else
          render json: { message: "Not authorized" }, status: 401
        end
      end
    end
  end

  private

  def fetch_products
    Product.where(store_id: params[:store_id]).order(:title).page(params.fetch(:page, 1))
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
end
