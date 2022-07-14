Rails.application.routes.draw do
  devise_for :users,
             path: 'users',
            #  path_names: {
            #    sign_in: 'login',
            #    sign_out: 'logout',
            #    registration: 'signup'
            #  },
            #  controllers: {
            #    sessions: 'users/sessions',
            #    registrations: 'users/registrations',
            #    passwords: 'users/passwords'
            #  },
             skip: [:sessions, :passwords, :registrations, :confirmations]
  
  as :user do
    post '/users/sign_in', :to => 'users/sessions#create', :as => 'user_session'
    post '/users/registration', :to => 'users/registrations#create'
    delete '/users/sign_out', :to => 'users/sessions#destroy', :as => 'destroy_user_session'
    put '/users/password', :to => 'users/passwords#update', :as => 'user_password'
    post '/users/password', :to => 'users/passwords#create'
    get '/users/confirmation', :to => 'users/confirmations#show', :as => 'user_confirmation'
    post '/users/confirmation', :to => 'users/confirmations#create'

    get '/users/sign_in', :to => 'static#index', :as => 'new_user_session'
    get '/users/password/edit', :to => 'static#index', :as => 'edit_user_password'
  end

  namespace :user_center do
    put 'reset_password'
    put 'update_profile'
    post 'get_all_users'
    get 'info'
  end

  namespace :configuration do
    post 'list'
    post 'option_page_list'
    put 'update'
    delete 'delete'
    post 'create'
    post 'update'
    post 'copy'
    get 'prove'
    post 'operations'
    get 'option_list'
    post 'option_add'
    post 'option_add_json'
    post 'option_update'
    delete 'option_delete'
    post 'dy_option_list'
  end

  namespace :operation do
    post 'list'
    put 'update'
    post 'copy'
    delete 'delete'
    post 'create'
    post 'dy_option_list'
    get 'option_list'
    post 'option_add'
    put 'option_update'
    delete 'option_delete'
    get 'option_all'
    post 'permit_group'
    post 'executions'
    post 'group_tree'
    post 'validate_engine_conf'

    post 'output_list'
    post 'output_add'
    post 'output_update'
    post 'output_delete'

    post 'nodes_list'
    post 'nodes_add'
    post 'nodes_delete'
    post 'nodes_options'
  end

  namespace :ticket_task do
    post 'list'
    post 'create'
    post 'delete'
    post 'task_list'
    post 'task_log'
    post 'task_create'
    post 'task_kill'
    # post 'task_options'
    post 'import'
    get 'task_summary'
    post 'attach_config'
    get 'config_list'
    get 'delete_config'
    post 'getJiraOptions'
    post 'operation_list'
    post 'utility_config_list'
  end

  namespace :schedule do
    post 'list'
    post 'create'
    put 'update'
    put 'disable'
    put 'enable'
    post 'task_list'
    post 'get_timeline'
  end

  namespace :option do
    post 'list'
    post 'create'
    put 'update'
    delete 'delete'
    get 'get_group_names'
    post 'show'
    get 'rule_list'
    post 'rule_create'
    put 'rule_update'
    delete 'rule_delete'
  end

  namespace :task do
    post 'list'
    post 'get_detail'
    post 'release'
    post 'getAzkabanFlow'
  end

  namespace :release_management do
    post 'get_envs'
    post 'get_latest_release_info'
  end

  namespace :management do
    namespace :permissions do
      get 'get_permissions'
      post 'create'
      post 'update'
      post 'delete'
      post 'reparent'
    end
    namespace :roles do
      post 'get_related_permission'
      post 'get_records'
      post 'destroy'
      post 'create'
      post 'update'
      post 'all'
    end
    namespace :users do
      post 'create'
      post 'update'
      post 'get_records'
      post 'lock'
      post 'approve'
      post 'unlock'
      post 'destroy'
    end
    namespace :operation_history do
      post 'get_summary'
      post 'get_records'
    end
    namespace :operation_group do
      post 'user_group_permission_list'
      post 'user_group_create'
      post 'user_group_destroy'
      post 'user_list'
      post 'list'
      post 'create'
      post 'update'
      post 'delete'
      post 'tree'
      post 'tree_search'
    end
    namespace :login_history do
      post 'get_records'
    end
  end

  get '/', to: 'static#index'
  get '/health/check', to: 'health#check'
  get '*other', to: 'static#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
