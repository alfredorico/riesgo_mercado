module Rm
  class RmAnalisisPortafolio::CalculoVar
    attr_reader :pivote
  	def initialize(atributos = {})
      @intervalo_de_confianza = atributos[:intervalo_de_confianza]
      @serie_variaciones = atributos.fetch(:serie_variaciones,[])
      @pivote = atributos.fetch(:pivote,0) # pivote: contiene un valor de posicion o precio según se envíe
    end

    def var
      @pivote * volatilidad
    end

    def volatilidad
      desviacion_estandar * Distribution::Normal.p_value(@intervalo_de_confianza.to_f / 100)
    end

    def desviacion_estandar
      @serie_variaciones.desviacion_estandar.round(10)
    end

  end
end
