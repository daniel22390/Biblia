class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  delegate :current_user, :user_signed_in?, :to => :usuario_sessao
  helper_method :current_user, :user_signed_in?

  def usuario_sessao
		UsuarioSessao.new(session)
	end
end
