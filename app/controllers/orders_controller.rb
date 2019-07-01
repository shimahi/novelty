class OrdersController < ApplicationController

  before_action :reset_order, only: [:address, :is_address, :design, :is_design, :option, :is_option, :confirmation, :create]

  def top
    session[:order] = nil
    session[:design_caches] = nil
  end

  def customer_type
    @order = Order.new
  end

  def is_customer_type
    @order = Order.new(order_params)
    session[:order] = @order
    if @order.valid?(:is_customer_type)
      redirect_to address_order_path
    else
      render :customer_type
    end
  end

  def address
    @order = Order.new(session[:order])
  end

  def is_address
    @order = Order.new(order_params)
    session[:order] = @order
    if @order.valid?(:is_address)
      redirect_to design_order_path
    else
      render :address
    end
  end

  def design
    @order = Order.new(session[:order])
    retrive_design_cache_from_session
  end

  def is_design
    @order = Order.new(order_params)
    store_caches_session
    session[:order] = @order
    if @order.valid?(:is_design)
      redirect_to option_order_path
    else
      render :design
    end
  end

  def option
    @order = Order.new(session[:order])
    retrive_design_cache_from_session
    session[:order] = @order
  end

  def is_option
    @order = Order.new(order_params)
    session[:order] = @order
    if @order.valid?(:is_option)
      redirect_to confirmation_order_path
    else
      render :option
    end
  end

  def confirmation
    @order = Order.new(session[:order])
    retrive_design_cache_from_session
  end

  def create
    @order = Order.new(order_params)
    retrive_design_cache
    synthesis_addr
    if @order.save
      @order.sent_mails.build()
      SendMailer.draft_confirm(@order).deliver_now
      @order.sent_mails.update(
        subject: SendMailer.draft_confirm(@order).subject,
        text: SendMailer.draft_confirm(@order).body
      )
      session[:order] = nil
      session[:design_caches] = nil
      session[:order_num] = @order.id
      redirect_to completed_order_path
    else
      render :confirmation
    end
  end

  def completed
    if session[:order_num]
      @order_num = session[:order_num]
    else
      redirect_to root_path
    end
  end

  def re_customer_type
    @order = Order.new(order_params)
    render :customer_type
  end

  def re_address
    @order = Order.new(order_params)
    render :address
  end

  def re_design
    @order = Order.new(order_params)
    retrive_design_cache
    render :design
  end

  def re_option
    @order = Order.new(order_params)
    retrive_design_cache
    render :option
  end

  #- - - - - - - - -管理画面からの操作- - - - - - - - -

  #デザインデータのダウンロード(管理画面)
  def data_download
    #ファイルの拡張子を除いた名前
    basename = File.basename(params[:design], ".*")
    #ファイルの拡張子
    extname = File.extname(params[:design])

    if Rails.env.production?
      filepath = params[:design]
    else
      #ローカルのストレージはpublic下
      #ローカルではデコードしないとファイルダウンロードできない
      filepath = "public#{URI.decode(params[:design])}"
    end
    data = open(filepath)

    type = extname.delete('.')
    case type
    when 'jpeg'
      filetype = 'image/jpeg'
    when 'jpg'
      filetype = 'image/jpg'
    when 'png'
      filetype = 'image/png'
    when 'gif'
      filetype = 'image/gif'
    when 'bmp'
      filetype = 'image/bmp'
    when 'psd'
      filetype = 'application/psd'
    when 'ai'
      filetype = 'application/ai'
    else
      filetype = data.content_type
    end
    #データ復元時のファイル名(拡張子)を本来のデータの奴に戻す
    filename = "#{basename}#{extname}"
    send_data data.read, type: filetype, filename: filename, x_sendfile: true
  end

  #代理注文の生成アクション
  def create_from_admin
    @order = Order.new(order_params)
    synthesis_addr
    if @order.save
      redirect_to "/admin/#{@order.status.pluralize}/#{@order.id}"
    else
      #render "/admin/#{@order.status.pluralize}/#{@order.id}/edit_from_admin"
    end
  end

  #管理画面からの更新アクション
  def update_from_admin
    @order = Order.find(order_params["id"])
    if @order.update(order_params)
      synthesis_addr
      @order.save
      redirect_to "/admin/#{@order.status.pluralize}/#{@order.id}"
    else
      render "/admin/#{@order.status.pluralize}/#{@order.id}/edit_from_admin"
    end
  end

  #- - - - - - - - -Stripe決済- - - - - - - - -

  #決済画面
  def payment_confirm
    @order = Order.find_by(payment_token: params[:payment_token])
  end

  #決済完了画面
  def pay
    @order = Order.find_by(payment_token: params[:payment_token])
    if @order.paid_confirmation
      redirect_to "/payment_confirm/#{@order.payment_token}", notice: "すでに決済処理を完了しています。"
      return
    end

    begin
      PaymentService.charge_stripe(@order, params[:stripeToken])
      @order.update(paid_confirmation: true)
      redirect_to "/payment_complete/#{@order.payment_token}"
    rescue => ex
      msg = "決済に失敗しました"
      msg += "\n" + ex.message if ex.message
      p ex.message if ex.message
      redirect_to "/payment_confirm/#{@order.payment_token}", alert: msg
    end
  end

  def payment_complete
    @order = Order.find_by(payment_token: params[:payment_token])
  end


  private
    def order_params
      params.require(:order).permit(
        :id,
        :customer_is_company, :customer_name, :customer_staff_name, :customer_division_name,
        :customer_email, :customer_tel, :customer_zip, :customer_addr1, :customer_addr2, :customer_addr3, :customer_addr4, :customer_addr5,
        :another_shipping, :shipping_is_company, :shipping_name, :shipping_staff_name, :shipping_division_name, :shipping_email, :shipping_tel, :shipping_zip,
        :shipping_addr1, :shipping_addr2, :shipping_addr3, :shipping_addr4, :shipping_addr5,
        :payment_type, :manufacture_plan, :status, :to_manufacture, :to_ship_date, :option, :ordered,
        products_attributes: [:id, :order_id, :item, :wrapping, :design, :quantity, :size, :_destroy, :design_cache]
        )
    end

    #セッションが切れたらリダイレクト
    def reset_order
      unless session[:order]
        redirect_to top_order_path, notice: "セッションが切れました。大変お手数ですが、再度オーダーするようお願い致します。"
        return
      end
    end

    #キャッシュから画像データを復元させる
    def retrive_design_cache
      @order.products.each do |product|
        if product.design_cache.present?
          product.design.retrieve_from_cache! product.design_cache if product.design.blank?
        end
      end
    end

    #セッションから画像データを復元させる
    def retrive_design_cache_from_session
      #セッションがなければ空build
      unless session[:design_caches]
        @order.products.build and return
      end
      session[:design_caches].each do |key, value|
        product = @order.products.build(value)
        if product.design.blank? && product.design_cache.present?
          product.design.retrieve_from_cache! product.design_cache
        end
      end
    end

    def store_caches_session
      #ハッシュのセッションを用意し、keyに対応したパラメータを格納する
      session[:design_caches] = {}
      @order.products.each_with_index do |product, index|
        #新しいデータはdesign_cacheがnilでcache_nameに値が入っているので
        #design_cacheをcache_nameメソッドから呼び出す
        product.design_cache = product.design.cache_name if product.design.cache_name.present?
        tmp = {item: product.item, size: product.size,
          quantity: product.quantity, wrapping: product.wrapping, design_cache: product.design_cache}
        session[:design_caches].store(index, tmp)
      end
    end

    #住所の結合
    def synthesis_addr
      @order.join_customer_addr
      @order.join_shipping_addr
    end
end
