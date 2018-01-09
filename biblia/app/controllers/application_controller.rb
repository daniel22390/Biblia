class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  delegate :current_user, :user_signed_in?, :to => :usuario_sessao
  helper_method :current_user, :user_signed_in?

  	def usuario_sessao
		UsuarioSessao.new(session)
	end

	def require_authentication
		unless user_signed_in?
			redirect_to root_path, :alert => 'É necessário efetuar o login na aplicação!'
		end
	end
end
