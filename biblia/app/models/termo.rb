class Termo < ApplicationRecord
	#attr_accessor :termo, :peso, :Radical_idRadical
	belongs_to :radical
end