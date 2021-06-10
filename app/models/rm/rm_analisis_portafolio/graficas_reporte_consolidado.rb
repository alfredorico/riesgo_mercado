module Rm
  module RmAnalisisPortafolio::GraficasReporteConsolidado
    def self.lineas(categorias, serie, titulo_grafica, titulo_serie, color)
      LazyHighCharts::HighChart.new('graph') do |grafico|
        grafico.options[:chart][:height] = "400"
        grafico.options[:chart][:defaultSeriesType] = "line"
        grafico.options[:title][:text] = titulo_grafica
        grafico.plotOptions(:column => {:dataLabels => {:enabled => true, :rotation => -35, :color => '#000', :align => 'left'}})
        grafico.xAxis(:categories => categorias, :labels => {:rotation => -90, :align => 'right'})
        grafico.series(:name => titulo_serie, :data => serie, :color => color)
      end
  	end
  end
end
