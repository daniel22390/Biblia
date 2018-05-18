class PesquisaController < ApplicationController

	def cadastra_pesquisa
		retorno = Hash.new
		retorno[:status] = ""
		retorno[:message] = ""
		retorno[:data] = ""

		@cadastra_pesquisa = Pesquisa.new(pesquisa_params)

		if(@cadastra_pesquisa.valid? && @cadastra_pesquisa.save)
		  	retorno = @cadastra_pesquisa.as_json
			render json: retorno
		else
			retorno[:status] = "Error"
		  	retorno[:message] = @cadastra_pesquisa.errors.first[1]
		  	retorno = JSON.generate(retorno)
			render json: retorno
		end
	end

	def pesquisa_params
      params.require(:pesquisa).permit(:pesquisado, :pesoExata, :pesoSinonimo, :pesoAntonimo, :pesoRadical, :pesoFlexao, :usuario_id)
    end
end