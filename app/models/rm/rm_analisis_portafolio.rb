module Rm
  class RmAnalisisPortafolio

    include ActiveModel::Model
    TIPO_DE_GESTION = [['REPORTE CONSOLIDADO',0], ['VAR TITULOS',1], ['BACKTESTING SOBRE POSICION',2], ['BACKTESTING SOBRE PRECIO',3] ]

    # Para ser mostrados en el formulario
    attr_reader :fecha_de_estudio, :tipo_cartera, :tipo_de_gestion, :intervalo_de_confianza, :rm_inversion_codigo, :numero_de_muestras_temporal, :numero_de_muestras_backtesting

    # Api de la clase para calculos
    attr_reader :calculo_var, :reporte_consolidado, :backtesting

    # Variables para la vista
    attr_reader :serie_acotada, :serie_precios_mercado_y_variaciones, :precio_mercado

    # Validaciones
    validates :intervalo_de_confianza, numericality: {greater_than: 1, less_than: 100}
    validates :numero_de_muestras_temporal, :presence => true, :numericality => { :greater_than_or_equal_to => 1, :less_than_or_equal_to => RmParametrosVarMercado.first.numero_muestras_desviacion_estandar }
    validates :numero_de_muestras_backtesting, :presence => true,:numericality => { :greater_than_or_equal_to => 1, :less_than_or_equal_to => RmParametrosVarMercado.first.maxima_cantidad_muestras_backtesting }
    validate :verificar_si_titulo_no_contiene_informacion_a_la_fecha_de_estudio

    def initialize(atributos = {})
      if atributos.blank?
        @fecha_de_estudio = RmAnalisisPortafolio.fecha_limite
        @intervalo_de_confianza = 95
        @numero_de_muestras_temporal = RmParametrosVarMercado.first.numero_muestras_desviacion_estandar.to_i
        @numero_de_muestras_backtesting = RmParametrosVarMercado.first.maxima_cantidad_muestras_backtesting.to_i          
        @tipo_cartera = RmAnalisisPortafolio::TipoCartera.listar_codigos.first
      else
        # Atributo propio del modelo
        @tipo_de_gestion = atributos[:tipo_de_gestion].to_i

        # Atributos de las clases colaboradoras
        @fecha_de_estudio =  Util::Fecha.objeto_fecha(atributos[:fecha_de_estudio])
        @tipo_cartera = atributos[:tipo_cartera].to_i
        @numero_de_muestras_temporal = atributos[:numero_de_muestras_temporal].to_i
        @numero_de_muestras_backtesting = atributos[:numero_de_muestras_backtesting].to_i        
        @intervalo_de_confianza = atributos[:intervalo_de_confianza]
        @rm_inversion_codigo = atributos[:rm_inversion_codigo]

        parametros = { numero_de_muestras_temporal: @numero_de_muestras_temporal,
                       numero_de_muestras_backtesting: @numero_de_muestras_backtesting,          
                       intervalo_de_confianza: @intervalo_de_confianza }

        @obj_serie =  RmAnalisisPortafolio::Serie.new(@fecha_de_estudio, @tipo_cartera, @rm_inversion_codigo)

        # Las tres instancias están disponibles
        if valid? # Si la instanciación se hace desde esta clase proxy, entonces los parámetros deben ser válidos
          @calculo_var = RmAnalisisPortafolio::CalculoVar.new(parametros.merge({pivote: @obj_serie.valor_primer_dia('posicion'), serie_variaciones: @obj_serie.serie_variaciones.take(@numero_de_muestras_temporal)}))
          @backtesting =  RmAnalisisPortafolio::CalculoBacktesting.new(parametros.merge({obj_serie: @obj_serie, columna_calculo: columna_calculo_para_backtesting}))

          parametros_reporte_consolidado = parametros.merge({
                                                              fecha_de_estudio: @fecha_de_estudio,
                                                              tipo_cartera: @tipo_cartera,
                                                              titulos_en_cartera_a_la_fecha_de_estudio: @obj_serie.titulos_en_cartera_a_la_fecha_de_estudio,
                                                            })

          @reporte_consolidado = RmAnalisisPortafolio::ReporteConsolidado.new(parametros_reporte_consolidado)

          # Para la interfaz gráfica (HTML)
          @serie_precios_mercado_y_variaciones = @obj_serie.serie_precios_mercado_y_variaciones.take(@numero_de_muestras_temporal)
          @serie_acotada = @obj_serie.serie.take(@numero_de_muestras_temporal)
          @precio_mercado = @obj_serie.valor_primer_dia('precio')
        end
      end
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
        errors.add(:fecha_de_estudio, 'El título o cartera no posee información a la fecha indicada.')
      end
    end

    # Método para verificar si se pueden hacer los cálculos
    def serie_no_tiene_informacion_a_la_fecha_de_estudio?
      # Si la primera fecha de la serie es diferente a la de la fecha de estudio
      # es por que hay registros con fechas mas antiguas o no hay registros
      @obj_serie.serie.first['fecha_snapshot'].to_s != @fecha_de_estudio.to_s
    end

  end
end
