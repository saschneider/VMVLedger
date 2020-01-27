#
# Application routes file.
#
# @author Matthew Casey
#
# (c) University of Surrey 2019
#

Rails.application.routes.draw do

  # Provide a route for robots.txt.
  mount_roboto

  # Provide the Devise routes.
  devise_for :users,
             path:        '',
             path_names:  { sign_in:      'login',
                            sign_out:     'logout',
                            registration: 'registration',
                            sign_up:      'sign_up_account' },
             controllers: { registrations: 'users/registrations' }

  # Define the home, about and privacy pages.  Note that root is especially needed for Devise.
  get 'home', to: 'home#home', as: 'home'
  get 'about', to: 'home#about', as: 'about'
  get 'documents', to: 'home#documents', as: 'documents'
  get 'introduction', to: 'home#introduction', as: 'introduction'
  get 'privacy', to: 'home#privacy', as: 'privacy'
  get 'verifiable', to: 'home#verifiable', as: 'verifiable'
  root to: redirect(path: '/home')

  # Define user account pages.
  resources :users, only: [:index, :edit, :update, :destroy]
  resources :invitations, except: [:show]

  # Define service pages.
  resources :services, only: [:edit, :update]

  # Define election pages and associated data.
  resources :audit_logs, only: [:index]
  resources :file_types
  resources :elections
  resources :uploads, except: [:destroy] do
    resources :contents, shallow: true, only: [:index, :show]
    member do
      get :blockchain
      get :download
      post :recommit
      post :retrieve
    end
  end

  # Define the voter verification routes.
  get 'verify', to: 'verify#verify'
  get 'verify/status', to: 'verify#status'
  get 'verify/faq', to: 'verify#faq'
  get 'verify/report_my_vote', to: 'verify#report_my_vote'
  post 'verify/send_report', to: 'verify#send_report'

  # Match certbot challenge responses.
  get '/.well-known/acme-challenge/*file', to: 'home#challenge', as: 'challenge'

  # Catch anything else and send it to the UI root, unless in development mode. Note that we explicitly ignore ActiveStorage as its routes are added afterwards.
  unless Rails.env.development?
    match "*path", to: 'application#not_found', via: :all, constraints: lambda { |request|
      request.path.exclude? 'rails/active_storage'
    }
  end
end
