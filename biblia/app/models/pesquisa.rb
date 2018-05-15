class Pesquisa < ApplicationRecord
	validates_presence_of :pesquisado, :message => "O nome da busca que foi efetuada deve ser preenchido."

	belongs_to :usuario
end