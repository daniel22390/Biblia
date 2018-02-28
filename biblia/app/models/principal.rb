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

	def busca_exata
		termos = @termos.split

		@texto_versiculos = Array.new

		busca_versiculo

		termos.each do |value|
			stopword = Stopword.where(:stopword => value).first
			if !stopword
				termo = Termo.where(:termo => value).first

				if @sinonimo && termo
					sinonimos = Termo_has_sinonimo.where(:sinonimo => termo).as_json
					sinonimos.each do |sinonimo|
						valor_sinonimo = Termo.find(sinonimo["termo_id"]).as_json
						versiculos = Versiculo_has_termo.where(:termo => sinonimo["termo_id"]).as_json
						versiculos.each do |verso|
							if !@hashCompletas[verso["versiculo_id"]]

						  		if !@numeroExatas[verso["versiculo_id"]]
									@numeroExatas[verso["versiculo_id"]] = {};
								end

								if !@numeroExatas[verso["versiculo_id"]][valor_sinonimo["termo"]]
									@numeroExatas[verso["versiculo_id"]][valor_sinonimo["termo"]] = 0.0;
								end

						  		@numeroExatas[verso["versiculo_id"]][valor_sinonimo["termo"]] += verso["aparicoes"] * (@current_user["pesoSinonimo"].to_f * 10)
								
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
					antonimos.each do |antonimo|	
						valor_antonimo = Termo.find(antonimo["termo_id"]).as_json
						versiculos = Versiculo_has_termo.where(:termo => antonimo["termo_id"]).as_json

						versiculos.each do |verso|
							if !@hashCompletas[verso["versiculo_id"]]

						  		if !@numeroExatas[verso["versiculo_id"]]
									@numeroExatas[verso["versiculo_id"]] = {};
								end

								if !@numeroExatas[verso["versiculo_id"]][valor_antonimo["termo"]]
									@numeroExatas[verso["versiculo_id"]][valor_antonimo["termo"]] = 0.0;
								end

						  		@numeroExatas[verso["versiculo_id"]][valor_antonimo["termo"]] += verso["aparicoes"] * (@current_user["pesoAntonimo"].to_f * 10)

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

					if flexoes
						flexao = Termo.find(flexoes["flexao_id"]).as_json
						controle_flexao = true
						verbos = Termo_has_flexao.where(:flexao_id => flexoes["flexao_id"]).as_json
						
						verbos.each do |verbo_hash|
							verbo = Termo.find(verbo_hash["termo_id"])

							if(verbo['termo'] != termo['termo'])
								versiculos =  Versiculo_has_termo.where(:termo => verbo["idTermo"]).as_json

								if ((verbo["termo"] != flexao["termo"]) || controle_flexao)
									versiculos.each do |verso|
										if !@hashCompletas[verso["versiculo_id"]]

									  		if !@numeroExatas[verso["versiculo_id"]]
												@numeroExatas[verso["versiculo_id"]] = {};
											end

											if !@numeroExatas[verso["versiculo_id"]][verbo["termo"]]
												@numeroExatas[verso["versiculo_id"]][verbo["termo"]] = 0.0;
											end
									  		@numeroExatas[verso["versiculo_id"]][verbo["termo"]] += verso["aparicoes"] * (@current_user["pesoFlexao"].to_f * 10)

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
					termos_radicais = Termo.where(:radical => radical["idRadical"]).as_json

					termos_radicais.each do |termo_radical|

						if termo_radical['termo'] != termo["termo"]
							versiculos =  Versiculo_has_termo.where(:termo => termo_radical["idTermo"])

							versiculos.each do |verso|
								if !@hashCompletas[verso["versiculo_id"]]

							  		if !@numeroExatas[verso["versiculo_id"]]
										@numeroExatas[verso["versiculo_id"]] = {};
									end

									if !@numeroExatas[verso["versiculo_id"]][termo_radical["termo"]]
										@numeroExatas[verso["versiculo_id"]][termo_radical["termo"]] = 0.0;
									end
							  		@numeroExatas[verso["versiculo_id"]][termo_radical["termo"]] += verso["aparicoes"] * (@current_user["pesoRadical"].to_f * 10)
								

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


				if termo && @exata
					versiculos = Versiculo_has_termo.where(:termo => termo).as_json

					versiculos.each do |verso|
						if !@hashCompletas[verso["versiculo_id"]]
							if !@numeroExatas[verso["versiculo_id"]]
								@numeroExatas[verso["versiculo_id"]] = {};
							end

							if !@numeroExatas[verso["versiculo_id"]][value]
								@numeroExatas[verso["versiculo_id"]][value] = 0.0;
							end

						  	@numeroExatas[verso["versiculo_id"]][value] += verso["aparicoes"] * (@current_user["pesoExata"].to_f * 10)

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