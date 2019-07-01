Rails.application.routes.draw do
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  #オーダーフォーム
  resource :order, only: [:create] do
    collection do
      get :completed

      post :re_option, path: :option
      post :re_design, path: :design
      post :re_address, path: :address
      post :re_customer_type, path: :customer_type

      post :is_confirmation
      post :is_option
      post :is_design
      post :is_address
      post :is_customer_type

      get :confirmation
      get :option
      get :design
      get :address
      get :customer_type

      get :top
      post :data_download
      post :create_from_admin
      post :update_from_admin
    end
  end
  get 'payment_confirm/:payment_token/' => 'orders#payment_confirm'
  post 'pay/:payment_token' => 'orders#pay'
  get 'payment_complete/:payment_token' => 'orders#payment_complete'


  root 'top#index'

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: '/letter_opener'
  end
end
