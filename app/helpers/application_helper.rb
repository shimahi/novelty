module ApplicationHelper

  #フッターの表示/非表示判定
  def footer_need?
    controller.controller_name != 'orders'
  end
end
