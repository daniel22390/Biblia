class Pesquisa_has_versiculo < ApplicationRecord
	#attr_accessor :termo, :peso, :Radical_idRadical
	belongs_to :pesquisa, :class_name => 'Pesquisa'
	belongs_to :versiculo, :class_name => 'Versiculo'
end