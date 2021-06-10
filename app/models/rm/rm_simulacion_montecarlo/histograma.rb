module Rm
  module RmSimulacionMontecarlo::Histograma
    
    def self.generar_histograma(vector_valores, cantidad_clases)
      _vector_valores = generar_clases(vector_valores, cantidad_clases)
      hist = Array.new(_vector_valores.size) {0}
      vector_valores.each do |precio|
        _vector_valores.each_with_index do |clase, i|
          if precio >= clase[0] and precio <= clase[1]
            hist[i] += 1
          end
        end
      end
      hist
    end

    def self.generar_clases(vector_valores,cantidad_clases)
      raise "No hay vector_valores para calcular clases" if vector_valores.empty?
      precio_maximo = vector_valores.max
      precio_minimo = vector_valores.min
      incremento = (precio_maximo - precio_minimo) / cantidad_clases
      clases = [precio_minimo]
      1.upto(cantidad_clases - 1) do |i| # Se asume la existencia de la variable de instancia @cantidad_clases
        clases << (clases[i-1] + incremento).round(7) # para evitar que se solapen
      end
      #clases.shift # Se elimina el precio minimo
      clases << vector_valores.max # Se añade un tope muy grande para el último cuadrante

      # 1.9.3-p448 :024 > x = [83.65, 85.3259, 87.0018, 88.6777, 90.3536]
      # 1.9.3-p448 :025 > y = [ [83.65, 85.3259],[85.32600000000001, 87.0018],[87.0019, 88.6777], [88.6778, 90.3536] ]
      x = [[clases[0],clases[1]]]
      1.upto(clases.size-2) do |i|
        exponente = clases[i].to_s.split('.').last.size
        x << [(clases[i] + eval("1e-#{exponente}")).round(7),clases[i+1]]
      end
      x
    end

    def self.grafica_histograma(clases, histograma, texto = "Histograma")
      LazyHighCharts::HighChart.new('graph') do |grafico|
        grafico.options[:chart][:height] = '500'
        #grafico.options[:chart][:width] = '750'
        # NOTA: Se asume la existencia de la variable de instancia @rm_inversion_codigo en la clase que se hace el include
        grafico.options[:title][:text] = texto # Se la
        grafico.plotOptions(:column=> {:dataLabels=> {:enabled=>true, :color=> '#000',:rotation=>-30, :y => -10, :style => {:fontSize => '0.7em'}}},:series=>{:colorByPoint => true})
        grafico.xAxis(:categories => clases.map{|clase| "#{clase[0]} - #{clase[1]}"},:labels=>{:rotation=>-60, :align=>'right', :style => {:fontSize => '0.9em'}})
        grafico.series(type: 'spline', :name=>'Cantidad de vector_valores en la clase',:data => histograma,:color=>"#FF3F3F")
      end
    end

  end
end
