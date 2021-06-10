module Rm
	module RmAnalisisPortafolio::GraficasBacktesting
		def self.lineas(serie,columna_calculo_titulo, columna_calculo)
	    LazyHighCharts::HighChart.new('graph') do |grafico|
	      grafico.options[:chart][:height] = "400"
	      grafico.options[:chart][:defaultSeriesType] = "line"
	      grafico.options[:title][:text] = ""
	      grafico.series(:name => 'Var+', :data => serie.reverse.map { |obj| ["#{Time.utc(obj.fecha_snapshot.to_date.year, obj.fecha_snapshot.to_date.month, obj.fecha_snapshot.to_date.day).to_i}000".to_i, obj["var+"].to_f.round(2)] }, :color => "#4278FF")
	      grafico.series(:name => columna_calculo_titulo, :data => serie.reverse.map { |obj| ["#{Time.utc(obj.fecha_snapshot.to_date.year, obj.fecha_snapshot.to_date.month, obj.fecha_snapshot.to_date.day).to_i}000".to_i, obj[columna_calculo].to_f.round(2)] }, :color => "#984EFF")
	      grafico.series(:name => 'Var-', :data => serie.reverse.map { |obj| ["#{Time.utc(obj.fecha_snapshot.to_date.year, obj.fecha_snapshot.to_date.month, obj.fecha_snapshot.to_date.day).to_i}000".to_i, obj["var-"].to_f.round(2)] }, :color => "#75B252")
	    end
		end
	end
end
