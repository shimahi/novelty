namespace :cleanup do
  desc "注文が確定してない注文レコードを削除"
  task order: :environment do
    Order.where.not(ordered: true).destroy_all
  end

end
