module Rm
  class RmDuration::RmInversionDuration
    
    attr_accessor :titulo, :detalle, :precio_mercado, :valor_nominal, :dias_vencimiento_titulo, :posicion

    def initialize(atributos = {})
    	@titulo = RmInversion.find_by_codigo(atributos[:rm_inversion_codigo])
    	base = RmInversionDiaria.where('rm_inversion_codigo = ? and fecha_snapshot = ?', @titulo.codigo, atributos[:fecha])
      @detalle = base.first
      @precio_mercado = RmPrecioMercado.where('codigo_titulo = ? and fecha_snapshot = ?', @titulo.codigo, atributos[:fecha]).first.precio_mercado.to_f / 100
      @valor_nominal = base.sum(:valor_nominal).to_f
      @posicion = base.sum(:valor_mercado).to_f
      @dias_vencimiento_titulo = @titulo.rm_base_calculo.dias_vencimiento.to_f
    end

    #D
    # TODO -> 364 deberia ser un parametro que se llama vencimiento_referencial_letras
    def duration
      if @titulo.rm_tipo_instrumento.codigo == 38 # Letras del Tesoro
        ((@detalle.fecha_venc - @detalle.fecha_snapshot).to_f / 364 )
      else
    	  ((1 + rendimiento_efectivo) / rendimiento_efectivo) - ( ((vida_titulo_anualizada*((tasa/100.0) - rendimiento_efectivo)) + (1 + rendimiento_efectivo)) / ( ((tasa/100.0) * (1 + rendimiento_efectivo)** vida_titulo_anualizada ) - ((tasa/100.0) - rendimiento_efectivo)) ) 
      end
    end

    #Dm
    def duration_modificada
      (duration / (1 + rendimiento_efectivo))
    end
   
    #r nuevo
    def rendimiento_efectivo
      if @titulo.rm_tipo_instrumento.codigo == 38 # Letras del Tesoro
        ((1 - @precio_mercado) / @precio_mercado) * (360 / ((@detalle.fecha_venc - @detalle.fecha_snapshot).to_f))
      else
       (((1 + ((tasa/100)/frecuencia))**(frecuencia)) - 1)
      end
    end
    
    #r antiguo
    #def rendimiento_efectivo
    #  if @titulo.rm_tipo_instrumento.codigo == 38 # Letras del Tesoro
    #    ((1 - @precio_mercado) / @precio_mercado) * (360 / ((@detalle.fecha_venc - @detalle.fecha_snapshot).to_f)) 
    #  else
    #  	((((valor_rescate/100)+(tasa/frecuencia))-((valor_nominal/100)+((dias_acumulados/dias_cupon)*(tasa/frecuencia)))) / (((valor_nominal/100)+((dias_acumulados/dias_cupon)*(tasa/frecuencia))))) * ((frecuencia*dias_cupon)/vida_titulo)
    #  end
    #end

    #A
    def dias_acumulados
    	(@detalle.fecha_snapshot - @detalle.fecha_inicio_cupon).to_f 
    end

    #E
    def dias_cupon
    	(@detalle.fecha_vencimiento_cupon - @detalle.fecha_inicio_cupon).to_f
    end

    #DLV
    def vida_titulo
    	(@detalle.fecha_venc - @detalle.fecha_snapshot).to_f
    end

    def valor_nominal
    	@valor_nominal.to_f
    end

    #c
    def tasa
    	@titulo.tasa_cupon.to_f
    end

    def frecuencia
    	@titulo.frecuencia_pago
    end

    def valor_rescate
      @titulo.valor_rescate.to_f
    end

    #n
    def vida_titulo_anualizada
      (vida_titulo / 360.to_f)
    end

  end
end
