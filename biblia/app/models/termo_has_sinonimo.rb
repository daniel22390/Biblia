class Termo_has_sinonimo < ApplicationRecord
	#attr_accessor :termo, :peso, :Radical_idRadical
	belongs_to :termo, :class_name => 'Termo'
	belongs_to :sinonimo, :class_name => 'Termo'
end