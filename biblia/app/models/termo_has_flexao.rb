class Termo_has_flexao < ApplicationRecord
	#attr_accessor :termo, :peso, :Radical_idRadical
	belongs_to :termo, :class_name => 'Termo'
	belongs_to :flexao, :class_name => 'Termo'
end