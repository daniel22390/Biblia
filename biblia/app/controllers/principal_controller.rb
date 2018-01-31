class PrincipalController < ApplicationController
	before_action :require_authentication, :only => [:envia_termos]
	attr_accessor :array_resposta

	def envia_termos
		
		@resposta_principal = Principal.new(params, current_user)

		if @resposta_principal.valid?
			@resultado = @resposta_principal.busca_exata
			@result_modal = @resposta_principal.resultado_secundario
			@usuario = current_user
		else
			@resultado = Hash.new
			@resultado[:erro] = @resposta_principal.errors.first[1]
		end
			
	end
end