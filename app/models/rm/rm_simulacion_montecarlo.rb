module Rm
  class RmSimulacionMontecarlo
    include ActiveModel::Validations
    include ActiveModel::Conversion
    extend ActiveModel::Naming

    FUNCIONALIDAD = %w(HISTOGRAMA SIMULACIÓN).each_with_index.map {|v,i|[v,i]}

    # Atributos en cómun tanto para HISTOGRAMA como para SIMULACIÓN
    attr_reader :funcionalidad, :fecha_de_estudio, :n_dias, 
                :tipo_cartera, :rm_inversion_codigo, 
                :funcionalidad # Para seleccionar con un radio button entre HISTOGRAMA o SIMULADOR

    # Parámetros para HISTOGRAMA 
    attr_reader :cantidad_clases

    # Parámetros para SIMULACIÓN
    attr_reader :numero_corridas, :metodo_de_calculo, :percentil, :var_a_n_dias,
                :distribucion_estadistica
                # Para las distribuciones estadísticas


                # Para las distribuciones estadísticas con Lenguaje R
    attr_reader :df,             # T-Student (degrees of freedom)
                :scale, :shape,   # Gamma
                :mean,           # Logistic - LogNormal
                :stddev,         # LogNormal
                :shape1, :shape2 # Beta: shape1 -> shape1, shape2 -> shape2
                
    # Objetos encargados de los procesos HISTOGRAMA Y SIMULADOR para despliegue de resultados
    attr_reader :histogramas, :simulador

    # Para visualizar el set de datos sobre los que se realiza la simulación
    attr_reader :serie_precios_mercado, :serie_fecha_y_precios_mercado, :serie_precios_mercado_variaciones, :serie_fecha_precios_mercado_rendimientos

    # Validaciones comunes
    validates :fecha_de_estudio, presence: true
    validates :n_dias, numericality: {greater_than_or_equal_to: 30}, presence: true
    validates :cantidad_clases, numericality: {greater_than: 5}, presence: true
    validates :tipo_cartera, presence: true, inclusion: { in: RmAnalisisPortafolio::TipoCartera.listar_codigos  }
    validates :funcionalidad, presence: true, inclusion: { in: FUNCIONALIDAD.map{ |c| c[1] } }
    validate :parametros_distribuciones
    #validate :hay_precios_mercado

    # Validaciones para la funcionalidad SIMULACION
    validates :var_a_n_dias, numericality: {greater_than: 0}, presence: true
    validates :percentil, numericality: {greater_than: 0}, presence: true
    validates :numero_corridas, numericality: {greater_than: 0, less_than_or_equal_to: 100000}, presence: true
    # Validaciones para las distribuciones
    #validates :shape, :scale, numericality: {greater_than: 0}, presence: false

    def initialize(atributos = {})

      if atributos.blank?
        @funcionalidad = 1 # Por default se generaría SIMULACION

        # Atributos en cómun tanto para HISTOGRAMA como para SIMULACIÓN
        @fecha_de_estudio = RmPrecioMercado.maximum(:fecha_snapshot)
        @n_dias = RmSimulacionMontecarlo::RmParametrosSimulacionMontecarlo.first.numero_de_dias
        @tipo_cartera = RmAnalisisPortafolio::TipoCartera.listar_codigos.first
        @var_a_n_dias = 1

        # Parámetros para HISTOGRAMA
        @cantidad_clases = 10

        # Parámetros para SIMULACIÓN    
        @numero_corridas = 2500
        @distribucion_estadistica = RmSimulacionMontecarlo::NumerosAleatorios.codigo_distribucion_default      
        @percentil = 99
        @metodo_de_calculo = 1
        @df = nil # Para T-Student
        @scale = nil
        @mean = nil
        @shape = nil

      else      
        @funcionalidad = atributos[:funcionalidad].to_i # Para seleccionar entre HISTOGRAMA y SIMULACION
        
        # Atributos en cómun tanto para HISTOGRAMA como para SIMULACIÓN
        @fecha_de_estudio =  Util::Fecha.objeto_fecha(atributos[:fecha_de_estudio])
        @n_dias = atributos[:n_dias].to_i
        @tipo_cartera = atributos[:tipo_cartera].to_i # Debe ser entero
        @var_a_n_dias = atributos[:var_a_n_dias]

        # Parámetros para HISTOGRAMA
        @cantidad_clases = atributos[:cantidad_clases].to_i

        # Parámetros para SIMULACIÓN    
        @numero_corridas = atributos[:numero_corridas].to_i
        @metodo_de_calculo = atributos[:metodo_de_calculo].to_i
        @distribucion_estadistica = atributos[:distribucion_estadistica].to_i
        @percentil = atributos[:percentil].to_f
        @df = atributos[:df].to_f # Para T-Student
        @shape1 = atributos[:shape1].to_f # Para Lognormal, Gamma, Beta
        @shape2 = atributos[:shape2].to_f # Para Gamma, Beta
        @shape = atributos[:shape].to_f # Para Gamma
        @scale = atributos[:scale].to_f # Para Gamma
        @mean = atributos[:mean].to_f # Para Gamma
        @stddev = atributos[:stddev].to_f # Para Gamma


        # Ahora viene el proceso de instanciación de objetos core e inyección de dependencias
        spm = RmSimulacionMontecarlo::SeriePreciosMercado.new( n_dias: @n_dias,
                                                               var_a_n_dias: @var_a_n_dias,
                                                               rm_inversion_codigo: @rm_inversion_codigo,
                                                               tipo_cartera: @tipo_cartera,
                                                               fecha_de_estudio: @fecha_de_estudio
                                                              )
        # Para visualizar el set de datos sobre los que se realiza la simulación
        @serie_fecha_precios_mercado_rendimientos = spm.serie_fecha_precios_mercado_rendimientos

        # ------------------------- CLASES CORE DEL MODELO DE NEGOCIO -----------------------------------
        # Generador de números aleatorios (objeto de uso interno)
        @generador_aleatorios = RmSimulacionMontecarlo::NumerosAleatorios.new( distribucion_estadistica: @distribucion_estadistica,
                                                                               df: @df,
                                                                               shape1: @shape1,
                                                                               shape2: @shape2,
                                                                               shape: @shape,
                                                                               scale: @scale,
                                                                               mean: @mean,
                                                                               stddev: @stddev,
                                                                               metodo_de_calculo: @metodo_de_calculo,
                                                                               serie_valores: spm.serie_precios_mercado,
                                                                               serie_valores_rendimientos: spm.serie_precios_mercado_ln
                                                                              )
        @serie_precios_mercado = spm.serie_precios_mercado
        # Objeto core @histogramas
        @histogramas = RmSimulacionMontecarlo::HistogramasPreciosMercado.new( serie_precios_mercado: spm.serie_precios_mercado,
                                                                              serie_precios_mercado_ln: spm.serie_precios_mercado_ln,
                                                                              cantidad_clases: @cantidad_clases,
                                                                              informacion_titulo: informacion_titulo
                                                                            )
        @serie_fecha_y_precios_mercado = spm.serie_fecha_y_precios_mercado

        # Motor de generación de números aleatorios
        # Objeto core @simulacion
        @simulador = RmSimulacionMontecarlo::Simulador.new( posicion: spm.posicion, 
                                                            percentil: @percentil,      
                                                            precio_mercado: spm.precio_mercado,
                                                            numero_corridas: @numero_corridas,
                                                            generador_aleatorios: @generador_aleatorios,
                                                            metodo_de_calculo: @metodo_de_calculo,
                                                            cantidad_clases: @cantidad_clases,
                                                            informacion_titulo: informacion_titulo
                                                          )


        
      end
    end

    def persisted?
      false
    end

    # ---------------------------------------------------------------------------------------------------
    def informacion_titulo
      "#{@rm_inversion_codigo || 'PORTAFOLIO'} (#{RmAnalisisPortafolio::TipoCartera.tipo(@tipo_cartera)})"
    end

   
    def self.fecha_limite
      RmPrecioMercado.maximum(:fecha_snapshot)
    end

    # ------------------------------------------
    # Reglas de validación de parámetros de distribuciones
    private
    def parametros_distribuciones
      # Códigos y orden basado en RmSimulacionMontecarlo::NumerosAleatorios
      # [['NORMAL',0],['T-STUDENT',1],['LOGISTICA',2],['GAMMA',3],['BETA',4]]    
      if @funcionalidad == 1 # Sólo para simulación:
        case @distribucion_estadistica
          when 1 # T-STUDENT
            if @df <= 0.0
              errors.add(:df, 'Debe ser un valor positivo')
            # elsif @n_dias - @df != 1
            # errors.add(:df, 'Debe haber una diferencia de uno (1) entre los días de muestra y los grados de libertad')
            end    
          when 2 # LOGISTIC
            # nada definido         
          when 3 # GAMMA
            if @shape <= 0
              errors.add(:shape, 'Debe ser superior a cero')
            end      
            if @scale <= 0
              errors.add(:scale, 'Debe ser superior a cero')
            end                               
          when 4 # BETA
            if @shape1 <= 0
              errors.add(:shape1, 'Debe ser superior a cero')
            end      
            if @shape2 <= 0
              errors.add(:shape2, 'Debe ser superior a cero')
            end
          when 5 # LOGNORMAL
            # nada definido
          when 6 # WEIBULL
            # nada definido            
        end         
      end
    end

  end
end
