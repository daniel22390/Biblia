class PrincipalController < ApplicationController
	before_action :require_authentication, :only => [:envia_termos]
	attr_accessor :array_resposta

	def envia_termos
		
		@resposta_principal = Principal.new(params, current_user)

		if @resposta_principal.valid?
			@resultado = @resposta_principal.busca
			@ranking = @resposta_principal.ranking
			@usuario = current_user
		else
			@resultado = Hash.new
			@resultado[:erro] = @resposta_principal.errors.first[1]
		end
			
	end

	def getPagina
		retorno = Hash.new
		retorno[:data] = Array.new

		versiculos = params[:versiculos]

		versiculos.each do |versiculo|
			verso = Versiculo.find(versiculo).as_json
			retorno[:data].push(verso)
		end

		retorno = JSON.generate(retorno)
		render json: retorno
	end

	def gera_marcacao
		retorno = Hash.new
		retorno[:status] = ""
		retorno[:data] = ""
		@marcacao = Marcacao.new(params)

		if @marcacao.valid?
			@resultado = @marcacao.gera_marcacao
			retorno[:status] = "Success"
		  	retorno[:data] = @resultado
		  	retorno = JSON.generate(retorno)
			render json: retorno
		else
			retorno[:status] = "erro"
		  	retorno[:data] = @marcacao.errors.first[1]
		  	retorno = JSON.generate(retorno)
			render json: retorno
		end
	end
end