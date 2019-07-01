require 'securerandom'

class Order < ApplicationRecord
  include OrderFee
  has_many :products, dependent: :destroy
  has_many :sent_mails, dependent: :destroy
  has_many :received_mails, dependent: :destroy
  accepts_nested_attributes_for :products, allow_destroy: true
  enum status: { newly: 0, answering: 1, constructing: 2, done: 3,canceled: 99 }
  enum payment_type: { card: 0, bank_transfer: 1, cod: 2 }
  enum manufacture_plan: { normal: 0, express: 1 }
  before_save :trim_memo
  before_create :generate_token


  #各種バリデーション
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :customer_is_company, inclusion: { in: [true, false] }, on: :is_customer_type
  validates :customer_name, presence: true, length: { maximum: 100 }, on: :is_address
  validates :customer_email, presence: true, length: { maximum: 100 }, format: { with: VALID_EMAIL_REGEX }, on: :is_address
  validates :customer_zip, presence: true, length: { maximum: 100 }, on: :is_address
  validates :customer_addr1, presence: true, length: { maximum: 100 }, on: :is_address
  validates :customer_addr2, presence: true, length: { maximum: 100 }, on: :is_address
  validates :customer_addr3, presence: true, length: { maximum: 100 }, on: :is_address
  validates :customer_tel, presence: true, length: { maximum: 100 }, on: :is_address
  validates :another_shipping, inclusion: { in: [true, false] }, on: :is_address

  validates :shipping_name, presence: true, length: { maximum: 100 }, on: :is_address, if: :another_shipping?
  validates :shipping_is_company, inclusion: { in: [true, false] }, on: :is_address, if: :another_shipping?
  validates :shipping_zip, presence: true, length: { maximum: 100 }, on: :is_address, if: :another_shipping?
  validates :shipping_addr1, presence: true, length: { maximum: 100 }, on: :is_address, if: :another_shipping?
  validates :shipping_addr2, presence: true, length: { maximum: 100 }, on: :is_address, if: :another_shipping?
  validates :shipping_addr3, presence: true, length: { maximum: 100 }, on: :is_address, if: :another_shipping?
  validates :shipping_tel, presence: true, length: { maximum: 100 }, on: :is_address, if: :another_shipping?

  validates :payment_type, presence: true, on: :is_option
  validates :manufacture_plan, presence: true, on: :is_option
  validates :option, length: { maximum: 1000 }, on: :is_option

  #enumフォーム値のlocale対応
  class << self
    def localed_status
      statuses.keys.map do |s|
        [I18n.t("order.status.#{s}"), s]
      end
    end

    def localed_payment_type
      payment_types.keys.map do |s|
        [I18n.t("order.payment_type.#{s}"), s]
      end
    end

    def localed_manufacture_plan
      manufacture_plans.keys.map do |s|
        [I18n.t("order.manufacture_plan.#{s}"), s]
      end
    end
  end

  def another_shipping?
    self.another_shipping == true
  end

  def customer_type
    self.customer_is_company ? "法人" : "個人"
  end

  def shipping_type
    #フォームによって初期値が変わったりするので、要確認
    self.shipping_is_company ? "法人" : "個人"
  end

  def join_customer_addr
    self.customer_addr = "#{self.customer_addr1}#{self.customer_addr2}#{self.customer_addr3}#{self.customer_addr4}#{self.customer_addr5}"
  end

  def join_shipping_addr
    tmp = "#{self.shipping_addr1}#{self.shipping_addr2}#{self.shipping_addr3}#{self.shipping_addr4}#{self.shipping_addr5}"
    if tmp.gsub(/\r\n|\r|\n|\s|\t/, "") == ""
      self.shipping_addr = nil
    else
      self.shipping_addr = tmp
    end
  end

  #メモ保存時に空白・改行をトリム
  def trim_memo
    if self.memo.present?
      self.memo.gsub!(/\r\n|\r|\n/, "")
      self.memo.strip!
    else
      self.memo = ""
    end
  end

  #データチェックが完了したか？
  def data_checked?
    self.products.map(&:data_status).exclude?("unchecked")
  end

  private
    def generate_token
      self.payment_token = SecureRandom.urlsafe_base64(64)
    end
end
