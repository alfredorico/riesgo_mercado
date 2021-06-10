module Rm
  class RmDuration
    include ActiveModel::Model

    FRECUENCIAS = [['ANUAL',1],['SEMESTRAL',2],['CUATRIMESTRAL',3],['TRIMESTRAL',4]]

    attr_reader :fecha_de_estudio, :durations, :total_posicion_cartera, :duration_portafolio, :duration_modificada_portafolio
    validates :fecha_de_estudio, presence: true
    def initialize( atributos = {})
    	if atributos.blank?
    		@fecha_de_estudio = RmPrecioMercado.maximum(:fecha_snapshot)
    	else
        @fecha_de_estudio =  Util::Fecha.objeto_fecha(atributos[:fecha_de_estudio])
    	end
    end

    def calculo_duration
      @calculo_duration ||= RmDuration::RmCalculoDuration.new(fecha_de_estudio: @fecha_de_estudio)
    end

    def durations
      @durations ||= calculo_duration.matriz_duration
    end

    def total_posicion_cartera
      @total_posicion_cartera ||= calculo_duration.total_cartera 
    end

    def duration_portafolio
      @duration_portafolio ||= calculo_duration.dp
    end

    def duration_modificada_portafolio
      @duration_modificada_portafolio ||= calculo_duration.dmp
    end

  end
end
