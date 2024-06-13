user = User.find_by(email: "store@example.com")

admin = User.find_or_create_by!(email: "admin@example.com") do |user|
  user.password = "123456"
  user.password_confirmation = "123456"
  user.role = :admin
end

["Orange Curry", "Belly King"].each do |store|
  seller_email = "#{store.split.map(&:downcase).join(".")}@example.com"
  seller = User.find_or_create_by!(email: seller_email) do |user|
    user.password = "123456"
    user.password_confirmation = "123456"
    user.role = :seller
  end
  Store.find_or_create_by!(name: store, user: seller)
end

{
  "Orange Curry" => ["Massaman Curry", "Risotto with Seafood", "Tuna Sashimi", "Fish and Chips", "Pasta Carbonara"],
  "Belly King" => ["Mushroom Risotto", "Caesar Salad", "Mushroom Risotto", "Tuna Sashimi", "Chicken Milanese"]
}.each do |store_name, dishes|
  store = Store.find_by(name: store_name)
  dishes.each do |dish|
    Product.find_or_create_by!(title: dish, store: store)
  end
end
