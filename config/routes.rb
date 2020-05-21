Rails.application.routes.draw do
  devise_for :users,
           path: '',
           path_names: {
             sign_in: 'login',
             sign_out: 'logout',
             registration: 'signup'
           },
           controllers: {
             sessions: 'user/sessions',
             registrations: 'user/registrations'
           }
  resources :contacts
  resources :projects
  resources :transactions

  devise_scope :user do 
    get '/userinfo', to: 'user/sessions#user_info'
  end
  
  get '/switch-company', to: 'companies#switch_company'
  get '/companies', to: 'companies#index'
  patch '/companies/:id', to: 'companies#update'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
