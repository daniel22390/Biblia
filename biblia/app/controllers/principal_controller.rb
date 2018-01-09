class PrincipalController < ApplicationController
	before_action :require_authentication, :only => [:envia_termos]

	def envia_termos
		
		@resposta_principal = Principal.new(params)

		if @resposta_principal.valid?
			@array_resposta = @resposta_principal.busca_exata
			@resultado = @array_resposta[0...10]

		else
			@resultado = Hash.new
			@resultado[:erro] = @resposta_principal.errors.first[1]
		end
			
	end
end