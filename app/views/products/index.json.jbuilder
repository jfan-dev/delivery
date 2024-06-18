json.result do
  if params[:page].present?
    json.pagination do
      current = @products.current_page
      total = @products.total_pages
      per_page = @products.limit_value

      json.current current
      json.per_page per_page
      json.pages total
      json.count @products.total_count
      json.previous (current > 1 ? (current - 1) : nil)
      json.next (current == total ? nil : (current + 1))
    end
  end

  json.store do
    json.id @store.id
    json.name @store.name
  end

  json.products do
    json.array! @products do |product|
      json.extract! product, :id, :title, :price, :enabled
    end
  end

  if @disabled_products
    json.disabled_products do
      json.array! @disabled_products do |product|
        json.extract! product, :id, :title, :price, :enabled
      end
    end
  end
end