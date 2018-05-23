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

	def altera_ranking
		retorno = Hash.new
		retorno[:status] = ""
		retorno[:message] = ""
		retorno[:data] = ""

		@altera_ranking = Pesquisa_has_versiculo.new(altera_params)

		if(@altera_ranking.valid? && @altera_ranking.save)
		  	retorno = @altera_ranking.as_json
			render json: retorno
		else
			retorno[:status] = "Error"
		  	retorno[:message] = @altera_ranking.errors.first[1]
		  	retorno = JSON.generate(retorno)
			render json: retorno
		end
	end

	def pesquisa_params
      params.require(:pesquisa).permit(:pesquisado, :pesoExata, :pesoSinonimo, :pesoAntonimo, :pesoRadical, :pesoFlexao, :usuario_id)
	end
	
	def altera_params
		params.require(:pesquisa).permit(:versiculo_id, :pesquisa_id, :peso, :pos_atual, :pos_original)
	  end
end