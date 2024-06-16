class OrderWorker
  include Sidekiq::Worker

  def perform(order_id)
    order = Order.find(order_id)
    # Process order logic here
    # ...
  end
end