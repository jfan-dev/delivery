user = User.find_by(email: "store@example.com")
if !user
  user = User.new(
    email: "store@example.com",
    password: "123456",
    password_confirmation: "123456"
  )
  user.save!
end

["Orange Curry", "Belly King"].each do |store|
  Store.find_or_create_by!(name: store, user: user)
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
