module Rm
  class RmCvar::CalculoCvar

    def initialize(atributos = {})
      @porcentaje_inicial_serie = atributos.fetch(:porcentaje_inicial_serie, 97.5).to_f.round(2)
      @porcentaje_incremento_serie = atributos.fetch(:porcentaje_incremento_serie, 0.05).to_f.round(2)
      @desviacion_estandar_de_serie_variaciones = atributos.fetch(:desviacion_estandar_de_serie_variaciones,0).to_f
      @posicion = atributos.fetch(:posicion, 0).to_f
    end

    # Interfaz Pública -----------------------------------------------------------------------------------------------
    def cvar
      @cvar ||= vector_cvar.sum.round(4)
    end

    def serie_cvar
      unless @serie_cvar
        @serie_cvar = []
        numero_elementos_vectores.times do |i|
          @serie_cvar << { vector_incremento_porcentajes: vector_incremento_porcentajes[i],
                           vector_1_menos_incremento_porcentajes: vector_1_menos_incremento_porcentajes[i],
                           vector_pesos_normalizados: vector_pesos_normalizados[i],
                           vector_factores: vector_factores[i],
                           vector_posicion_x_devstd_x_factor: vector_posicion_x_devstd_x_factor[i],
                           vector_cvar: vector_cvar[i]
                         }
        end      
      end
      @serie_cvar
    end

    # Métodos utilitarios ----------------------------------------------------------------------------------------------
    private

    def vector_cvar
      unless @vector_cvar
        @vector_cvar = []
        numero_elementos_vectores.times do |i|
          @vector_cvar << vector_pesos_normalizados[i] * vector_posicion_x_devstd_x_factor[i]
        end      
      end
      @vector_cvar
    end

    def vector_posicion_x_devstd_x_factor
      unless @vector_posicion_x_devstd_x_factor
        @vector_posicion_x_devstd_x_factor = []
        numero_elementos_vectores.times do |i|
          @vector_posicion_x_devstd_x_factor << @posicion * @desviacion_estandar_de_serie_variaciones * vector_factores[i]
        end
      end
      @vector_posicion_x_devstd_x_factor 
    end

    def vector_pesos_normalizados
      @vector_normalizar_pesos ||= vector_1_menos_incremento_porcentajes.map {|valor| (valor / (vector_1_menos_incremento_porcentajes.sum)) }
    end

    def vector_1_menos_incremento_porcentajes
      @vector_1_menos_incremento_porcentajes ||= vector_incremento_porcentajes.map{|valor| (1.0-valor) }
    end

    def vector_factores
      @vector_factores ||= vector_incremento_porcentajes.map {|valor| Distribution::Normal.p_value(valor) }
    end

    def vector_incremento_porcentajes
      unless @vector_incremento_porcentajes
        acumulador = @porcentaje_inicial_serie      
        @vector_incremento_porcentajes = []
        begin 
          @vector_incremento_porcentajes << acumulador if acumulador < 100.0
          acumulador = (acumulador + @porcentaje_incremento_serie)
        end while (acumulador < 100.0)
        @vector_incremento_porcentajes.pop # Inevitablemente debemos sacar el último
        @vector_incremento_porcentajes.map! {|c| (c / 100.0)}
      end   
      @vector_incremento_porcentajes
    end

    def numero_elementos_vectores
      vector_incremento_porcentajes.size
    end

  end
end
