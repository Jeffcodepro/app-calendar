Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: "users/registrations" }

  root "dashboards#show"

  get "up" => "rails/health#show", as: :rails_health_check

  # Dashboard (singular)
  resource :dashboard, only: [:show]

  # Solicitações de férias (usuário logado)
  resources :vacation_requests, path: "ferias", only: [:index, :new, :create, :destroy] do
    member { patch :cancel }
  end


  # Calendário por grupo (agora inclui seguranca)
  get "calendario", to: "calendars#show", as: :calendar,
      constraints: { grupo: /(escritorio|gerentes|seguranca|admin)/ }

  # Admin
  namespace :admin do
    get 'users/index'
    get 'users/edit'
    # Admin NÃO cria admin por aqui. Só revisa/ajusta/aprova.
    resources :users, only: [:index, :edit, :update, :destroy] do
      member { patch :approve }
      collection { get :export_vacation_history }
    end

    get "email-approvals/users/:token", to: "email_approvals#approve_user", as: :email_approve_user
    get "email-approvals/ferias/:token/approve", to: "email_approvals#approve_vacation_request", as: :email_approve_vacation_request
    get "email-approvals/ferias/:token/reject", to: "email_approvals#reject_vacation_request", as: :email_reject_vacation_request

    # Admin gerencia solicitações (aprovar/recusar)
    resources :vacation_requests, path: "ferias", only: [:index, :show, :destroy] do
      member do
        patch :approve
        patch :reject
      end
    end
  end

  namespace :api do
    get "destinos", to: "destinations#index", as: :destinations
  end
end
