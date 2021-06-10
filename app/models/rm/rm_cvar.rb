module Rm
  class RmCvar
    include ActiveModel::Model 

    # Valores de formulario para información de títulos
    attr_reader :fecha_de_estudio, :tipo_cartera, :tipo_de_gestion, :intervalo_de_confianza, :rm_inversion_codigo, :numero_de_muestras_temporal
   
    # Valores de formularios para el C-Var
    attr_reader :porcentaje_inicial_serie, :porcentaje_incremento_serie

    # Variables para la vista
    attr_reader :posicion, :var, :volatilidad,
                :cvar, :serie_cvar

    # Validaciones
    validates :intervalo_de_confianza, numericality: {greater_than: 1, less_than: 100}
    validates :numero_de_muestras_temporal, :numericality => { :greater_than_or_equal_to => 1, :less_than_or_equal_to => RmParametrosVarMercado.first.numero_muestras_desviacion_estandar }
    validates :numero_de_muestras_temporal, :presence => true
    validates :porcentaje_inicial_serie, :presence => true, 
                                         :numericality => { :greater_than_or_equal_to => 90.0, :less_than_or_equal_to => 99.9999 }
    validates :porcentaje_incremento_serie, :presence => true, 
                                            :numericality => { :greater_than => 0.0, :less_than => 1.0 }

    validate :verificar_si_titulo_no_contiene_informacion_a_la_fecha_de_estudio

    def initialize(atributos = {})
      if atributos.blank?
        @fecha_de_estudio = RmCvar.fecha_limite
        @intervalo_de_confianza = 95
        @numero_de_muestras_temporal = RmParametrosVarMercado.first.numero_muestras_desviacion_estandar.to_i
        @tipo_cartera = RmAnalisisPortafolio::TipoCartera.listar_codigos.first
        @porcentaje_inicial_serie = 97.5
        @porcentaje_incremento_serie = 0.05
      else

        # EXTRACCION DE PARAMETROS DEL FORMULARIO
        # -------------------------------------------------------------------------------------------------------------------
        # Atributos para la serie
        @fecha_de_estudio =  Util::Fecha.objeto_fecha(atributos[:fecha_de_estudio])
        @tipo_cartera = atributos[:tipo_cartera].to_i
        @rm_inversion_codigo = atributos[:rm_inversion_codigo].present? ? atributos[:rm_inversion_codigo] : nil

        # Atributos para el calculo VaR
        @numero_de_muestras_temporal = atributos[:numero_de_muestras_temporal].to_i
        @intervalo_de_confianza = atributos[:intervalo_de_confianza].to_f

        # Se instancia el objeto del seria para las validaciones, cálculo VaR y para extraer la desviación estandar.
        @obj_serie = RmAnalisisPortafolio::Serie.new(@fecha_de_estudio, @tipo_cartera, @rm_inversion_codigo)

        # Atributos para c-var
        @porcentaje_inicial_serie = atributos[:porcentaje_inicial_serie].to_f
        @porcentaje_incremento_serie = atributos[:porcentaje_incremento_serie].to_f


        # INSTANCIACIÓN DE OBJETOS CORE UTILITARIOS
        # -------------------------------------------------------------------------------------------------------------------
        if valid? # Los parámetros deben ser válidos
          # VaR tradicional Riskguard
          calculo_var = RmAnalisisPortafolio::CalculoVar.new( pivote: @obj_serie.valor_primer_dia('posicion'), 
                                                              serie_variaciones: @obj_serie.serie_variaciones.take(@numero_de_muestras_temporal), 
                                                              intervalo_de_confianza: @intervalo_de_confianza
                                                            )

          # CVaR
          obj_calculo_cvar =  RmCvar::CalculoCvar.new( porcentaje_inicial_serie: @porcentaje_inicial_serie, 
                                                       porcentaje_incremento_serie: @porcentaje_incremento_serie, 
                                                       desviacion_estandar_de_serie_variaciones: @obj_serie.serie_variaciones.take(@numero_de_muestras_temporal).desviacion_estandar,
                                                       posicion: @obj_serie.valor_primer_dia('posicion')
                                                     )      
          # Variables para entregar en la vista
          # VaR Riskguard       

          @posicion = @obj_serie.valor_primer_dia('posicion')
          @volatilidad = calculo_var.volatilidad        
          @var = calculo_var.var 

          @cvar = obj_calculo_cvar.cvar
          @serie_cvar = obj_calculo_cvar.serie_cvar

        end                  
      end
    end

    def instrumento
      "CARTERA #{RmAnalisisPortafolio::TipoCartera.tipo(@tipo_cartera)} / #{@rm_inversion_codigo || 'PORTAFOLIO'} "
    end

    def titulos_en_cartera_que_no_existen_en_precios_mercado
      # Sólo se dejan los títulos de la cartera que no existen en RM_PRECIOS_MERCADO
      @obj_serie.titulos_en_cartera_que_no_existen_en_precios_mercado
    end  


    def self.fecha_limite
      RmPrecioMercado.maximum(:fecha_snapshot)
    end

    private
    def columna_calculo_para_backtesting
      case @tipo_de_gestion
        when 3 then # 'BACKTESTING SOBRE PRECIO'
          'precio'
        else # 'BACKTESTING SOBRE POSICION'
          'posicion'      
      end
    end

    def verificar_si_titulo_no_contiene_informacion_a_la_fecha_de_estudio
      # Esta validacion aplica sólo si seleccionó un título. Por lo tanto @instrumento es instancia de RmAnalisisPortafolio::Titulo
      if serie_no_tiene_informacion_a_la_fecha_de_estudio?
        errors.add(:rm_inversion_codigo, 'El título o cartera no posee información a la fecha indicada.')    
      end
    end

    # Método para verificar si se pueden hacer los cálculos
    def serie_no_tiene_informacion_a_la_fecha_de_estudio?
      # Si la primera fecha de la serie es diferente a la de la fecha de estudio es por que hay registros con fechas mas antiguas o no hay registros.
      @obj_serie.serie.first['fecha_snapshot'].to_s != @fecha_de_estudio.to_s 
    end  

  end
end
