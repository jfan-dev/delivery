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
      @products = Product.where(store_id: params[:store_id]).order(:title).page(params.fetch(:page, 1))
      
      format.html do
        render :index
      end
      format.json do
        if buyer?
          page = params.fetch(:page, 1)
          @products = Product
            .where(store_id: params[:store_id])
            .order(:title)
            .page(page)
          
          render :index
        else
          render json: { message: "Not authorized" }, status: 401
        end
      end
    end
  end

  private

  def buyer?
    (current_user && current_user.buyer?) && current_credential.buyer?
  end
end
