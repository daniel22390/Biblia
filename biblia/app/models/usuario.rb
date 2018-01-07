class Usuario < ApplicationRecord
	validates_presence_of :nome, :message => "Nome é um campo obrigatório. Por favor, preencha-o."
	validates_presence_of :email, :message => "Email é um campo obrigatório. Por favor, preencha-o." 
	validates_presence_of :login, :message => "Usuário é um campo obrigatório. Por favor, preencha-o."
	validates_presence_of :nivel, :message => "Nível é um campo obrigatório. Por favor, preencha-o."
	validates_presence_of :password, :message => "Senha é um campo obrigatório. Por favor, preencha-o." 
	validates_confirmation_of :password, :message => 'Senhas com valores diferentes.'

	def self.authenticate(login, password)
		usuario = Usuario.find_by login: login, password: password
	end
end