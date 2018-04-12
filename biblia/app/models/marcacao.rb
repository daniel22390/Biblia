class Marcacao
	require 'ffi'
	require "i18n"
	include ActiveModel::Model

	attr_accessor :versiculo, :busca_efetuada, :contextos

	validates_presence_of :versiculo, :message => "É necessário o campo versiculo."
	validates_presence_of :busca_efetuada, :message => "É necessário o campo busca efetuada."
	validates_presence_of :contextos, :message => "É necessário o campo de contextos."

	def initialize(attributes = {})
		@versiculo = attributes[:versiculo]
		@busca_efetuada = attributes[:busca_efetuada]
		@contextos = attributes[:contextos]
	end

	def gera_marcacao
		"resultado"
	end
end