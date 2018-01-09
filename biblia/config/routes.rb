Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root :to => "home#index"
  get 'resultados' => 'principal#envia_termos'
  post 'cadastra_usuario' => 'usuario#cadastra_usuario'
  put 'atualiza_usuario' => 'usuario#atualiza_usuario'
  post 'login' => 'usuario_sessao#login'
  post 'logout' => 'usuario_sessao#logout'
end
