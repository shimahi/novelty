class Product < ApplicationRecord
  belongs_to :order
  enum data_status: { unchecked: 0, checked: 1, error: 2, caution: 3, unconfirmed: 4, canceled: 99 }
  enum item: { keyholder: 0, coaster: 1 }
  enum size: { small: 0, medium: 1, large: 2, extra: 3, small_ab: 4, medium_ab: 5, large_ab: 6, extra_ab: 7, coaster_size: 99 }
  enum wrapping: { nowrap: 0, unit_1: 1 }
  attr_accessor :design_cache
  mount_uploader :design, DesignUploader
  before_save :set_coaster_size

  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 10 }
  validate :design_data_must_be

  def design_data_must_be
    if design.blank? && design_cache.blank?
      errors.add(:design, "を入力してください")
    end
  end

  #selectフォーム値のlocale対応
  class << self
    def localed_data_statuses
      data_statuses.keys.map do |s|
        [I18n.t("order.data_status.#{s}"), s]
      end
    end

    def localed_items
      items.keys.map do |s|
        [I18n.t("order.item.#{s}"), s]
      end
    end

    def localed_sizes
      #コースターの場合のサイズをフォームのselectから除外する
      sizes.except(:coaster_size).keys.map do |s|
        [I18n.t("order.size.#{s}"), s]
      end
    end

    def localed_wrappings
      wrappings.keys.map do |s|
        [I18n.t("order.wrapping.#{s}"), s]
      end
    end
  end

  #コースターの注文は保存する前にサイズをcoaster_sizeにする
  def set_coaster_size
    if self.item == "coaster"
      self.size = "coaster_size"
    end
  end

  #design文字列からルートを引いた文字列(ファイル名)を返す
  def file_name
    name = self.design.to_s
    if Rails.env.production?
      name.slice!("#{Rails.application.credentials.conoha[:container]}/uploads/product/design/#{self.id}/")
    else
      name.slice!("/uploads/product/design/#{self.id}/")
    end
    URI.decode(name)
  end


  #ファイル形式
  def file_type
    type = File.extname(self.design.to_s)
    type.slice!(0)
    type
  end

  #ファイルが画像ファイルか判定する
  def image_file?
    %w(.png .gif .jpg .jpeg .bmp).include?(File.extname(self.design.to_s))
  end

end
