ActiveAdmin.register Order do
  menu false
  actions :none

  collection_action :new_from_admin, :title => "新規注文フォーム", method: :get do
    @order = Order.new
    @order.products.build
  end
end
