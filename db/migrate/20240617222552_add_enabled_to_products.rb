class AddEnabledToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :enabled, :boolean
  end
end
