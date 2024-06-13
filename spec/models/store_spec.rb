require 'rails_helper'
require 'faker'

RSpec.describe Store, type: :model do
  describe "validations" do
    it { should validate_presence_of(:name) }
    it { should validate_length_of(:name).is_at_least(3) }

    it "is valid with a valid name" do
      store = Store.new(name: Faker::Restaurant.name)
      expect(store).to be_valid
    end
  end
end
