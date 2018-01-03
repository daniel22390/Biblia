class Termo_has_antonimo < ApplicationRecord
	#attr_accessor :termo, :peso, :Radical_idRadical
	belongs_to :termo, :class_name => 'Termo'
	belongs_to :antonimo, :class_name => 'Termo'
end