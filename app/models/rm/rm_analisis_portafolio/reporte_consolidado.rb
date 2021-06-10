module Rm
  class RmAnalisisPortafolio::ReporteConsolidado

    attr_reader :fecha_de_estudio

  	def initialize(atributos = {})
  		@fecha_de_estudio = atributos[:fecha_de_estudio]
  		@tipo_cartera = atributos[:tipo_cartera]
  		@numero_de_muestras_temporal = atributos[:numero_de_muestras_temporal]
      @intervalo_de_confianza = atributos[:intervalo_de_confianza]
      @titulos_en_cartera_a_la_fecha_de_estudio = atributos[:titulos_en_cartera_a_la_fecha_de_estudio]
      @parametros_calculo_var = {
                                  numero_de_muestras_temporal: @numero_de_muestras_temporal,
                                  intervalo_de_confianza: @intervalo_de_confianza
                                }

  	end

    # Cálculo por títulos -----------------------------------------------------------------------------------------
    def titulos_en_cartera_a_la_fecha_de_estudio_que_existan_en_precios_mercado
      # Sólo se considera para el reporte consolidado los títulos de la cartera que existan en precios_mercado
      # Es decir puede haber casos en que aparezca un título en la cartera que ni siquiera existe en precios mercado.
      # Entonces no pueden tomarse en cuenta para el reporte consolidado.
      @titulos_en_cartera_a_la_fecha_de_estudio_que_existan_en_precios_mercado ||= (@titulos_en_cartera_a_la_fecha_de_estudio & RmPrecioMercado.titulos.map{ |h| h['codigo_titulo']})
    end

    def reporte_titulos
      @reporte_titulos ||= titulos_en_cartera_a_la_fecha_de_estudio_que_existan_en_precios_mercado.map do |titulo|
                             obj_serie = RmAnalisisPortafolio::Serie.new(@fecha_de_estudio, @tipo_cartera, titulo)
                             calculo_var = RmAnalisisPortafolio::CalculoVar.new(@parametros_calculo_var.merge({pivote: obj_serie.valor_primer_dia('posicion'), serie_variaciones: obj_serie.serie_variaciones.take(@numero_de_muestras_temporal)}))
                             _resultado_por_titulo = obj_serie.serie.first # Solo se toma el primer día
                             _resultado_por_titulo["rm_inversion_codigo"] = titulo
                             _resultado_por_titulo["var"] = calculo_var.var
                             _resultado_por_titulo["volatilidad"] = calculo_var.volatilidad
                             _resultado_por_titulo
                           end
    end

    # Métodos pensados para la gráfica del reporte -----------------------------------------------------------------
    def listado_vares
      reporte_titulos.map { |r| r["var"].to_f.nan? ? 0 : r['var'].to_f.round(2) }
    end

    def listado_posiciones
      reporte_titulos.map { |r| r["posicion"].to_f }
    end

    # Cálculo para el portafolio -----------------------------------------------------------------------------------------
    def reporte_portafolio
      @reporte_portafolio ||= unless @reporte_portafolio
                                calculo_var = RmAnalisisPortafolio::CalculoVar.new(@parametros_calculo_var.merge({pivote: obj_serie_portafolio.valor_primer_dia('posicion'), serie_variaciones: obj_serie_portafolio.serie_variaciones.take(@numero_de_muestras_temporal)}))
                                _resultado_por_titulo = obj_serie_portafolio.serie.first.dup # Solo se toma el primer día y se clona el hash para evitar inconvenientes
                                _resultado_por_titulo["var"] = calculo_var.var
                                _resultado_por_titulo["volatilidad"] = calculo_var.volatilidad
                                _resultado_por_titulo['gp_nr'] = total_columna_de_reporte_titulos('gp_nr')
                                _resultado_por_titulo['precio_mercado'] = total_columna_de_reporte_titulos('valor_segun_mercado') / _resultado_por_titulo["valor_nominal"].to_f * 100.0
                                _resultado_por_titulo
                              end
    end

    def precio_mercado_portafolio
      reporte_portafolio['precio_mercado']
    end

    # Cálculos resumen adicionales -----------------------------------------------------------------------------------------
    def sumatoria_var_individuales
      total_columna_de_reporte_titulos('var')
    end

    def var_consolidado_de_portafolio
      reporte_portafolio['var']
    end

    def efecto_diversificacion
      (((sumatoria_var_individuales - var_consolidado_de_portafolio) / sumatoria_var_individuales) * 100).round(2)
    rescue # Si denominador es 0
      0
    end

    def var_1_dia_de_gestion
      @var_1_dia_de_gestion ||= unless @var_1_dia_de_gestion
                                  calculo_var = RmAnalisisPortafolio::CalculoVar.new(@parametros_calculo_var.merge({
                                                                                                                     intervalo_de_confianza: 95, # Requisito para el VaR a 1 días (95%). Sobrescritura
                                                                                                                     pivote: obj_serie_portafolio.valor_primer_dia('posicion'),
                                                                                                                     serie_variaciones: obj_serie_portafolio.serie_variaciones.take(@numero_de_muestras_temporal)
                                                                                                                  }))
                                  calculo_var.var
                                end
    end

    def var_10_dias_regulatorio
      @var_10_dias_regulatorio ||= unless @var_10_dias_regulatorio
                                      calculo_var = RmAnalisisPortafolio::CalculoVar.new(@parametros_calculo_var.merge({
                                                                                                                       intervalo_de_confianza: 99, # Requisito para el VaR a 10 días regulatorio (99%). Sobrescritura
                                                                                                                       pivote: obj_serie_portafolio.valor_primer_dia('posicion'),
                                                                                                                       serie_variaciones: obj_serie_portafolio.serie_variaciones.take(@numero_de_muestras_temporal)
                                                                                                                    }))
                                      calculo_var.var * Math::sqrt(10)
                                   end
    end

    private
    # Se basa en #reporte_titulos
    def total_columna_de_reporte_titulos(columna)
      reporte_titulos.inject(0.0) {|suma, titulo| titulo[columna.to_s].to_f + suma  }
    end

    def obj_serie_portafolio
      @obj_serie_portafolio ||= RmAnalisisPortafolio::Serie.new(@fecha_de_estudio, @tipo_cartera)
    end

  end
end
