class PrincipalController < ApplicationController
	before_action :require_authentication, :only => [:envia_termos]
	attr_accessor :array_resposta

	def envia_termos
		
		@resposta_principal = Principal.new(params, current_user)

		if @resposta_principal.valid?
			@resposta_principal.busca_sinonimos
				# @resultado = @resposta_principal.busca_exata
				# @result_modal = @resposta_principal.resultado_secundario
				# @ranking = @resposta_principal.versiculo_banco
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
end