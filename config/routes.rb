Rails.application.routes.draw do
  get "line_notification/send_notification"
  get "friendships/index"
  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords",
    omniauth_callbacks: "omniauth_callbacks"
  }

  resources :users do
    member do
      post :toggle_friendship, to: "users#toggle_friendship"
    end
  end

  resources :events do
    member do
      post "toggle_registration", to: "events#toggle_registration" # 募集中/募集終了の切り替え
      post "toggle_participation", to: "events#toggle_participation" # 参加する/参加中の切り替え
    end
    collection do
      get "past", to: "events#past_index"
      get "calendar", to: "events#calendar"
    end
  end

  resources :groups

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest

  # Defines the root path route ("/")
  # root "posts#index"

  root "static_pages#top"
  get "terms_of_service", to: "static_pages#terms_of_service"
  get "privacy_policy", to: "static_pages#privacy_policy"
  post "line_notification/send_notification", to: "line_notification#send_notification"

  if Rails.env.development?
    mount LetterOpenerWeb::Engine, at: "/letter_opener"
  end
end
