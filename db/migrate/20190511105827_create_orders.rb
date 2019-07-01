class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      #発注者情報
      t.boolean :customer_is_company, default: false #法人かどうか
      t.string :customer_name, null: false #顧客名 or 法人名
      t.string :customer_staff_name #担当者名(法人)
      t.string :customer_division_name #部署名(法人)
      t.string :customer_email, null: false #メールアドレス
      t.string :customer_tel, null: false #電話番号
      t.string :customer_zip, null: false #郵便番号
      t.string :customer_addr1, null: false #都道府県
      t.string :customer_addr2, null: false #市町村
      t.string :customer_addr3 #町域
      t.string :customer_addr4 #番地
      t.string :customer_addr5 #建物
      t.string :customer_addr #住所(結合)

      #配送先情報
      t.boolean :another_shipping, default: false #別送先があるか
      t.boolean :shipping_is_company, default: false
      t.string :shipping_name
      t.string :shipping_staff_name
      t.string :shipping_division_name
      t.string :shipping_tel
      t.string :shipping_zip
      t.string :shipping_addr1
      t.string :shipping_addr2
      t.string :shipping_addr3
      t.string :shipping_addr4
      t.string :shipping_addr5
      t.string :shipping_addr #住所(結合)

      #製作に関する情報
      t.integer :payment_type #決済方法
      t.integer :manufacture_plan #製作プラン
      t.integer :status, default: 0, null: false #進捗状況
      t.date :to_manufacture #製作開始日
      t.date :to_ship_date #発送予定日
      t.string :option #オプション注文
      t.string :memo #社内メモ

      t.boolean :ordered, default: false #管理画面に表示するか

      #クレカ決済用トークン
      t.string :payment_token
      t.boolean :paid_confirmation

      t.index :customer_email
      t.index :customer_name
      t.timestamps
    end

    create_table :products do |t|
      t.references :order, foreign_key: true
      t.string :design
      t.integer :quantity
      t.integer :size
      t.integer :item #商品
      t.integer :wrapping #包装
      t.integer :data_status, default: 0
      t.timestamps
    end

    create_table :sent_mails do |t|
      t.references :order, foreign_key: true
      t.string :subject
      t.text :text
      t.string :attachment1
      t.string :attachment2
      t.string :attachment3
      t.timestamps
    end

    create_table :received_mails do |t|
      t.references :order, foreign_key: true
      t.string :subject
      t.text :text
      t.string :attachment1
      t.string :attachment2
      t.string :attachment3
      t.timestamps
    end

  end
end
