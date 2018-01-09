class UsuarioSessaoController < ApplicationController

	def login
		@session = UsuarioSessao.new(session, login_params)
		@session.authenticate
		redirect_to root_path	
	end

	def logout
		usuario_sessao.destroy
		redirect_to root_path, :notice => 'Logout efetuado com sucesso. Ate logo!'
	end

	def login_params
      params.require(:logar).permit(:login, :password)
    end

end