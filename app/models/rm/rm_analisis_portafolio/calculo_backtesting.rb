module Rm
	class RmAnalisisPortafolio::CalculoBacktesting

		attr_reader :columna_calculo

		def initialize(atributos = {})
			@obj_serie  = atributos[:obj_serie]
	    @intervalo_de_confianza = atributos[:intervalo_de_confianza]
			@numero_de_muestras_backtesting = atributos[:numero_de_muestras_backtesting]
			@columna_calculo = atributos.fetch(:columna_calculo, 'posicion')
	    raise 'La columna_calculo para el backstesting debe ser posicion o precio' unless ['posicion', 'precio'].include?(@columna_calculo)
		end

		def serie
	    @serie ||= unless @serie
		    # Se hace un recorrido hacia atrás tantas veces indique el @numero_de_muestras_backtesting
		    # El resultado será un vector con el cálculo del VaR de cada día hacía atrás
		    serie = []
		    (@numero_de_muestras_backtesting+1).times do # Se suma 1 para que no quede var+ o  var- con nil en el último día de la serie (día más antiguo)
				    calculo_var = RmAnalisisPortafolio::CalculoVar.new( intervalo_de_confianza: @intervalo_de_confianza,
	                                                            	serie_variaciones: @obj_serie.serie_variaciones.take(@numero_de_muestras_backtesting), # Sólo se toman las 252 muestras del total de la serie
	                                                            	pivote: @obj_serie.valor_primer_dia(@columna_calculo))
		        r =  @obj_serie.serie.first # Cada elemento del vector serie es un hash
		        r['var'] = calculo_var.var
		        serie << r
		        # Ahora se altera la serie. Es decir se extrae de la cabeza la primera fecha para ocasionar un desplazamiento hacía atrás
		        @obj_serie.serie_shift!
		    end
		    # Ahora se calcula el VaR+ y VaR-
		    serie.each_cons(2) do |hoy, ayer|
		      hoy['var+'] = ayer[@columna_calculo].to_f + ayer['var'].to_f
		      hoy['var-'] = ayer[@columna_calculo].to_f - ayer['var'].to_f
		    end
				serie.pop # Extraer día más antiguo (último día) que no tiene var+ y var-
				serie
	    end
		end

		def excepciones_sobre_lo_estimado
			serie.inject(0) { |suma, _hash| _hash[@columna_calculo].to_f > _hash['var+'].to_f ? suma + 1 : suma  }
		end

		def excepciones_bajo_lo_estimado
			serie.inject(0) { |suma, _hash| _hash[@columna_calculo].to_f < _hash['var-'].to_f ? suma + 1 : suma  }
		end

		def columna_calculo_para_encabezado_tabla
			@columna_calculo.upcase # Esto puediera cambiar con una setencia 'case' para otro encabezado
		end

	end
end
