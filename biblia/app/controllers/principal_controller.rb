class PrincipalController < ApplicationController
	def envia_termos
		
		@resposta_principal = Principal.new(params)

		if @resposta_principal.valid?
			@resultado = @resposta_principal.busca
		else
			@resultado = Hash.new
			@resultado[:erro] = @resposta_principal.errors.first[1]
		end
			
	end
end