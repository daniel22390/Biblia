class Versiculo_has_termo < ApplicationRecord
	#attr_accessor :termo, :peso, :Radical_idRadical
	belongs_to :versiculo
	belongs_to :termo
	attr_accessor :aparicoes
end