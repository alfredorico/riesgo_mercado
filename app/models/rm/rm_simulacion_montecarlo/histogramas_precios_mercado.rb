module Rm
  class RmSimulacionMontecarlo::HistogramasPreciosMercado

    NUMERO_CLASES = [10,15,20,30,60]

    def initialize(atributos)
      @serie_precios_mercado = atributos.fetch(:serie_precios_mercado,[])
      @serie_precios_mercado_ln = atributos.fetch(:serie_precios_mercado_ln,[])
      @cantidad_clases = atributos.fetch(:cantidad_clases, NUMERO_CLASES.first)
      @texto = atributos.fetch(:texto, 'Histograma')
    end

    def persisted?
      false
    end

    # INTERFAZ PUBLICA
    # -------- CALCULO DE CLASES E HISTOGRAMAS ----------------------------------------
    public
    def clases
      RmSimulacionMontecarlo::Histograma.generar_clases(@serie_precios_mercado, @cantidad_clases)
    end

    def histograma_precios
      RmSimulacionMontecarlo::Histograma.generar_histograma(@serie_precios_mercado, @cantidad_clases)
    end

    #-- Con logaritmo neperiano -------------------------
    def clases_ln
      RmSimulacionMontecarlo::Histograma.generar_clases(@serie_precios_mercado_ln, @cantidad_clases)
    end

    def histograma_precios_ln
      RmSimulacionMontecarlo::Histograma.generar_histograma(@serie_precios_mercado_ln, @cantidad_clases)
    end

    # -- Graficación
    def grafica_histograma_precios
      RmSimulacionMontecarlo::Histograma.grafica_histograma(clases, histograma_precios, @texto)
    end

    def grafica_histograma_precios_ln
      RmSimulacionMontecarlo::Histograma.grafica_histograma(clases_ln, histograma_precios_ln, @texto)
    end

  end
end
