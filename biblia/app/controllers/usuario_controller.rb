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

	def atualiza_usuario
		retorno = Hash.new
		retorno[:status] = ""
		retorno[:message] = ""
		retorno[:data] = ""

		@atualiza_usuario = Usuario.update(current_user.id, usuario_params)

		if(@atualiza_usuario.valid?)
			retorno[:status] = "Success"
		  	retorno[:message] = "Pesos atualizados com sucesso!"
		  	retorno = JSON.generate(retorno)
			render json: retorno
		else
			retorno[:status] = "Error"
		  	retorno[:message] = @cadastra_usuario.errors.first[1]
		  	retorno = JSON.generate(retorno)
			render json: retorno
		end

	end

	def remove_mensagem
		@remove_mensagem = Usuario.update(current_user.id, :mensagem => 'N')
	end

	def usuario_params
      params.require(:usuario).permit(:nome, :email, :login, :nivel, :password, :password_confirmation, :pesoExata, :pesoSinonimo, :pesoAntonimo, :pesoRadical, :pesoFlexao, :mensagem)
    end

end