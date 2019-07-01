module OrderFee
  extend ActiveSupport::Concern

  #----------------------数量集計---------------------------------------------

  #品目を「アイテム&サイズ」ごとに["アイテム", "サイズ", "単価", "個数"]のハッシュを返す
  #キャンセル状態の商品はあらかじめ
  def items_array
    self.products.where.not(data_status: "canceled").group(:item, :size).sum(:quantity).map do |k, h|
      price =
        case k[0]
        when "keyholder"
            case k[1]
            when "small"
              Constants::KEYHOLDER_SMALL
            when "medium"
              Constants::KEYHOLDER_MEDIUM
            when "large"
              Constants::KEYHOLDER_LARGE
            when "extra"
              Constants::KEYHOLDER_EXTRA
            when "small_ab"
              Constants::KEYHOLDER_SMALL_AB
            when "medium_ab"
              Constants::KEYHOLDER_MEDIUM_AB
            when "medium_ab"
              Constants::KEYHOLDER_LARGE_AB
            when "large_ab"
              Constants::KEYHOLDER_LARGE_AB
            when "extra_ab"
              Constants::KEYHOLDER_EXTRA_AB
            end
        when "coaster"
            Constants::COASTER
        end
        {item: k[0], size: k[1], price: price, quantity: h}
    end
  end

  #包装ごとに["包装種別", "単価", "個数"]のハッシュを返す
  #キャンセル状態の商品はあらかじめ除外する
  def wrappings_array
    self.products.where.not(data_status: "canceled").group(:wrapping).sum(:quantity).map do |k, h|
      price =
        case k
        when "nowrap"
          0
        when "unit_1"
          Constants::WRAP_UNIT_1
        end
      {wrapping: k, price: price, quantity: h}
    end
  end


  #----------------------金額計算---------------------------------------------

  #アイテム全体の小計
  def items_price
    self.items_array.map{ |array| array[:price] * array[:quantity] }.sum
  end

  #包装全体の小計
  def wrappings_price
    self.wrappings_array.map{ |array| array[:price] * array[:quantity] }.sum
  end

  #商品全体の合計
  def order_price
    items_price + wrappings_price
  end

  #送料
  def order_carriage
    #TODO: xx円以上で無料とかやるやつ
    Constants::CARRIAGE
  end

  #商品+送料
  def carriage_added_price
    order_price + Constants::CARRIAGE
  end

  def order_tax
    (carriage_added_price * (Constants::TAX - 1)).ceil
  end

  #合計
  def total_price
    carriage_added_price + order_tax
  end

end
