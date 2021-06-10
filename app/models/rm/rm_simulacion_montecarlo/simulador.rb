module Rm
  class RmSimulacionMontecarlo::Simulador

    include RmSimulacionMontecarlo::Histograma # Para graficar los 2500 (o n cantidad) precios

    METODO_DE_CALCULO = [['MÉTODO POR VOLATILIDAD',0], ['MÉTODO DE PRECIOS',1]]

    def initialize(atributos)    
      raise "Debe suministrar una posición válida" if atributos[:posicion].to_f <= 0
      raise "Debe suministrar una precio mercado válido" if atributos[:precio_mercado].to_f <= 0
      raise "Número de corridas debe ser mayor a cero" if atributos[:numero_corridas].to_f <= 0
      raise "Debe suministrar la cantidad de clases para graficar histograma de precios aleatorios" if atributos[:cantidad_clases].to_i <= 0
      @numero_corridas = atributos[:numero_corridas].to_i
      @posicion = atributos[:posicion].to_f
      @percentil = atributos[:percentil].to_f || 99
      @precio_mercado = atributos[:precio_mercado] # Precio mercado a la fecha de estudio
      @metodo_de_calculo = atributos[:metodo_de_calculo].to_i
      @generador_aleatorios = atributos[:generador_aleatorios]
      @cantidad_clases = atributos[:cantidad_clases].to_i
      @informacion_titulo = atributos[:informacion_titulo]
    end

    def persisted?
      false
    end

    # Interfaz pública de la simulación.
    # -- El objetivo es calcular el var
    # Métodos de simulación --------------------------------------------------------------------------
    def var
      case @metodo_de_calculo
        when 0 # 'MÉTODO POR VOLATILIDAD'
          precio_simulado * posicion # Se extrae la posicion del titulo/portafolio para cartera negociacion/vencimiento
        when 1  # 'MÉTODO DE PRECIOS'
          precio_simulado * posicion # Se repite la funcionalidad para el caso anterior hasta no encontrar una forma mas refiniada
      end
    end

    def precio_simulado #Cálculo    
      DescriptiveStatistics::Stats.new(precios_aleatorios).percentile(@percentil)
    end

    # ...y mostrar un histograma de los precios generados
    def precios_aleatorios
      # Hay que determinar si se deben "cachear" o no. Aquí está "cacheado"
      unless @precios_aleatorios
        @precios_aleatorios = @generador_aleatorios.generar_numeros_aleatorios(@numero_corridas)  # 2500 corridas
        generar_csv(@precios_aleatorios) # Efecto colateral. Sólo se hace una vez
      end
      @precios_aleatorios
    end

    def parte_aleatoria_nombre_archivo
      @parte_aleatoria_nombre_archivo ||= Array.new(10){rand(36).to_s(36)}.join
    end

    # Grafica para los precios (2500) generados
    def grafica_histograma_precios_aleatorios
      clases = RmSimulacionMontecarlo::Histograma.generar_clases(precios_aleatorios, @cantidad_clases)
      histograma = RmSimulacionMontecarlo::Histograma.generar_histograma(precios_aleatorios, @cantidad_clases)
      RmSimulacionMontecarlo::Histograma.grafica_histograma(clases , histograma, @informacion_titulo)    
    end

    # Se hace wraper de las siguientes métodos
    def posicion
      @posicion 
    end

    def precio_mercado
      # Precio Mercado a la fecha de estudio
      # Este precio puede ser de un título o del portafolio para negociacion o vencimiento
      # Se divide por 100 para que no sea porcentaje    
      @precio_mercado / 100
    end

    def self.archivo_precios_aleatorios(parte_aleatoria_nombre_archivo)
      "/archivos_planos/excel/valores_aleatorios_#{parte_aleatoria_nombre_archivo}.csv"
    end

    private
    def generar_csv(precios_aleatorios)
       CSV.open(RmSimulacionMontecarlo::Simulador.archivo_precios_aleatorios(parte_aleatoria_nombre_archivo), "wb") {|csv| precios_aleatorios.each {|precio| csv << [precio] }}
    end

  end
end
