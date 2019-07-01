class SendMailer < ApplicationMailer
  extend ActiveSupport::Concern

  default from: '<order@example.com>'

  #入稿後の自動送信
  def draft_confirm(order)
    @order = order
    mail(to: @order.customer_email, subject: "ご送信の確認[ご注文番号: #{order.id}]")
  end

  #管理者から送るメール
  def send_notification(order, subject, text, mail)
    @order = order
    @text = text

    if Rails.env.production?
      attachments["#{File.basename(mail.attachment1.path)}"] = File.read(open(mail.attachment1.url)) if mail.attachment1.present?
      attachments["#{File.basename(mail.attachment2.path)}"] = File.read(open(mail.attachment1.url)) if mail.attachment2.present?
      attachments["#{File.basename(mail.attachment3.path)}"] = File.read(open(mail.attachment1.url)) if mail.attachment3.present?
    else
      attachments["#{File.basename(mail.attachment1.path)}"] = File.read(Rails.root.join("public#{mail.attachment1.url}")) if mail.attachment1.present?
      attachments["#{File.basename(mail.attachment2.path)}"] = File.read(Rails.root.join("public#{mail.attachment2.url}")) if mail.attachment2.present?
      attachments["#{File.basename(mail.attachment3.path)}"] = File.read(Rails.root.join("public#{mail.attachment3.url}")) if mail.attachment3.present?
    end

    mail(to: @order.customer_email, subject: subject)

  end

end
