class Principal
	require 'ffi'
	require "i18n"
	include ActiveModel::Model

	attr_accessor :termos, :exata, :sinonimo, :antonimo, :verbo, :radical, :caracteres

	validates_presence_of :termos, :message => "É necessária a entrada de algum termo para pesquisa."

	def initialize(attributes = {}, current_user)
		@termos = attributes[:termos]
		@exata = attributes[:exata]
		@sinonimo = attributes[:sinonimo]
		@antonimo = attributes[:antonimo]
		@verbo = attributes[:verbo]
		@radical = attributes[:radical]
		@rankingExatas1 = Hash.new
		@rankingSinonimos = Hash.new
		@numeroExatas = Hash.new
		@numeroSinonimos = Hash.new
		@current_user = current_user.as_json
		@caracteres = ["?", "!", "@", "#", "$", "%", "&", "*", "/", "?", "(", ")", ",", ".", ":", ";", "]", "[", "}", "{", "=", "+"]
		@resultado_secundario = Hash.new
	end

	def busca
		# busca_versiculo
		# if @exata
		# 	busca_exata
		# end
		# gera_resultado
		arq = File.new("arquivo.txt", "w")

		 Versiculo_has_termo.all.each do |hash|
		 	termo = Termo.find(hash.as_json["termo_id"]).as_json["termo"]
			versiculo = Versiculo.find(hash.as_json["versiculo_id"]).as_json["texto"]
			versiculo = versiculo.mb_chars.downcase!
			aparicao = 0

			@caracteres.each do |caracter|
				versiculo = versiculo.tr(caracter, "")
			end

			array_termos = versiculo.split

			array_termos.each do |palavra|
				if(I18n.transliterate(palavra) == I18n.transliterate(termo))
					aparicao += 1
				end
			end

			if(aparicao == 0)
				if(I18n.transliterate(termo).include? "-")
					aparicao += 1
				end
			end

			if aparicao == 0

				versiculo = Versiculo.find(hash.as_json["versiculo_id"]).as_json["texto"]

				versiculo = versiculo.tr("-", " ")

				array_termos = versiculo.split

				array_termos.each do |palavra|
					if(I18n.transliterate(palavra) == I18n.transliterate(termo))
						aparicao += 1
					end
				end
			end

			#if aparicao == 0
			#	puts termo
			#	puts versiculo
			#	puts "-------"
			#end

			versiculo_id = hash.as_json["versiculo_id"]
			termo_id = hash.as_json['termo_id']
			aparicoes = aparicao

			arq.puts "UPDATE versiculo_has_termos SET aparicoes = #{aparicoes} WHERE versiculo_id = #{versiculo_id} AND termo_id = #{termo_id};";

			#conn = ActiveRecord::Base.connection
			#result = conn.execute "UPDATE versiculo_has_termos SET aparicoes = #{aparicao} WHERE versiculo_id = #{hash.as_json['versiculo_id']} AND termo_id = #{hash.as_json['termo_id']}" 
				
		 end

		 arq.close unless file.closed?

	end

	def busca_exata
		termos = @termos.split

		@totalAparicao = {}
		@totalAparicaoSinonimos = {}
		@texto_versiculos = {}
		@texto_versiculos_sinonimos = {}

		termos.each do |value|
			stopword = Stopword.where(:stopword => value).first
			if !stopword
				termo = Termo.where(:termo => value).select("idTermo").first

				if @sinonimo && termo

					sinonimos = Termo_has_sinonimo.where(:sinonimo => termo).as_json
					sinonimos.each do |sinonimo|
						valor_sinonimo = Termo.find(sinonimo["termo_id"]).as_json
						versiculos = Versiculo_has_termo.where(:termo => sinonimo["termo_id"]).as_json
						if versiculos.length > 0
							@totalAparicao[valor_sinonimo["termo"]] = (versiculos.length * 5).to_f
						else
							@totalAparicao[value] = 0.0
						end
						versiculos.each do |verso|
							if !@rankingExatas1[verso["versiculo_id"]]

								result = Versiculo.find(verso["versiculo_id"]).as_json
								texto = result["texto"]
								@texto_versiculos[result["idVersiculo"]] = result
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
						if versiculos.length > 0
							@totalAparicao[valor_antonimo["termo"]] = (versiculos.length * 5).to_f
						else
							@totalAparicao[value] = 0.0
						end
						versiculos.each do |verso|
							if !@rankingExatas1[verso["versiculo_id"]]

								result = Versiculo.find(verso["versiculo_id"]).as_json
								texto = result["texto"]
								@texto_versiculos[result["idVersiculo"]] = result
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
							versiculos =  Versiculo_has_termo.where(:termo => verbo["idTermo"]).as_json

							if ((verbo["termo"] != flexao["termo"]) || controle_flexao)
								versiculos.each do |verso|
									if !@rankingExatas1[verso["versiculo_id"]]

										result = Versiculo.find(verso["versiculo_id"]).as_json
										texto = result["texto"]
										@texto_versiculos[result["idVersiculo"]] = result
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

				if @radical && termo
					retorno = gera_radical(Termo.where(:termo => value).first.as_json)
					radical = Radical.where(:radical => retorno).first.as_json

					termos_radicais = Termo.where(:radical => radical["idRadical"]).as_json

					termos_radicais.each do |termo_radical|
						versiculos =  Versiculo_has_termo.where(:termo => termo_radical["idTermo"])

						versiculos.each do |verso|
							if !@rankingExatas1[verso["versiculo_id"]]

								result = Versiculo.find(verso["versiculo_id"]).as_json
								texto = result["texto"]
								@texto_versiculos[result["idVersiculo"]] = result
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


				if termo
					versiculos = Versiculo_has_termo.where(:termo => termo).as_json
					if versiculos.length > 0
						@totalAparicao[value] = (versiculos.length * 10).to_f
					else
						@totalAparicao[value] = 0.0
					end
					versiculos.each do |verso|
						if !@rankingExatas1[verso["versiculo_id"]]
							if !@numeroExatas[verso["versiculo_id"]]
								@numeroExatas[verso["versiculo_id"]] = {};
							end

							if !@numeroExatas[verso["versiculo_id"]][value]
								@numeroExatas[verso["versiculo_id"]][value] = 0.0;
							end

							result = Versiculo.find(verso["versiculo_id"]).as_json
							texto = result["texto"]
							@texto_versiculos[result["idVersiculo"]] = result
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

		puts @resultado_secundario
		@pesoExatas = {}

		@numeroExatas.each do |key, versiculo|
			# pesos = []
			# somatorio = 0.0
			# versiculo.each do |key2, termo|
			# 	if @totalAparicao[key2] > 0
			# 		numero = (31097.0 / @totalAparicao[key2]).to_f
			# 	else
			# 		numero = 0.0
			# 	end
			# 	peso = ((1 + Math.log2(termo)) *  Math.log2(numero)).to_f
			# 	pesos.push(peso)
			# 	if @totalAparicao[key2] > 0
			# 		somatorio += (peso * Math.log2(31097.0 / @totalAparicao[key2])).to_f
			# 	end
			# end

			# multiplicatorio = 0.0
			# multiplicatorio1 = 0.0
			# multiplicatorio2 = 0.0

			# pesos.each do |valor|
			# 	multiplicatorio1 += (valor**2).to_f
			# end
			# multiplicatorio1 = (Math.sqrt(multiplicatorio1)).to_f

			# @totalAparicao.each do |key, valor|
			# 	if(valor == 0)
			# 		multiplicatorio2 += 0.0
			# 	else
			# 		multiplicatorio2 += (Math.log2(31097.0 / valor)**2).to_f
			# 	end
			# end

			# multiplicatorio2 = (Math.sqrt(multiplicatorio2)).to_f

			# multiplicatorio = (multiplicatorio1 * multiplicatorio2).to_f

			# @pesoExatas[key] = (somatorio / multiplicatorio).to_f

			versiculo.each do |termo, valor|
				if !@pesoExatas[key]
					@pesoExatas[key] = 0
				end
				@pesoExatas[key] += valor
			end

		end

		ranking_exatas = @pesoExatas.sort_by { |versiculo, valor| valor }.reverse

		@versiculo_banco = Array.new
		ranking_exatas.each do |versiculo, valor|
			@versiculo_banco.push(@texto_versiculos[versiculo])
		end
		@versiculo_banco
	end

	def busca_versiculo
		@versiculo_banco = Versiculo.where("texto like :termos", {:termos => "%#{@termos}%"}).as_json
		@versiculo_banco.each do |versiculo|
			@rankingExatas1[versiculo["idVersiculo"]] = 0
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

# module RSLPStemmer
#   extend FFI::Library

#    ffi_lib 'c'
#    DLL = File.expand_path('rslpStemmer.so', File.dirname(__FILE__))
#   ffi_lib "#{DLL}"
#   attach_function :rslpLoadStemmer, [ :pointer, :string ], :void
# end