module Rm
  class RmSimulacionMontecarlo::SeriePreciosMercado

    attr_reader :rm_inversion_codigo, :n_dias, :fecha_de_estudio, :tipo_cartera,
                :var_a_n_dias

    def initialize(atributos = {})
      @n_dias = atributos[:n_dias].to_i; raise "@n_dias debe ser mayor a 0" if @n_dias <= 0
      @var_a_n_dias = atributos[:var_a_n_dias].to_i; raise "@n_dias debe ser mayor a 0" if @var_a_n_dias <= 0

      # Para la generación de la sere se colabora con la clase RmAnalisisPortafolio::Serie
      @rm_inversion_codigo = atributos[:rm_inversion_codigo]
      @tipo_cartera = atributos[:tipo_cartera].to_i
      @fecha_de_estudio = atributos[:fecha_de_estudio]
      @serie = RmAnalisisPortafolio::Serie.new(@fecha_de_estudio, @tipo_cartera, @rm_inversion_codigo)

    end

    # Series de precios -----------------------------------------------------------------
    def serie_precios_mercado    
      @serie_precios_mercado ||= @serie.serie_precios_mercado. # 1) Se saca solo la columna precio
                                        each_with_index.map { |v, i| v if (i+1) % @var_a_n_dias==0 }. # 2) Se seleccionan los precios en saltos de cada @var_a_n_dias
                                        compact. # 3) Se eliminan los huecos nil
                                        take(@n_dias+1) #4)  Se toman la cantidad de días por parámetro
    end

    def serie_fecha_precios_mercado_rendimientos
      @serie_fecha_precios_mercado_rendimientos ||= serie_fecha_y_precios_mercado.each_cons(2).map{|hoy,ayer| hoy["rendimiento"] = Math.log(hoy["precio"]/ayer["precio"]); hoy }
    end

    def serie_fecha_y_precios_mercado
      @serie.serie_fecha_y_precios_mercado. # 1) Se saca solo la columna precio
             each_with_index.map { |v, i| v if (i+1) % @var_a_n_dias==0 }. # 2) Se seleccionan los precios en saltos de cada @var_a_n_dias
             compact. #3) Se eliminan los huecos nil
             take(@n_dias+1) #4) Se toman la cantidad de días por parámetro    
    end

    def serie_precios_mercado_ln
      unless @serie_precios_mercado_ln
        @serie_precios_mercado_ln = serie_precios_mercado.each_with_index.map do |precio, i|
          # Math.loh(precio hoy / precio_ayer)
          Math.log(precio / serie_precios_mercado[i+1]) if serie_precios_mercado[i+1]
        end
        @serie_precios_mercado_ln = @serie_precios_mercado_ln[0..-2]
      end
      @serie_precios_mercado_ln
    end

    def serie_precios_mercado_variaciones
      unless @serie_precios_mercado_variaciones
        @serie_precios_mercado_variaciones = serie_precios_mercado.each_with_index.map do |precio, i|
          # (precio / precio_ayer) - 1
          (precio / serie_precios_mercado[i+1]) - 1 if serie_precios_mercado[i+1]
        end
        @serie_precios_mercado_variaciones = @serie_precios_mercado_variaciones[0..-2]
      end
      @serie_precios_mercado_variaciones
    end

    # Posible cálculo de grados de libertad
    # def grados_de_libertad
    #   # Se eliminan los precios que se repiten (dejando sólo un valor cuando se repite), se cuentan (size) y
    #   # se resta 1
    #   serie_precios_mercado.uniq.size - 1
    # end

    # Posicion de titulo o cartera segun el caso ----------------------------------------
    def posicion
      @serie.valor_primer_dia('posicion')
    end

    # Precio mercado a la fecha_de_estudio
    def precio_mercado
      @serie.valor_primer_dia('precio')
    end

  end
end
