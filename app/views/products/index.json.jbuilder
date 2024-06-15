json.result do
  if params[:page].present?
    json.pagination do
      json.current @products.current_page
      json.per_page @products.limit_value
      json.pages @products.total_pages
      json.count @products.total_count
      json.previous (@products.current_page > 1 ? @products.current_page - 1 : nil)
      json.next (@products.current_page == @products.total_pages ? nil : @products.current_page + 1)
    end
  end

  json.products do
    json.array! @products do |product|
      json.extract! product, :id, :title
      json.price number_to_currency(product.price)
    end
  end
end