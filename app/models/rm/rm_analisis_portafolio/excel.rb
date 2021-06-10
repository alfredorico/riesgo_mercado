module Rm
	class RmAnalisisPortafolio::Excel

		def self.exportar_reporte_consolidado(rc)
			raise "La Clase RmAnalisisPortafolio::ExportarExcel debe recibir como parámetro un objeto de tipo RmAnalisisPortafolio::ReporteConsolidado" unless rc.is_a?(RmAnalisisPortafolio::ReporteConsolidado)
	    ruta = "/archivos_planos/excel/valorizacion-de-mercado-#{rc.fecha_de_estudio.strftime('%d-%m-%Y')}.xlsx"

	    p = Axlsx::Package.new
	    wb = p.workbook
	    wb.styles do |s|
	      titulo_reporte = s.add_style(:b => true, :fg_color => "1C2553", :sz => 12, :alignment=>{:horizontal => :center})
	      titulo_tabla = s.add_style(:b => true, :fg_color => "1C2553", :sz => 10)
	      titulo_columna =  s.add_style(:b => true, :bg_color => "1C2553", :fg_color => "FF",:sz => 9)
	      titulo_columna_centrado =  s.add_style(:b => true, :bg_color => "1C2553", :fg_color => "FF",:sz => 9,:alignment=>{:horizontal => :center, :vertical => :center}, :border => { :style => :thin, :color =>"FF" } )
	      borde = s.add_style(:border => Axlsx::STYLE_THIN_BORDER)
	      centrado = s.add_style(:alignment=>{:horizontal => :center})

	      reporte_titulos = rc.reporte_titulos
	      reporte_portafolio  = rc.reporte_portafolio

	      # Reporte consolidado de cada titulo
	      wb.add_worksheet(:name => "Títulos del portafolio") do |sheet|
	        sheet.show_gridlines = false
	        6.times {sheet.add_row}
	        img = Estilos::Logos.ruta_logo_cliente
	        sheet.add_image(:image_src => img, :noSelect => true, :noMove => true, :hyperlink=>"http://da.com.ve") do |image|
	          image.width=Estilos::Logos.width(Estilos::Logos.ruta_logo_cliente)
	          image.height=Estilos::Logos.height(Estilos::Logos.ruta_logo_cliente)
	          image.hyperlink.tooltip = "Labeled Link"
	          image.start_at 0, 0
	        end
	        sheet.add_row ["REPORTE CONSOLIDADO DE VALORIZACIÓN DE LA CARTERA AL #{rc.fecha_de_estudio.strftime('%d/%m/%Y')}"], :style => [titulo_reporte]
	        sheet.merge_cells("A7:F7")
	        #Primera tabla
	        sheet.add_row
	        sheet.merge_cells("A9:F9")
	        sheet.add_row ['DETALLE DEL PORTAFOLIO DE NEGOCIACIÓN (VaR PARA TITULOS DE LA CARTERA)'], :style => [titulo_tabla]
	        sheet.add_row
	        sheet.column_widths 10, nil, nil, nil, nil, nil, nil, 15, nil
	        sheet.add_row ['CODIGO', 'VALOR NOMINAL', 'POSICION',  'PRECIO MERCADO',  'VALOR ADQUISICION', 'VALOR SEGUN MERCADO', 'G/P NR', 'VOLATILIDAD', 'VAR'], :style => ([titulo_columna] * 9)
	        reporte_titulos .each do |item|
	          sheet.add_row [item["rm_inversion_codigo"], item["valor_nominal"].to_f.round(4),item["posicion"].to_f.round(4),item["precio"].to_f.round(4),item["valor_adquisicion"].to_f.round(4),item["valor_segun_mercado"].to_f.round(4),item["gp_nr"].to_f.round(4), item["volatilidad"].to_f.round(4) * 100.0,item["var"].to_f.round(4) ], :style => Axlsx::STYLE_THIN_BORDER
	        end


	      end

	      wb.add_worksheet(:name => "Reporte Consolidado") do |sheet|
	        sheet.show_gridlines = false
	        6.times {sheet.add_row}
	        img = Estilos::Logos.ruta_logo_cliente
	        sheet.add_image(:image_src => img, :noSelect => true, :noMove => true, :hyperlink=>"http://da.com.ve") do |image|
	          image.width=Estilos::Logos.width(Estilos::Logos.ruta_logo_cliente)
	          image.height=Estilos::Logos.height(Estilos::Logos.ruta_logo_cliente)
	          image.hyperlink.tooltip = "Labeled Link"
	          image.start_at 0, 0
	        end
	        sheet.add_row ["REPORTE CONSOLIDADO DE VALORIZACIÓN DE LA CARTERA AL #{rc.fecha_de_estudio.strftime('%d/%m/%Y')}"], :style => [titulo_reporte]
	        sheet.merge_cells("A7:F7")
	        #Primera tabla
	        sheet.add_row
	        sheet.merge_cells("A9:F9")
	        sheet.add_row ['Cálculos para el portafolio de negociación'], :style => [titulo_tabla]
	        sheet.add_row

	        item = reporte_portafolio
	        sheet.add_row ['VALOR NOMINAL', item["valor_nominal"].to_f.round(4)], :style => Axlsx::STYLE_THIN_BORDER
	        sheet.add_row ['POSICION', item["posicion"].to_f.round(4)], :style => Axlsx::STYLE_THIN_BORDER
	        sheet.add_row ['PRECIO MERCADO',  item["precio_mercado"].to_f.round(4)], :style => Axlsx::STYLE_THIN_BORDER
	        sheet.add_row ['VALOR DE ADQUISICIÓN',  item["valor_adquisicion"].to_f.round(4)], :style => Axlsx::STYLE_THIN_BORDER
	        sheet.add_row ['VALOR SEGUN MERCADO', item["valor_segun_mercado"].to_f.round(4)], :style => Axlsx::STYLE_THIN_BORDER
	        sheet.add_row ['GP N/R',  item["gp_nr"].to_f.round(4)], :style => Axlsx::STYLE_THIN_BORDER
	        sheet.add_row ['VOLATILIDAD', item["volatilidad"].to_f.round(4) * 100.0], :style => Axlsx::STYLE_THIN_BORDER
	        sheet.add_row ['VaR', item["var"].to_f.round(4)], :style => Axlsx::STYLE_THIN_BORDER

	      end


	      wb.add_worksheet(:name => "Resumen Adicional") do |sheet|
	        sheet.show_gridlines = false
	        6.times {sheet.add_row}
	        img = Estilos::Logos.ruta_logo_cliente
	        sheet.add_image(:image_src => img, :noSelect => true, :noMove => true, :hyperlink=>"http://da.com.ve") do |image|
	          image.width=Estilos::Logos.width(Estilos::Logos.ruta_logo_cliente)
	          image.height=Estilos::Logos.height(Estilos::Logos.ruta_logo_cliente)
	          image.hyperlink.tooltip = "Labeled Link"
	          image.start_at 0, 0
	        end
	        sheet.add_row ["REPORTE CONSOLIDADO DE VALORIZACIÓN DE LA CARTERA AL #{rc.fecha_de_estudio.strftime('%d/%m/%Y')}"], :style => [titulo_reporte]
	        sheet.merge_cells("A7:F7")
	        #Primera tabla
	        sheet.add_row
	        sheet.merge_cells("A9:F9")
	        sheet.add_row ['Cálculos resumen adicionales'], :style => [titulo_tabla]
	        sheet.add_row
	        sheet.add_row ['SUMATORIA VaR INDIVIDUALES', rc.sumatoria_var_individuales.to_f.round(4)], :style => Axlsx::STYLE_THIN_BORDER
	        sheet.add_row ['VaR CONSOLIDADO PORTAFOLIO', rc.var_consolidado_de_portafolio.to_f.round(4)], :style => Axlsx::STYLE_THIN_BORDER
	        sheet.add_row ['EFECTO DIVERSIFICACION',  rc.efecto_diversificacion.to_f.round(4)], :style => Axlsx::STYLE_THIN_BORDER
	        sheet.add_row ['VaR 1 DIA DE GESTION',  rc.var_1_dia_de_gestion.to_f.round(4)], :style => Axlsx::STYLE_THIN_BORDER
	        sheet.add_row ['VaR 10 DIAS REGULATORIO', rc.var_10_dias_regulatorio.to_f.round(4)], :style => Axlsx::STYLE_THIN_BORDER


	      end
	    end
	    p.serialize(ruta)
	    ruta

		end
	end
end
