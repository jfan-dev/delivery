json.order do
  json.id @order.id
  json.store_id @order.store_id
  json.buyer_id @order.buyer_id
  json.created_at @order.created_at
  json.updated_at @order.updated_at
end