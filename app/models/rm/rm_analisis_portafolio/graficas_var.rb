module Rm
	class RmAnalisisPortafolio::GraficasVar
		def self.lineas(serie, columna, nombre_serie, color)
	    LazyHighCharts::HighChart.new('graph') do |grafico|
	      grafico.options[:chart][:height] = "300"
	      grafico.options[:chart][:defaultSeriesType] = "line"
	      grafico.options[:title][:text] = ""
	      grafico.rangeSelector({:buttons => [{:type => 'all', :text => 'Todos'}]})
	      #Se debe hacer un reverse para que las fechas salgán del pasado al futuro en las gráficas.
	      grafico.series(:name => nombre_serie, :data => serie.reverse.map { |obj| ["#{Time.utc(obj.fecha_snapshot.to_date.year, obj.fecha_snapshot.to_date.month, obj.fecha_snapshot.to_date.day).to_i}000".to_i, obj[columna].to_f.round(8)] }, :color => color)
	    end
		end
	end
end
