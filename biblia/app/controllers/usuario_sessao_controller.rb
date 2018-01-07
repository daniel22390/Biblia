class UsuarioSessaoController < ApplicationController

	def login
		@session = UsuarioSessao.new(session, login_params)
		@session.authenticate
		redirect_to root_path	
	end

	def login_params
      params.require(:logar).permit(:login, :password)
    end

end