class Principal
	require 'ffi'
	require "i18n"
	include ActiveModel::Model

	attr_accessor :termos, :exata, :sinonimo, :antonimo, :verbo, :radical, :caracteres, :resultado_secundario, :versiculo_banco

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
	end

	def busca_sinonimos
		@versiculo_pontos = {}

		versiculos = Versiculo.where("texto like :termos", {:termos => "%#{@termos}%"}).as_json
		versiculos.each { |versiculo| @versiculo_pontos[versiculo["idVersiculo"]] = 10000 }

		termos = @termos.split

		termos.each do |value|
			stopword = Stopword.where(:stopword => value).first

			if !stopword

				if @sinonimo
					puts "sinonimos"
					versiculos = Versiculo_has_termo.find_by_sql("SELECT DISTINCT versiculo_has_termos.*, t2.aparicoes as aparicoes_termo	 FROM termos t1 LEFT JOIN termo_has_sinonimos ON t1.idTermo = termo_has_sinonimos.sinonimo_id LEFT JOIN termos t2 ON t2.idTermo = termo_has_sinonimos.termo_id LEFT JOIN versiculo_has_termos ON versiculo_has_termos.termo_id = t2.idTermo where t1.termo = '#{value}'").as_json				
					versiculos.each do |versiculo|
						if(!versiculo["versiculo_id"].nil?)
							@versiculo_pontos[versiculo["versiculo_id"]] ||= {}
							@versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] ||= 0.0
							@versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] ||= 0.0
							@versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] ||= 0.0

							peso_doc_esq = 1 + (Math.log2 (versiculo["aparicoes"]))
							peso_doc_dir = Math.log2 (31097 / versiculo["aparicoes_termo"])
							peso_cons_esq = 1 + (Math.log2 (1))

							@versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] += peso_doc_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir * @current_user["pesoSinonimo"]
							@versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] += peso_doc_esq * peso_doc_dir * peso_doc_esq * peso_doc_dir
							@versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] += peso_cons_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir
						end
					end 
				end

				if @antonimo
					puts "antonimos"
					versiculos = Versiculo_has_termo.find_by_sql("SELECT DISTINCT versiculo_has_termos.*, t2.aparicoes  as aparicoes_termo FROM termos t1 LEFT JOIN termo_has_antonimos ON t1.idTermo = termo_has_antonimos.antonimo_id LEFT JOIN termos t2 ON t2.idTermo = termo_has_antonimos.termo_id LEFT JOIN versiculo_has_termos ON versiculo_has_termos.termo_id = t2.idTermo where t1.termo = '#{value}'").as_json			
					versiculos.each do |versiculo| 
						if(!versiculo["versiculo_id"].nil?)
							@versiculo_pontos[versiculo["versiculo_id"]] ||= {}
							@versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] ||= 0.0
							@versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] ||= 0.0
							@versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] ||= 0.0

							peso_doc_esq = 1 + (Math.log2 (versiculo["aparicoes"]))
							peso_doc_dir = Math.log2 (31097 / versiculo["aparicoes_termo"])
							peso_cons_esq = 1 + (Math.log2 (1))

							@versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] += peso_doc_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir * @current_user["pesoAntonimo"]
							@versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] += peso_doc_esq * peso_doc_dir * peso_doc_esq * peso_doc_dir
							@versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] += peso_cons_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir
						end
					end 
				end

				if @verbo
					puts "flexoes"
					versiculos = Versiculo_has_termo.find_by_sql("SELECT DISTINCT versiculo_has_termos.*, t2.aparicoes as aparicoes_termo FROM termos t1 LEFT JOIN termo_has_flexaos tf1 ON t1.idTermo = tf1.termo_id LEFT JOIN termo_has_flexaos tf2 ON tf2.flexao_id = tf1.flexao_id LEFT JOIN termos t2 ON t2.idTermo = tf2.termo_id LEFT JOIN versiculo_has_termos ON versiculo_has_termos.termo_id = t2.idTermo where t1.termo = '#{value}'").as_json
					versiculos.each do |versiculo| 
						if(!versiculo["versiculo_id"].nil?)
							@versiculo_pontos[versiculo["versiculo_id"]] ||= {}
							@versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] ||= 0.0
							@versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] ||= 0.0
							@versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] ||= 0.0

							peso_doc_esq = 1 + (Math.log2 (versiculo["aparicoes"]))
							peso_doc_dir = Math.log2 (31097 / versiculo["aparicoes_termo"])
							peso_cons_esq = 1 + (Math.log2 (1))

							@versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] += peso_doc_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir * @current_user["pesoFlexao"]
							@versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] += peso_doc_esq * peso_doc_dir * peso_doc_esq * peso_doc_dir
							@versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] += peso_cons_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir
						end
					end 
				end

				if @radical
					puts "radicais"
					@radical_gerado = gera_radical(value)
					versiculos = Versiculo_has_termo.find_by_sql("SELECT DISTINCT versiculo_has_termos.*, t1.aparicoes as aparicoes_termo FROM termos t1 LEFT JOIN radicals r1 ON r1.idRadical = t1.radical_id LEFT JOIN versiculo_has_termos ON versiculo_has_termos.termo_id = t1.idTermo where r1.radical = '#{@radical_gerado}'").as_json
					versiculos.each do |versiculo| 
						if(!versiculo["versiculo_id"].nil?)
							@versiculo_pontos[versiculo["versiculo_id"]] ||= {}
							@versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] ||= 0.0
							@versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] ||= 0.0
							@versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] ||= 0.0

							peso_doc_esq = 1 + (Math.log2 (versiculo["aparicoes"]))
							peso_doc_dir = Math.log2 (31097 / versiculo["aparicoes_termo"])
							peso_cons_esq = 1 + (Math.log2 (1))

							@versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] += peso_doc_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir * @current_user["pesoRadical"]
							@versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] += peso_doc_esq * peso_doc_dir * peso_doc_esq * peso_doc_dir
							@versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] += peso_cons_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir
						end
					end 
				end

				if @exata
					puts "exatos"
					versiculos = Versiculo_has_termo.find_by_sql("SELECT DISTINCT versiculo_has_termos.*, t1.aparicoes as aparicoes_termo FROM termos t1 LEFT JOIN versiculo_has_termos ON versiculo_has_termos.termo_id = t1.idTermo where t1.termo = '#{value}'").as_json
					versiculos.each do |versiculo| 
						if(!versiculo["versiculo_id"].nil?)
							@versiculo_pontos[versiculo["versiculo_id"]] ||= {}
							@versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] ||= 0.0
							@versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] ||= 0.0
							@versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] ||= 0.0

							peso_doc_esq = 1 + (Math.log2 (versiculo["aparicoes"]))
							peso_doc_dir = Math.log2 (31097 / versiculo["aparicoes_termo"])
							peso_cons_esq = 1 + (Math.log2 (1))

							@versiculo_pontos[versiculo["versiculo_id"]]['multiplicatorio'] += peso_doc_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir * @current_user["pesoExata"]
							@versiculo_pontos[versiculo["versiculo_id"]]['somatorio1'] += peso_doc_esq * peso_doc_dir * peso_doc_esq * peso_doc_dir
							@versiculo_pontos[versiculo["versiculo_id"]]['somatorio2'] += peso_cons_esq * peso_doc_dir * peso_cons_esq * peso_doc_dir
						end
					end				
				end

			end
		end

		@array_versiculos = []
		@ranking = []

		@versiculo_pontos.each do |key, value|
			total ||= 0.0
			total = (value['multiplicatorio'] / ((Math.sqrt(value['somatorio1'])) * (Math.sqrt(value['somatorio2']))))
			indice = (0...@array_versiculos.size).bsearch{|x| total >= @array_versiculos[x]}
			if indice.blank?
				@array_versiculos.push(total)
				@ranking.push({:versiculo => key, :pontos => total})
			else
				@array_versiculos.insert(indice, total)
				@ranking.insert(indice, {:versiculo => key, :pontos => total})
			end
			
		end

		puts @ranking
		puts "acabou"
	end

	def busca_exata
		termos = @termos.split

		@texto_versiculos = Array.new

		@gets = 0

		busca_versiculo

		termos.each do |value|
			stopword = Stopword.where(:stopword => value).first
			if !stopword
				termo = Termo.where(:termo => value).first
				@gets += 1
				if @sinonimo && termo
					sinonimos = Termo_has_sinonimo.where(:sinonimo => termo).as_json
					@gets += 1
					sinonimos.each do |sinonimo|
						valor_sinonimo = Termo.find(sinonimo["termo_id"]).as_json
						@gets += 1
						versiculos = Versiculo_has_termo.where(:termo => sinonimo["termo_id"]).as_json
						@gets += 1
						versiculos.each do |verso|
							if !@hashCompletas[verso["versiculo_id"]]

						  		if !@numeroExatas[verso["versiculo_id"]]
									@numeroExatas[verso["versiculo_id"]] = {};
								end

								if !@numeroExatas[verso["versiculo_id"]][valor_sinonimo["termo"]]
									@numeroExatas[verso["versiculo_id"]][valor_sinonimo["termo"]] = 0.0;
								end
								if verso["aparicoes"] > 0
						  			@numeroExatas[verso["versiculo_id"]][valor_sinonimo["termo"]] += (1.00 / verso["aparicoes"]) * (@current_user["pesoSinonimo"].to_f * 10)
									if(valor_sinonimo["termo"] == "ofensa" && verso["versiculo_id"] == 28061)
										puts "ofensa"
									end
								end
								if(!@resultado_secundario[verso["versiculo_id"]])
									@resultado_secundario[verso["versiculo_id"]] = {};
									@resultado_secundario[verso["versiculo_id"]][:sinonimos] = {}
									@resultado_secundario[verso["versiculo_id"]][:sinonimos][valor_sinonimo["termo"]] = verso["aparicoes"]
								else
									if(!@resultado_secundario[verso["versiculo_id"]][:sinonimos])
										@resultado_secundario[verso["versiculo_id"]][:sinonimos] = {}
										@resultado_secundario[verso["versiculo_id"]][:sinonimos][valor_sinonimo["termo"]] = verso["aparicoes"]
									else
										@resultado_secundario[verso["versiculo_id"]][:sinonimos][valor_sinonimo["termo"]] = verso["aparicoes"]
									end
								end
								
							end
						end
					end
				end

				if @antonimo && termo
					antonimos = Termo_has_antonimo.where(:antonimo => termo).as_json
					@gets += 1
					antonimos.each do |antonimo|	
						valor_antonimo = Termo.find(antonimo["termo_id"]).as_json
						@gets += 1
						versiculos = Versiculo_has_termo.where(:termo => antonimo["termo_id"]).as_json
						@gets += 1
						versiculos.each do |verso|
							if !@hashCompletas[verso["versiculo_id"]]

						  		if !@numeroExatas[verso["versiculo_id"]]
									@numeroExatas[verso["versiculo_id"]] = {};
								end

								if !@numeroExatas[verso["versiculo_id"]][valor_antonimo["termo"]]
									@numeroExatas[verso["versiculo_id"]][valor_antonimo["termo"]] = 0.0;
								end
								if verso["aparicoes"] > 0
						  			@numeroExatas[verso["versiculo_id"]][valor_antonimo["termo"]] += (1.00 / verso["aparicoes"]) * (@current_user["pesoAntonimo"].to_f * 10)
						  		end
								if(!@resultado_secundario[verso["versiculo_id"]])
									@resultado_secundario[verso["versiculo_id"]] = {}
									@resultado_secundario[verso["versiculo_id"]][:antonimos] = {}
									@resultado_secundario[verso["versiculo_id"]][:antonimos][valor_antonimo["termo"]] = verso["aparicoes"]
								else
									if(!@resultado_secundario[verso["versiculo_id"]][:antonimos])
										@resultado_secundario[verso["versiculo_id"]][:antonimos] = {}
										@resultado_secundario[verso["versiculo_id"]][:antonimos][valor_antonimo["termo"]] = verso["aparicoes"]
									else
										@resultado_secundario[verso["versiculo_id"]][:antonimos][valor_antonimo["termo"]] = verso["aparicoes"]
									end
								end
							end
						end
					end

				end

				if @verbo && termo
					flexoes = Termo_has_flexao.where(:termo => termo).first.as_json
					@gets += 1
					if flexoes
						flexao = Termo.find(flexoes["flexao_id"]).as_json
						@gets += 1
						controle_flexao = true
						verbos = Termo_has_flexao.where(:flexao_id => flexoes["flexao_id"]).as_json
						@gets += 1
						
						verbos.each do |verbo_hash|
							verbo = Termo.find(verbo_hash["termo_id"])
							@gets += 1
							if(verbo['termo'] != termo['termo'])
								versiculos =  Versiculo_has_termo.where(:termo => verbo["idTermo"]).as_json
								@gets += 1
								if ((verbo["termo"] != flexao["termo"]) || controle_flexao)
									versiculos.each do |verso|
										if !@hashCompletas[verso["versiculo_id"]]

									  		if !@numeroExatas[verso["versiculo_id"]]
												@numeroExatas[verso["versiculo_id"]] = {};
											end

											if !@numeroExatas[verso["versiculo_id"]][verbo["termo"]]
												@numeroExatas[verso["versiculo_id"]][verbo["termo"]] = 0.0;
											end
											if verso["aparicoes"] > 0
									  			@numeroExatas[verso["versiculo_id"]][verbo["termo"]] += (1.00 / verso["aparicoes"]) * (@current_user["pesoFlexao"].to_f * 10)
									  		end
											if(!@resultado_secundario[verso["versiculo_id"]])
												@resultado_secundario[verso["versiculo_id"]] = {}
												@resultado_secundario[verso["versiculo_id"]][:flexoes] = {}
												@resultado_secundario[verso["versiculo_id"]][:flexoes][verbo["termo"]] = verso["aparicoes"]
											else
												if(!@resultado_secundario[verso["versiculo_id"]][:flexoes])
													@resultado_secundario[verso["versiculo_id"]][:flexoes] = {}
													@resultado_secundario[verso["versiculo_id"]][:flexoes][verbo["termo"]] = verso["aparicoes"]
												else
													@resultado_secundario[verso["versiculo_id"]][:flexoes][verbo["termo"]] = verso["aparicoes"]
												end
											end
										end
									end
								end

								if ( verbo["termo"] == flexao["termo"] ) && controle_flexao
									controle_flexao = false
								end
							end

						end
					end
				end

				if @radical && termo
					retorno = gera_radical(Termo.where(:termo => value).first.as_json)

					radical = Radical.where(:radical => retorno.squish).first.as_json
					@gets += 1
					if radical.present?
						termos_radicais = Termo.where(:radical => radical["idRadical"]).as_json

						termos_radicais.each do |termo_radical|

							if termo_radical['termo'] != termo["termo"]
								versiculos =  Versiculo_has_termo.where(:termo => termo_radical["idTermo"])
								@gets += 1

								versiculos.each do |verso|
									if !@hashCompletas[verso["versiculo_id"]]

								  		if !@numeroExatas[verso["versiculo_id"]]
											@numeroExatas[verso["versiculo_id"]] = {};
										end

										if !@numeroExatas[verso["versiculo_id"]][termo_radical["termo"]]
											@numeroExatas[verso["versiculo_id"]][termo_radical["termo"]] = 0.0;
										end
										if verso["aparicoes"] > 0
								  			@numeroExatas[verso["versiculo_id"]][termo_radical["termo"]] += (1.00 / verso["aparicoes"]) * (@current_user["pesoRadical"].to_f * 10)
										end

										if(!@resultado_secundario[verso["versiculo_id"]])
											@resultado_secundario[verso["versiculo_id"]] = {}
											@resultado_secundario[verso["versiculo_id"]][:radicais] = {}
											@resultado_secundario[verso["versiculo_id"]][:radicais][termo_radical["termo"]] = verso["aparicoes"]
										else
											if(!@resultado_secundario[verso["versiculo_id"]][:radicais])
												@resultado_secundario[verso["versiculo_id"]][:radicais] = {}
												@resultado_secundario[verso["versiculo_id"]][:radicais][termo_radical["termo"]] = verso["aparicoes"]
											else
												@resultado_secundario[verso["versiculo_id"]][:radicais][termo_radical["termo"]] = verso["aparicoes"]
											end
										end
									end
								end
							end
						end
					end
				end


				if termo && @exata
					versiculos = Versiculo_has_termo.where(:termo => termo).as_json
					@gets += 1
					versiculos.each do |verso|
						if !@hashCompletas[verso["versiculo_id"]]
							if !@numeroExatas[verso["versiculo_id"]]
								@numeroExatas[verso["versiculo_id"]] = {};
							end

							if !@numeroExatas[verso["versiculo_id"]][value]
								@numeroExatas[verso["versiculo_id"]][value] = 0.0;
							end
							if verso["aparicoes"] > 0
						  		@numeroExatas[verso["versiculo_id"]][value] += (1.00 / verso["aparicoes"]) * (@current_user["pesoExata"].to_f * 10)
						  	end
							if(!@resultado_secundario[verso["versiculo_id"]])
								@resultado_secundario[verso["versiculo_id"]] = {}
								@resultado_secundario[verso["versiculo_id"]][:exatas] = {}
								@resultado_secundario[verso["versiculo_id"]][:exatas][value] = verso["aparicoes"]
							else
								if(!@resultado_secundario[verso["versiculo_id"]][:exatas])
									@resultado_secundario[verso["versiculo_id"]][:exatas] = {}
									@resultado_secundario[verso["versiculo_id"]][:exatas][value] = verso["aparicoes"]
								else
									@resultado_secundario[verso["versiculo_id"]][:exatas][value] = verso["aparicoes"]
								end
							end
						end
					end
				end
			end
		end

		@pesoExatas = {}

		@numeroExatas.each do |key, versiculo|
			versiculo.each do |termo, valor|
				if !@pesoExatas[key]
					@pesoExatas[key] = 0
				end
				@pesoExatas[key] += valor
			end

		end

		ranking_exatas = @pesoExatas.sort_by { |versiculo, valor| valor }.reverse

		ranking_exatas[0..10].each do |key, valor|
			# puts @numeroExatas[key]
			# puts @resultado_secundario[key]
			# puts valor
			# puts "----"
		end

		puts "------------------------------------#{@gets}"

		@versiculo_banco = Array.new
		@versos = Array.new

		@hashCompletas.each do |versiculo, valor|
			@versiculo_banco.push(versiculo)
		end
		
		ranking_exatas.each do |versiculo, valor|
			@versiculo_banco.push(versiculo)
		end

		@versiculo_banco[0..10].each do |versiculo|
			verso = Versiculo.find(versiculo).as_json
			@versos.push(verso)
		end

		@versos
	end

	def busca_versiculo
		@versiculo_banco = Versiculo.where("texto like :termos", {:termos => "%#{@termos}%"}).as_json
		@versiculo_banco.each do |versiculo|
			result = versiculo
			texto = result["texto"]
			@texto_versiculos[result["idVersiculo"]] = result

			if !@hashCompletas[result["idVersiculo"]]
				@hashCompletas[result["idVersiculo"]] = {:completo => true}
			end

			if(!@resultado_secundario[result["idVersiculo"]])
					@resultado_secundario[result["idVersiculo"]] = {}
					@resultado_secundario[result["idVersiculo"]][:exatasCompleta] = {}
					@resultado_secundario[result["idVersiculo"]][:exatasCompleta][@termos] = 1
			else
				if(!@resultado_secundario[result["idVersiculo"]][:exatasCompleta])
					@resultado_secundario[result["idVersiculo"]][:exatasCompleta] = {}
					@resultado_secundario[result["idVersiculo"]][:exatasCompleta][@termos] = 1
				else
					@resultado_secundario[result["idVersiculo"]][:exatasCompleta][@termos] = 1
				end
			end

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