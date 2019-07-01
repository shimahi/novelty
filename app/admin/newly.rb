ActiveAdmin.register Order, as: 'newly' do
  menu priority: 2, label: -> { "新規注文" }
  actions :all, except: [:new, :create, :edit, :destroy] #updateメソッドはデータチェック更新で使う
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
  #filter :customer_is_company
  #filter :manufacture_plan, filters: ['equals']
  filter :customer_addr
  #filter :created_at
  batch_action :destroy, false

  member_action :upgrade_status, method: :post do
    @order = Order.find(params[:id])
    @order.answering!
    if @order.save
      redirect_to admin_answering_path(@order)
    end
  end

  member_action :edit_memo, method: :get do
    @order = Order.find(params[:id])
    @memo = @order.memo
  end

  member_action :update_memo, method: :post do
    @order = Order.find(params[:id])
    @order.update(memo: params.permit(:memo)["memo"])
    redirect_to admin_newly_path(@order)
  end

  #伝票発行--------------------------------------------------------------------------
  #TODO:ここではないが、送り状とかもやっとかないと
  member_action :estimate, method: :get do
    @order = Order.find(params[:id])
    report = Thinreports::Report.new(layout: "#{Rails.root}/app/pdfs/estimate.tlf")
    report.start_new_page
    report.page.item(:date).value(Date.today)
    report.page.item(:order_id).value(@order.id)
    report.page.item(:customer_name).value(@order.customer_name)
    report.page.item(:order_price).value("¥#{@order.order_price.to_s(:delimited)}")
    report.page.item(:order_carriage).value("¥#{@order.order_carriage.to_s(:delimited)}")
    report.page.item(:order_tax).value("¥#{@order.order_tax.to_s(:delimited)}")
    report.page.item(:total_price).value("¥#{@order.total_price.to_s(:delimited)}")
    @order.items_array.each do |array|
      report.list.add_row do |row|
        row.values item_unit: (t("order.size.#{array[:size]}") + t("order.item.#{array[:item]}")),
                   item_quantity: array[:quantity],
                   item_price: "¥#{array[:price].to_s(:delimited)}",
                   unit_price: "¥#{(array[:quantity] * array[:price]).to_s(:delimited)}"
      end
    end
    @order.wrappings_array.each do |array|
      if array[:wrapping] == "nowrap"
        next
      end
      report.list.add_row do |row|
        row.values item_unit: t("order.wrapping.#{array[:wrapping]}"),
                   item_quantity: array[:quantity],
                   item_price: "¥#{array[:price].to_s(:delimited)}",
                   unit_price: "¥#{(array[:quantity] * array[:price]).to_s(:delimited)}"
      end
    end
    file = report.generate
    send_data(
      file,
      filename: "estimate##{@order.id}.pdf",
      type: "application/pdf",
      disposition: "inline")
  end
  #---------------------------------------------------------------------------------

  member_action :new_mail, method: :get do
    @order = Order.find(params[:id])
    #データチェック未完了なら/showに飛ばす
    redirect_to "/admin/#{@order.status.pluralize}/#{@order.id}" unless @order.data_checked?
    @mail = @order.sent_mails.build
  end

  member_action :create_mail, method: :post do
    @order = Order.find(params[:id])
    @mail = @order.sent_mails.build
    mail_params = params.require(:sent_mail).permit(:subject, :text, :attachment1, :attachment2, :attachment3)
    @subject = mail_params["subject"]
    @text = mail_params["text"].gsub(/\r\n|\r|\n/, "<br />").html_safe
    @mail.attachment1 = mail_params["attachment1"]
    @mail.attachment2 = mail_params["attachment2"]
    @mail.attachment3 = mail_params["attachment3"]
    if @order.save
      SendMailer.send_notification(@order, @subject, @text, @mail).deliver_now
      @mail.update(
        subject: SendMailer.send_notification(@order, @subject, @text, @mail).subject,
        text: SendMailer.send_notification(@order, @subject, @text, @mail).body,
      )
      redirect_to admin_newly_path(@order)
    else
      render :new_mail
      p "失敗です。"
    end
  end

  #受信メール登録...ほんとは転送orAPIで簡単にしたい
  member_action :register_received_mail, method: :get do
    @order = Order.find(params[:id])
    @mail = @order.received_mails.build
  end
  member_action :save_received_mail, method: :post do
    @order = Order.find(params[:id])
    @subject = params.require(:received_mail).permit(:subject, :text)["subject"]
    @text = params.require(:received_mail).permit(:subject, :text)["text"].gsub(/\r\n|\r|\n/, "<br />").html_safe
    @order.received_mails.build(subject: @subject, text: @text)
    if @order.save
      redirect_to admin_newly_path(@order)
    else
      render :new_mail
      p "あぼーん"
    end
  end


  #編集
  member_action :edit_from_admin, :title => "編集フォーム", method: :get do
    @order = Order.find(params[:id])
  end

  #---------------------------------------------------------------------------------

  controller do
    def scoped_collection
      super.newly
    end
    def show
      @order = Order.find(params[:id])
      @mails = (@order.sent_mails + @order.received_mails).sort_by(&:created_at).reverse
      @page_title = "新規注文 #"+ @order.id.to_s
    end
  end

  #代理注文
  action_item :proxy_order, only: :index do
    link_to '代理注文', new_from_admin_admin_orders_path
  end

  action_item :edit_from_admin, only: :show do
    link_to '注文を編集する', edit_from_admin_admin_newly_path
  end

  index :title => "新規注文" do
    selectable_column
    column "注文番号" do |order|
      link_to order.id, admin_newly_path(order), class: :narrow
    end
    column "種別" do |order|
      order.customer_is_company ? "法人" : "個人"
    end
    column :status, sortable: false do |order|
      span class: :status_newly do
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
    render "admin/newlies/show"
  end

end
