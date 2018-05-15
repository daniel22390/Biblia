class Principal
	require 'ffi'
	require "i18n"
	include ActiveModel::Model

	attr_accessor :termos, :exata, :sinonimo, :antonimo, :verbo, :radical, :caracteres, :resultado_secundario, :versiculo_banco, :versiculos_array

	validates_presence_of :termos, :message => "É necessária a entrada de algum termo para pesquisa."

	def initialize(attributes = {}, current_user)
		@termos = attributes[:termos]
		@exata = attributes[:exata]
		@sinonimo = attributes[:sinonimo]
		@antonimo = attributes[:antonimo]
		@verbo = attributes[:verbo]
		@radical = attributes[:radical]
		@rankingSinonimos = Hash.new
		@numeroExatas = Hash.new
		@hashCompletas = Hash.new
		@numeroSinonimos = Hash.new
		@current_user = current_user.as_json
		@caracteres = ["?", "!", "@", "#", "$", "%", "&", "*", "/", "?", "(", ")", ",", ".", ":", ";", "]", "[", "}", "{", "=", "+"]
		@resultado_secundario = Hash.new
		@ranking
		@versiculos_array
	end

	def busca_tf
		# @versiculo_pontos = {}
		@hash_geral = {}

		busca_versiculo

		termos = @termos.split

		termos.each do |value|
			stopword = Stopword.where(:stopword => value).first

			if !stopword

				if @sinonimo
					versiculos = Versiculo_has_termo.find_by_sql("SELECT DISTINCT versiculo_has_termos.*, t2.termo as termo_termo, t2.aparicoes as aparicoes_termo	 FROM termos t1 LEFT JOIN termo_has_sinonimos ON t1.idTermo = termo_has_sinonimos.sinonimo_id LEFT JOIN termos t2 ON t2.idTermo = termo_has_sinonimos.termo_id LEFT JOIN versiculo_has_termos ON versiculo_has_termos.termo_id = t2.idTermo where t1.termo = '#{value}'").as_json				
					versiculos.each do |versiculo|
						if(!versiculo["versiculo_id"].nil?)
							# puts versiculo
							# @versiculo_pontos[versiculo["versiculo_id"]] ||= {}
							# @versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] ||= 0.0
							# @versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] ||= 0.0
							# @versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] ||= 0.0

							@hash_geral[versiculo["versiculo_id"]] ||= {}
							@hash_geral[versiculo["versiculo_id"]]['termos'] ||= {}

							# puts @hash_geral[versiculo["versiculo_id"]]

							# if(!@hash_geral[versiculo["versiculo_id"]]['termos'][versiculo["termo_id"]].nil?)
							# 	puts @hash_geral[versiculo["versiculo_id"]]['termos'][versiculo["termo_id"]][:contexto]
							# end

							if(@hash_geral[versiculo["versiculo_id"]]['termos'].nil? ||  @hash_geral[versiculo["versiculo_id"]]['termos'][versiculo["termo_id"]].nil? || (@current_user["pesoSinonimo"] > @current_user[@hash_geral[versiculo["versiculo_id"]]['termos'][versiculo["termo_id"]][:contexto]] ))
								# if(!@hash_geral[versiculo["versiculo_id"]]['termos'][versiculo["termo_id"]].nil?)
								# 	puts @hash_geral[versiculo["versiculo_id"]]['termos'][versiculo["termo_id"]][:contexto]
								# end
								# puts "ijhiijoninjininijninijni"
								# puts versiculo['termo'].as_json['termo']
								@hash_geral[versiculo["versiculo_id"]]['termos'][versiculo["termo_id"]] = {'termo' => versiculo["termo_termo"] ,'aparicoes': versiculo["aparicoes"], 'aparicoes_termo': versiculo["aparicoes_termo"], 'contexto': "pesoSinonimo", 'pesquisa': value}
							end

							# peso_doc_esq = 1 + (Math.log2 (versiculo["aparicoes"]))

							# #tf-idf
							# peso_doc_dir = Math.log2 (31097 / versiculo["aparicoes_termo"])

							# #tf
							# # peso_doc_dir = 1

							# peso_cons_esq = 1 + (Math.log2 (1))



							# @versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] += peso_doc_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir * @current_user["pesoSinonimo"]
							# @versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] += peso_doc_esq * peso_doc_dir * peso_doc_esq * peso_doc_dir
							# @versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] += peso_cons_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir
						end
					end 
				end

				if @antonimo
					versiculos = Versiculo_has_termo.find_by_sql("SELECT DISTINCT versiculo_has_termos.*, t2.termo as termo_termo, t2.aparicoes  as aparicoes_termo FROM termos t1 LEFT JOIN termo_has_antonimos ON t1.idTermo = termo_has_antonimos.antonimo_id LEFT JOIN termos t2 ON t2.idTermo = termo_has_antonimos.termo_id LEFT JOIN versiculo_has_termos ON versiculo_has_termos.termo_id = t2.idTermo where t1.termo = '#{value}'").as_json			
					versiculos.each do |versiculo| 
						if(!versiculo["versiculo_id"].nil?)
							# @versiculo_pontos[versiculo["versiculo_id"]] ||= {}
							# @versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] ||= 0.0
							# @versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] ||= 0.0
							# @versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] ||= 0.0

							@hash_geral[versiculo["versiculo_id"]] ||= {}
							@hash_geral[versiculo["versiculo_id"]]['termos'] ||= {}
							# puts "ant"
							# if(!@hash_geral[versiculo["versiculo_id"]]['termos'][versiculo["termo_id"]].nil?)
							# 	puts @hash_geral[versiculo["versiculo_id"]]['termos'][versiculo["termo_id"]][:contexto]
							# end

							if(@hash_geral[versiculo["versiculo_id"]]['termos'].nil? ||  @hash_geral[versiculo["versiculo_id"]]['termos'][versiculo["termo_id"]].nil? || (@current_user["pesoAntonimo"] > @current_user[@hash_geral[versiculo["versiculo_id"]]['termos'][versiculo["termo_id"]][:contexto]] ))
								# @hash_geral[versiculo["versiculo_id"]]['termos'] ||= {}
								@hash_geral[versiculo["versiculo_id"]]['termos'][versiculo["termo_id"]] = {'termo' =>  versiculo["termo_termo"] ,'aparicoes': versiculo["aparicoes"], 'aparicoes_termo': versiculo["aparicoes_termo"], 'contexto': "pesoAntonimo", 'pesquisa': value}
							end

							# peso_doc_esq = 1 + (Math.log2 (versiculo["aparicoes"]))

							# #tf-idf
							# peso_doc_dir = Math.log2 (31097 / versiculo["aparicoes_termo"])

							# #tf
							# # peso_doc_dir = 1

							# peso_cons_esq = 1 + (Math.log2 (1))

							# @versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] += peso_doc_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir * @current_user["pesoAntonimo"]
							# @versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] += peso_doc_esq * peso_doc_dir * peso_doc_esq * peso_doc_dir
							# @versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] += peso_cons_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir
						end
					end 
				end

				if @verbo
					versiculos = Versiculo_has_termo.find_by_sql("SELECT DISTINCT versiculo_has_termos.*, t2.termo as termo_termo, t2.aparicoes as aparicoes_termo FROM termos t1 LEFT JOIN termo_has_flexaos tf1 ON t1.idTermo = tf1.termo_id LEFT JOIN termo_has_flexaos tf2 ON tf2.flexao_id = tf1.flexao_id LEFT JOIN termos t2 ON t2.idTermo = tf2.termo_id LEFT JOIN versiculo_has_termos ON versiculo_has_termos.termo_id = t2.idTermo where t1.termo = '#{value}'").as_json
					versiculos.each do |versiculo| 
						if(!versiculo["versiculo_id"].nil?)
							# @versiculo_pontos[versiculo["versiculo_id"]] ||= {}
							# @versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] ||= 0.0
							# @versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] ||= 0.0
							# @versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] ||= 0.0

							@hash_geral[versiculo["versiculo_id"]] ||= {}
							@hash_geral[versiculo["versiculo_id"]]['termos'] ||= {}

							if(@hash_geral[versiculo["versiculo_id"]]['termos'].nil? ||  @hash_geral[versiculo["versiculo_id"]]['termos'][versiculo["termo_id"]].nil? || (@current_user["pesoFlexao"] > @current_user[@hash_geral[versiculo["versiculo_id"]]['termos'][versiculo["termo_id"]][:contexto]] ))
								# @hash_geral[versiculo["versiculo_id"]]['termos'] ||= {}
								@hash_geral[versiculo["versiculo_id"]]['termos'][versiculo["termo_id"]] = {'termo' => versiculo["termo_termo"] ,'aparicoes': versiculo["aparicoes"], 'aparicoes_termo': versiculo["aparicoes_termo"], 'contexto': "pesoFlexao", 'pesquisa': value}
							end

							# peso_doc_esq = 1 + (Math.log2 (versiculo["aparicoes"]))

							# #tf-idf
							# peso_doc_dir = Math.log2 (31097 / versiculo["aparicoes_termo"])

							# #tf
							# # peso_doc_dir = 1

							# peso_cons_esq = 1 + (Math.log2 (1))

							# @versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] += peso_doc_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir * @current_user["pesoFlexao"]
							# @versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] += peso_doc_esq * peso_doc_dir * peso_doc_esq * peso_doc_dir
							# @versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] += peso_cons_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir
						end
					end 
				end

				if @radical
					@radical_gerado = gera_radical(value)
					versiculos = Versiculo_has_termo.find_by_sql("SELECT DISTINCT versiculo_has_termos.*, t1.termo as termo_termo, t1.aparicoes as aparicoes_termo FROM termos t1 LEFT JOIN radicals r1 ON r1.idRadical = t1.radical_id LEFT JOIN versiculo_has_termos ON versiculo_has_termos.termo_id = t1.idTermo where r1.radical = '#{@radical_gerado}'").as_json
					versiculos.each do |versiculo| 
						if(!versiculo["versiculo_id"].nil?)
							# @versiculo_pontos[versiculo["versiculo_id"]] ||= {}
							# @versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] ||= 0.0
							# @versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] ||= 0.0
							# @versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] ||= 0.0

							@hash_geral[versiculo["versiculo_id"]] ||= {}
							@hash_geral[versiculo["versiculo_id"]]['termos'] ||= {}

							if(@hash_geral[versiculo["versiculo_id"]]['termos'].nil? ||  @hash_geral[versiculo["versiculo_id"]]['termos'][versiculo["termo_id"]].nil? || (@current_user["pesoRadical"] > @current_user[@hash_geral[versiculo["versiculo_id"]]['termos'][versiculo["termo_id"]][:contexto]] ))
								
								# @hash_geral[versiculo["versiculo_id"]]['termos'] ||= {}
								@hash_geral[versiculo["versiculo_id"]]['termos'][versiculo["termo_id"]] = {'termo' => versiculo["termo_termo"] ,'aparicoes': versiculo["aparicoes"], 'aparicoes_termo': versiculo["aparicoes_termo"], 'contexto': "pesoRadical", 'pesquisa': value}
							end

							# peso_doc_esq = 1 + (Math.log2 (versiculo["aparicoes"]))
							# #tf-idf
							# peso_doc_dir = Math.log2 (31097 / versiculo["aparicoes_termo"])

							# #tf
							# # peso_doc_dir = 1
							# peso_cons_esq = 1 + (Math.log2 (1))

							# @versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] += peso_doc_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir * @current_user["pesoRadical"]
							# @versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] += peso_doc_esq * peso_doc_dir * peso_doc_esq * peso_doc_dir
							# @versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] += peso_cons_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir
						end
					end 
				end

				if @exata
					versiculos = Versiculo_has_termo.find_by_sql("SELECT DISTINCT versiculo_has_termos.*, t1.termo as termo_termo, t1.aparicoes as aparicoes_termo FROM termos t1 LEFT JOIN versiculo_has_termos ON versiculo_has_termos.termo_id = t1.idTermo where t1.termo = '#{value}'").as_json
					versiculos.each do |versiculo| 
						if(!versiculo["versiculo_id"].nil?)
							# @versiculo_pontos[versiculo["versiculo_id"]] ||= {}
							# @versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] ||= 0.0
							# @versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] ||= 0.0
							# @versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] ||= 0.0

							@hash_geral[versiculo["versiculo_id"]] ||= {}
							@hash_geral[versiculo["versiculo_id"]]['termos'] ||= {}

							if(@hash_geral[versiculo["versiculo_id"]]['termos'].nil? ||  @hash_geral[versiculo["versiculo_id"]]['termos'][versiculo["termo_id"]].nil? || (@current_user["pesoExata"] > @current_user[@hash_geral[versiculo["versiculo_id"]]['termos'][versiculo["termo_id"]][:contexto]] ))
								# @hash_geral[versiculo["versiculo_id"]]['termos'] ||= {}
								@hash_geral[versiculo["versiculo_id"]]['termos'][versiculo["termo_id"]] = {'termo' => versiculo["termo_termo"] ,'aparicoes': versiculo["aparicoes"], 'aparicoes_termo': versiculo["aparicoes_termo"], 'contexto': "pesoExata", 'pesquisa': value}
							end

							# peso_doc_esq = 1 + (Math.log2 (versiculo["aparicoes"]))
							# #tf-idf
							# peso_doc_dir = Math.log2 (31097 / versiculo["aparicoes_termo"])

							# #tf
							# # peso_doc_dir = 1
							# peso_cons_esq = 1 + (Math.log2 (1))

							# @versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] += peso_doc_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir * @current_user["pesoExata"]
							# @versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] += peso_doc_esq * peso_doc_dir * peso_doc_esq * peso_doc_dir
							# @versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] += peso_cons_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir
						end
					end				
				end

			end
		end

		# puts @hash_geral
		#@versiculos_hash = {}
		@versiculos_array = []

		@hash_geral.each do |key, value|
			# puts key
			#puts value
			# puts '---'
			if(!value["exatasCompleta"].nil? && value["exatasCompleta"])
				#@versiculos_hash[key]  = 1000
				@versiculos_array.insert(0, {versiculo: key, peso: 1000, termos: value['termos']})
			elsif 
				multiplicatorio = 0.0;
				somatorio1 = 0.0;
				somatorio2 = 0.0;
				pesos = 0;
				value['termos'].each do |key2, val2|
					peso_doc_esq = 1 + (Math.log2 (val2[:aparicoes]))
					peso_doc_dir = 1
					peso_cons_esq = 1 + (Math.log2 (1))
					pesos +=  @current_user[val2[:contexto]]

					multiplicatorio += peso_doc_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir * @current_user[val2[:contexto]]
					somatorio1 += peso_doc_esq * peso_doc_dir * peso_doc_esq * peso_doc_dir
					somatorio2 += peso_cons_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir
				end

				# if(value['termos'].length > 1 && key == 13277	)
				# 	puts 'length---'
				# 	puts value['termos'].length
				# 	multiplicatorio = 0.0;
				# 	somatorio1 = 0.0;
				# 	somatorio2 = 0.0;
				# 	pesos = 0.0;
				# 	value['termos'].each do |key2, val2|
				# 		puts val2["termo"]
				# 		puts val2[:contexto]
				# 		peso_doc_esq = 1 + (Math.log2 (val2[:aparicoes])) 
				# 		peso_doc_dir = 1
				# 		peso_cons_esq = 1 + (Math.log2 (1))
				# 		pesos += @current_user[val2[:contexto]]

				# 		multiplicatorio += peso_doc_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir
				# 		somatorio1 += peso_doc_esq * peso_doc_dir * peso_doc_esq * peso_doc_dir
				# 		somatorio2 += peso_cons_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir
				# 		puts "pesos---"
				# 		puts multiplicatorio
				# 		puts somatorio1
				# 		puts somatorio2
				# 	end
				# 	puts "peso total---"
				# 	puts (multiplicatorio / ((Math.sqrt(somatorio1)) * (Math.sqrt(somatorio2)))) * pesos
				# 	puts "----"
				# end
				# indice = @versiculos_array.bsearch{|x| (multiplicatorio / ((Math.sqrt(somatorio1)) * (Math.sqrt(somatorio2)))) >= x['peso']}
				contem = false
				@versiculos_array.each_with_index{|versiculo, key2|
					if(versiculo[:peso] <= (multiplicatorio / ((Math.sqrt(somatorio1)) * (Math.sqrt(somatorio2)))) * pesos)
						@versiculos_array.insert(key2, {versiculo: key, peso: (multiplicatorio / ((Math.sqrt(somatorio1)) * (Math.sqrt(somatorio2)))) * pesos, termos: value['termos']})
						contem = true
						break
					end
				}

				if(!contem)
					@versiculos_array.push({versiculo: key, peso: (multiplicatorio / ((Math.sqrt(somatorio1)) * (Math.sqrt(somatorio2)))) * pesos, termos: value['termos']})
				end

				# if indice.blank?
				# 	@versiculos_array.push({versiculo: key, peso: (multiplicatorio / ((Math.sqrt(somatorio1)) * (Math.sqrt(somatorio2)))), termos: value['termos']})
				# 	# @ranking.push({:versiculo => key, :pontos => total})
				# else
				# 	# @array_versiculos.insert(indice, total)
				# 	# @ranking.insert(indice, {:versiculo => key, :pontos => total})
				# 	@versiculos_array.insert(indice, {versiculo: key, peso: (multiplicatorio / ((Math.sqrt(somatorio1)) * (Math.sqrt(somatorio2)))), termos: value['termos']})
				# end

				#@versiculos_hash[key] = {versiculo: key, peso: (multiplicatorio / ((Math.sqrt(somatorio1)) * (Math.sqrt(somatorio2)))), termos: value['termos']}
			
			end
		end




		# @array_versiculos = []
		# @ranking = []

		# @versiculo_pontos.each do |key, value|
		# 	total ||= 0.0
		# 	total = (value['multiplicatorio'] / ((Math.sqrt(value['somatorio1'])) * (Math.sqrt(value['somatorio2']))))
		# 	indice = (0...@array_versiculos.size).bsearch{|x| total >= @array_versiculos[x]}
		# 	if indice.blank?
		# 		@array_versiculos.push(total)
		# 		@ranking.push({:versiculo => key, :pontos => total})
		# 	else
		# 		@array_versiculos.insert(indice, total)
		# 		@ranking.insert(indice, {:versiculo => key, :pontos => total})
		# 	end
		# end

		@versos = []
		@versiculos_array[0..9].each do |value|
			verso = Versiculo.find(value[:versiculo]).as_json
			@versos.push(verso)
		end

		@versos
	end

	# def busca_tf

	# 	@versiculo_pontos = {}

	# 	termos = @termos.split

	# 	termos.each do |value|
	# 		stopword = Stopword.where(:stopword => value).first

	# 		if !stopword

	# 			if @sinonimo
	# 				puts "sinonimos"
	# 				versiculos = Versiculo_has_termo.find_by_sql("SELECT DISTINCT versiculo_has_termos.*, t2.aparicoes as aparicoes_termo	 FROM termos t1 LEFT JOIN termo_has_sinonimos ON t1.idTermo = termo_has_sinonimos.sinonimo_id LEFT JOIN termos t2 ON t2.idTermo = termo_has_sinonimos.termo_id LEFT JOIN versiculo_has_termos ON versiculo_has_termos.termo_id = t2.idTermo where t1.termo = '#{value}'").as_json				
	# 				versiculos.each do |versiculo|
	# 					if(!versiculo["versiculo_id"].nil?)
	# 						@versiculo_pontos[versiculo["versiculo_id"]] ||= {}
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] ||= 0.0
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] ||= 0.0
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] ||= 0.0

	# 						peso_doc_esq = 1 + (Math.log2 (versiculo["aparicoes"]))

	# 						#tf-idf
	# 						# peso_doc_dir = Math.log2 (31097 / versiculo["aparicoes_termo"])

	# 						#tf
	# 						peso_doc_dir = 1

	# 						peso_cons_esq = 1 + (Math.log2 (1))

	# 						@versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] += peso_doc_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir * @current_user["pesoSinonimo"]
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] += peso_doc_esq * peso_doc_dir * peso_doc_esq * peso_doc_dir
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] += peso_cons_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir
	# 					end
	# 				end 
	# 			end

	# 			if @antonimo
	# 				puts "antonimos"
	# 				versiculos = Versiculo_has_termo.find_by_sql("SELECT DISTINCT versiculo_has_termos.*, t2.aparicoes  as aparicoes_termo FROM termos t1 LEFT JOIN termo_has_antonimos ON t1.idTermo = termo_has_antonimos.antonimo_id LEFT JOIN termos t2 ON t2.idTermo = termo_has_antonimos.termo_id LEFT JOIN versiculo_has_termos ON versiculo_has_termos.termo_id = t2.idTermo where t1.termo = '#{value}'").as_json			
	# 				versiculos.each do |versiculo| 
	# 					if(!versiculo["versiculo_id"].nil?)
	# 						@versiculo_pontos[versiculo["versiculo_id"]] ||= {}
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] ||= 0.0
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] ||= 0.0
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] ||= 0.0

	# 						peso_doc_esq = 1 + (Math.log2 (versiculo["aparicoes"]))

	# 						#tf-idf
	# 						# peso_doc_dir = Math.log2 (31097 / versiculo["aparicoes_termo"])

	# 						#tf
	# 						peso_doc_dir = 1

	# 						peso_cons_esq = 1 + (Math.log2 (1))

	# 						@versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] += peso_doc_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir * @current_user["pesoAntonimo"]
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] += peso_doc_esq * peso_doc_dir * peso_doc_esq * peso_doc_dir
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] += peso_cons_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir
	# 					end
	# 				end 
	# 			end

	# 			if @verbo
	# 				puts "flexoes"
	# 				versiculos = Versiculo_has_termo.find_by_sql("SELECT DISTINCT versiculo_has_termos.*, t2.aparicoes as aparicoes_termo FROM termos t1 LEFT JOIN termo_has_flexaos tf1 ON t1.idTermo = tf1.termo_id LEFT JOIN termo_has_flexaos tf2 ON tf2.flexao_id = tf1.flexao_id LEFT JOIN termos t2 ON t2.idTermo = tf2.termo_id LEFT JOIN versiculo_has_termos ON versiculo_has_termos.termo_id = t2.idTermo where t1.termo = '#{value}'").as_json
	# 				versiculos.each do |versiculo| 
	# 					if(!versiculo["versiculo_id"].nil?)
	# 						@versiculo_pontos[versiculo["versiculo_id"]] ||= {}
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] ||= 0.0
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] ||= 0.0
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] ||= 0.0

	# 						peso_doc_esq = 1 + (Math.log2 (versiculo["aparicoes"]))

	# 						#tf-idf
	# 						# peso_doc_dir = Math.log2 (31097 / versiculo["aparicoes_termo"])

	# 						#tf
	# 						peso_doc_dir = 1

	# 						peso_cons_esq = 1 + (Math.log2 (1))

	# 						@versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] += peso_doc_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir * @current_user["pesoFlexao"]
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] += peso_doc_esq * peso_doc_dir * peso_doc_esq * peso_doc_dir
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] += peso_cons_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir
	# 					end
	# 				end 
	# 			end

	# 			if @radical
	# 				puts "radicais"
	# 				@radical_gerado = gera_radical(value)
	# 				versiculos = Versiculo_has_termo.find_by_sql("SELECT DISTINCT versiculo_has_termos.*, t1.aparicoes as aparicoes_termo FROM termos t1 LEFT JOIN radicals r1 ON r1.idRadical = t1.radical_id LEFT JOIN versiculo_has_termos ON versiculo_has_termos.termo_id = t1.idTermo where r1.radical = '#{@radical_gerado}'").as_json
	# 				versiculos.each do |versiculo| 
	# 					if(!versiculo["versiculo_id"].nil?)
	# 						@versiculo_pontos[versiculo["versiculo_id"]] ||= {}
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] ||= 0.0
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] ||= 0.0
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] ||= 0.0

	# 						peso_doc_esq = 1 + (Math.log2 (versiculo["aparicoes"]))
	# 						#tf-idf
	# 						# peso_doc_dir = Math.log2 (31097 / versiculo["aparicoes_termo"])

	# 						#tf
	# 						peso_doc_dir = 1
	# 						peso_cons_esq = 1 + (Math.log2 (1))

	# 						@versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] += peso_doc_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir * @current_user["pesoRadical"]
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] += peso_doc_esq * peso_doc_dir * peso_doc_esq * peso_doc_dir
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] += peso_cons_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir
	# 					end
	# 				end 
	# 			end

	# 			if @exata
	# 				puts "exatos"
	# 				versiculos = Versiculo_has_termo.find_by_sql("SELECT DISTINCT versiculo_has_termos.*, t1.aparicoes as aparicoes_termo FROM termos t1 LEFT JOIN versiculo_has_termos ON versiculo_has_termos.termo_id = t1.idTermo where t1.termo = '#{value}'").as_json
	# 				versiculos.each do |versiculo| 
	# 					if(!versiculo["versiculo_id"].nil?)
	# 						@versiculo_pontos[versiculo["versiculo_id"]] ||= {}
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] ||= 0.0
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] ||= 0.0
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] ||= 0.0

	# 						peso_doc_esq = 1 + (Math.log2 (versiculo["aparicoes"]))
	# 						#tf-idf
	# 						# peso_doc_dir = Math.log2 (31097 / versiculo["aparicoes_termo"])

	# 						#tf
	# 						peso_doc_dir = 1
	# 						peso_cons_esq = 1 + (Math.log2 (1))

	# 						@versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] += peso_doc_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir * @current_user["pesoExata"]
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] += peso_doc_esq * peso_doc_dir * peso_doc_esq * peso_doc_dir
	# 						@versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] += peso_cons_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir
	# 					end
	# 				end				
	# 			end

	# 		end
	# 	end

	# 	@array_versiculos = []
	# 	@ranking = []

	# 	@versiculo_pontos.each do |key, value|
	# 		total ||= 0.0
	# 		total = (value['multiplicatorio'] / ((Math.sqrt(value['somatorio1'])) * (Math.sqrt(value['somatorio2']))))
	# 		indice = (0...@array_versiculos.size).bsearch{|x| total >= @array_versiculos[x]}
	# 		if indice.blank?
	# 			@array_versiculos.push(total)
	# 			@ranking.push({:versiculo => key, :pontos => total})
	# 		else
	# 			@array_versiculos.insert(indice, total)
	# 			@ranking.insert(indice, {:versiculo => key, :pontos => total})
	# 		end
	# 	end

	# 	@versos = []
	# 	@ranking[0..9].each do |value|
	# 		# puts value
	# 		verso = Versiculo.find(value[:versiculo]).as_json
	# 		@versos.push(verso)
	# 	end

	# 	@versos
	# end


	def busca_versiculo
		@versiculo_banco = Versiculo.where("texto like :termos", {:termos => "%#{@termos}%"}).as_json
		@versiculo_banco.each do |versiculo|
			result = versiculo
			# texto = result["texto"]
			# @texto_versiculos[result["idVersiculo"]] = result

			# if !@hashCompletas[result["idVersiculo"]]
			# 	@hashCompletas[result["idVersiculo"]] = {:completo => true}
			# end

			# @hash_geral[result["idVersiculo"]] ||= {:exatasCompleta => true, :termos => {}}

			@hash_geral[result["idVersiculo"]] ||= {}
			@hash_geral[result["idVersiculo"]]['termos'] ||= {}
			@hash_geral[result["idVersiculo"]]['exatasCompleta'] ||= true

			# if(!@resultado_secundario[result["idVersiculo"]])
			# 		@resultado_secundario[result["idVersiculo"]] = {}
			# 		@resultado_secundario[result["idVersiculo"]][:exatasCompleta] = {}
			# 		@resultado_secundario[result["idVersiculo"]][:exatasCompleta][@termos] = 1
			# else
			# 	if(!@resultado_secundario[result["idVersiculo"]][:exatasCompleta])
			# 		@resultado_secundario[result["idVersiculo"]][:exatasCompleta] = {}
			# 		@resultado_secundario[result["idVersiculo"]][:exatasCompleta][@termos] = 1
			# 	else
			# 		@resultado_secundario[result["idVersiculo"]][:exatasCompleta][@termos] = 1
			# 	end
			# end

		end
		
	end

	def gera_resultado
		@versiculo_banco
	end

	def remover_acentos(texto)
	    return texto if texto.blank?
	    texto = texto.gsub(/(á|à|ã|â|ä)/, 'a').gsub(/(é|è|ê|ë)/, 'e').gsub(/(í|ì|î|ï)/, 'i').gsub(/(ó|ò|õ|ô|ö)/, 'o').gsub(/(ú|ù|û|ü)/, 'u')
	    texto = texto.gsub(/(Á|À|Ã|Â|Ä)/, 'A').gsub(/(É|È|Ê|Ë)/, 'E').gsub(/(Í|Ì|Î|Ï)/, 'I').gsub(/(Ó|Ò|Õ|Ô|Ö)/, 'O').gsub(/(Ú|Ù|Û|Ü)/, 'U')
	    texto = texto.gsub(/ñ/, 'n').gsub(/Ñ/, 'N')
	    texto = texto.gsub(/ç/, 'c').gsub(/Ç/, 'C')
	    texto
	  end

	def gera_radical(termo)
		retorno = `RSLP.exe #{termo["termo"]}`
		retorno
	end
end