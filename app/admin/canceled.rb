ActiveAdmin.register Order, as: 'canceled' do
  menu priority: 6, label: -> { "キャンセル注文" }
  actions :all, except: [:new, :create, :edit, :update]
  permit_params :id, :customer_is_company, :customer_name,
                :customer_staff_name, :customer_division_name, :customer_email,
                :customer_tel, :customer_zip,
                :customer_addr1, :customer_addr2, :customer_addr3, :customer_addr4, :customer_addr5,
                :another_shipping,
                :shipping_is_company, :shipping_name, :shipping_staff_name, :shipping_division_name, :shipping_tel,
                :shipping_zip, :shipping_addr1, :shipping_addr2, :shipping_addr3, :shipping_addr4, :shipping_addr5,
                :payment_type, :manufacture_plan, :status, :to_manufacture,
                :to_ship_date, :option, :memo,
                products_attributes: [:id, :order_id, :item, :wrapping, :design, :quantity, :size, :data_status]
  filter :id, filters: ['equals']
  filter :customer_name
  filter :customer_is_company
  filter :customer_addr
  filter :created_at
  batch_action :destroy, false

  member_action :edit_memo, method: :get do
    @order = Order.find(params[:id])
    @memo = @order.memo
  end

  member_action :update_memo, method: :post do
    @order = Order.find(params[:id])
    @order.update(memo: params.permit(:memo)["memo"])
    redirect_to admin_canceled_path(@order)
  end

  controller do
    def scoped_collection
      super.canceled
    end
    def show
      @order = Order.find(params[:id])
      @mails = (@order.sent_mails + @order.received_mails).sort_by(&:created_at).reverse
      @page_title = "キャンセル #"+ @order.id.to_s
    end
  end

  index :title => "キャンセル注文" do
    selectable_column
    column "注文番号" do |order|
      link_to order.id, admin_canceled_path(order), class: :narrow
    end
    column "種別" do |order|
      order.customer_is_company ? "法人" : "個人"
    end
    column :status, sortable: false do |order|
      span class: :status_canceled do
        t "order.status.#{order.status}"
      end
    end
    column :manufacture_plan, sortable: false do |order|
      span class: :plan_tag do
        unless order.manufacture_plan == "normal"
          span class: :express_plan_tag do
            t "order.manufacture_plan.#{order.manufacture_plan}"
          end
        else
          span class: :normal_plan_tag do
            t "order.manufacture_plan.#{order.manufacture_plan}"
          end
        end
      end
    end
    column :payment_type, sortable: false do |order|
      t "order.payment_type.#{order.payment_type}"
    end
    column :customer_name, sortable: false
    column "配送先住所", sortable: false do |order|
      div do
        if order.another_shipping
          span do
            b do "[別送]" end
          end
          br do end
          span do
            "#{order.shipping_addr1}#{order.shipping_addr2}"
          end
          br do end
          span do
            "#{order.shipping_addr3}#{order.shipping_addr4}"
          end
          br do end
          span do
            order.shipping_addr5
          end
        else
          span do
            "#{order.customer_addr1}#{order.customer_addr2}"
          end
          br do end
          span do
            "#{order.customer_addr3}#{order.customer_addr4}"
          end
          br do end
          span do
            order.customer_addr5
          end
        end
      end
    end
    column :created_at
  end

  show do
    render "admin/canceleds/show"
  end

end
