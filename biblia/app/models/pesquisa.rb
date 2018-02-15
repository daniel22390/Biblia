class Pesquisa < ApplicationRecord
	validates_presence_of :buscaEfetuada, :message => "O nome da busca que foi efetuada deve ser preenchido."
	validates_presence_of :ranking, :message => "A posição do ranking é obrigatório.." 
	validates_presence_of :pesoExata, :message => "O peso da busca exata é obrigatório."
	validates_presence_of :pesoSinonimo, :message => "O peso da busca por sinônimo é obrigatório."
	validates_presence_of :pesoAntonimo, :message => "O peso da busca por antônimo é obrigatório."
	validates_presence_of :pesoRadical, :message => "O peso da busca por radical é obrigatório."
	validates_presence_of :pesoFlexao, :message => "O peso da busca verbal é obrigatória."

	belongs_to :usuario
	belongs_to :versiculo
end