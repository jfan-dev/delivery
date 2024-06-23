admin = User.find_or_create_by!(email: "admin@example.com") do |user|
  user.password = "123456"
  user.password_confirmation = "123456"
  user.role = :admin
end

["Go Jira", "Pan Dah"].each do |buyer|
  email = buyer.split.map { |s| s.downcase }.join(".")
  user = User.find_by(email: email)
  
  if !user
    user = User.new(
      email: "#{email}@example.com",
      password: "123456",
      password_confirmation: "123456",
      role: :buyer
    )
    user.save!
  end
end

store_names = [
  "Fresh Bites", "Urban Grills", "Savory Delights", "Flavor Feast", "Gourmet Palace",
  "Taste Haven", "Epicurean Treats", "Heavenly Bites", "Yummy Yards", "Culinary Crave",
  "Delish Hub", "Bistro Bites", "Cuisine Magic", "Elite Eats", "Feast Paradise",
  "Grill Masters", "Snack Corner", "Divine Dine", "Master Meals", "Nibble Corner",
  "Orange Curry", "Belly King"
]

products = [
  "Chicken Parmesan", "Seafood Paella", "Spicy Tuna Roll", "Grilled Salmon", "Pasta Primavera",
  "Truffle Risotto", "Greek Salad", "Pork Schnitzel", "Lamb Chops", "Margherita Pizza",
  "Fettuccine Alfredo", "Fish Tacos", "Tom Yum Soup", "Steak Diane", "Duck Confit",
  "Baby Back Ribs", "Moussaka", "Chow Mein", "Spring Rolls", "Baked Trout"
]

store_names.each do |store|
  seller_email = "#{store.split.map(&:downcase).join(".")}@example.com"
  seller = User.find_or_create_by!(email: seller_email) do |user|
    user.password = "123456"
    user.password_confirmation = "123456"
    user.role = :seller
  end

  store_record = Store.find_or_create_by!(name: store, user: seller)

  products.each do |product|
    price = rand(5.99..49.99).round(2)
    Product.find_or_create_by!(title: product, store: store_record) do |p|
      p.price = price
    end
  end
end
