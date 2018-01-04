class UsuarioController < ApplicationController

	def cadastra_usuario
		retorno = Hash.new
		retorno[:status] = ""
		retorno[:message] = ""
		retorno[:data] = ""

		@cadastra_usuario = Usuario.new(usuario_params)

		if(@cadastra_usuario.valid? && @cadastra_usuario.save)
			retorno[:status] = "Success"
		  	retorno[:message] = "Cadastro efetuado com sucesso!"
		  	retorno = JSON.generate(retorno)
			render json: retorno
		else
			retorno[:status] = "Error"
		  	retorno[:message] = @cadastra_usuario.errors.first[1]
		  	retorno = JSON.generate(retorno)
			render json: retorno
		end
	end

	def usuario_params
      params.require(:usuario).permit(:nome, :email, :login, :nivel, :password, :password_confirmation)
    end

end