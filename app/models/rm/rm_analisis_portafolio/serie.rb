module Rm
class RmAnalisisPortafolio::Serie

		def initialize(fecha_de_estudio, tipo_cartera, rm_inversion_codigo = nil)
			@fecha_de_estudio = fecha_de_estudio
			raise "Tipo de Cartera Inválida" unless RmAnalisisPortafolio::TipoCartera.listar_codigos.include?(tipo_cartera)
	  	@tipo_cartera = tipo_cartera
	  	@rm_inversion_codigo = rm_inversion_codigo.present? ? rm_inversion_codigo : nil
		end

		def valor_primer_dia(columna)
	    # Si envía un sym se convierte a string
			serie.first[columna.to_s].to_f
		end

		def serie
	    if @rm_inversion_codigo
	      sql = <<-QUERY
	        with CTE as (
	          select fecha_snapshot, coalesce(precio_mercado,0) precio_mercado, posicion, valor_nominal, valor_adquisicion
	            from #{RmAnalisisPortafolio::TipoCartera.tabla(@tipo_cartera)}_y_rmpm
	              where rm_inversion_codigo = '#{@rm_inversion_codigo}'
	              and fecha_snapshot <= '#{@fecha_de_estudio.to_s}'
	              and posicion is not null
	          UNION -- Ahora se une con la cola de precios mercado
	           select fecha_snapshot, precio_mercado, 0, 0, 0
	            from rm_precios_mercado
	              where fecha_snapshot < (select min(fecha_snapshot) as fecha
	                                        from #{RmAnalisisPortafolio::TipoCartera.tabla(@tipo_cartera)}_y_rmpm
	                                          where rm_inversion_codigo = '#{@rm_inversion_codigo}')
	                and codigo_titulo = '#{@rm_inversion_codigo}'
	           order by fecha_snapshot desc
	        )
	        select row_number() over () as muestra,
	               fecha_snapshot,
	               precio_mercado as precio, -- NOTA: se hace un alias para efectos de var_titulos.html.erb. Ojo con su impacto
	               posicion,
	               valor_nominal,
	               valor_adquisicion,
	               (valor_nominal * precio_mercado) / 100 as valor_segun_mercado,
	               coalesce ((((valor_nominal * precio_mercado) / 100) - #{pivote_gp_nr}),0) as gp_nr
	          from CTE
	          --  where precio_mercado is not null
	      QUERY
	    else
	      sql = <<-QUERY
	          with CTE1 as (
	            select fecha_snapshot,
	                 valor_adquisicion,
	                 valor_nominal,
	                 sum(posicion) over (PARTITION BY fecha_snapshot order by fecha_snapshot desc) posicion,
	                 valor_nominal * precio_mercado / (sum(valor_nominal) over (PARTITION BY fecha_snapshot order by fecha_snapshot desc)) as ponderacion
	            from #{RmAnalisisPortafolio::TipoCartera.tabla(@tipo_cartera)}_y_rmpm
	            where posicion is not null
	            -- and precio_mercado is not null
	            -- Solo se considera para el dia a efectos de hallar los valores
	            and fecha_snapshot <= '#{@fecha_de_estudio.to_s}'
	              order by fecha_snapshot desc, rm_inversion_codigo desc
	          ),
	          CTE2 as(
	            select  fecha_snapshot, posicion, round(sum(ponderacion),4) as precio_ponderado, sum(valor_nominal) as valor_nominal,
	                    sum(valor_adquisicion) as valor_adquisicion
	              from CTE1
	                group by fecha_snapshot, posicion  having sum(ponderacion) is not null
	                  order by fecha_snapshot desc
	          )
	          select row_number() over( ) as muestra,
	                 fecha_snapshot,
	                 valor_adquisicion,
	                 valor_nominal,
	                 posicion,
	                 (valor_nominal * precio_ponderado) / 100 as valor_segun_mercado,
	                 (((valor_nominal * precio_ponderado) / 100) - #{pivote_gp_nr}) as gp_nr, -- se invoca al metodo privado al final
	                 precio_ponderado as precio, -- NOTA: se hace un alias para efectos de var_titulos.html.erb. Ojo con su impacto
	                 round((precio_ponderado / lead(precio_ponderado) over ()),10) - 1 as variacion,
	                 precio_ponderado  - lead(precio_ponderado ) over () as variacion_absoluta,
	                 round( ln(precio_ponderado / lead(precio_ponderado) over ()),10) as rendimiento
	            from CTE2
	      QUERY
	    end
	    @serie ||= ActiveRecord::Base.connection.select_all(sql).to_a
		end

		def serie_variaciones
	    @serie_variaciones ||= if @rm_inversion_codigo.present?
	                             if no_hay_concidencia_entre_maxima_fecha_en_serie_y_maxima_fecha_en_variaciones_precios_mercado?
	                               [] # Entonces para ese día no debe haber serie por que no hay precio_mercado.
	                                  # En consecuencia la volatilidad y el VaR debe ser 0
	                             else
	                      		     serie_precios_mercado_y_variaciones.map {|s| s['variacion'].to_f }
	                             end
	                           else
	                             # para el portafolio se basa en la serie
	                             serie.map {|s| s['variacion'].to_f }
	                           end
		end

	  def serie_precios_mercado_y_variaciones
	    # En este caso no podemos reutilizar la serie debido a la posible existencia de huecos en
	    # la cartera xxx (negociacion, vencimiento, fideicomiso, etc)
	    # Unicamente se basa en los precios mercado
	    @serie_precios_mercado_y_variaciones ||= if @rm_inversion_codigo.present?
	                                               sql = <<-QUERY
	                                                 with CTE1 as (
	                                                   select fecha_snapshot, precio_mercado
	                                                     from rm_precios_mercado
	                                                       where codigo_titulo = '#{@rm_inversion_codigo}' -- dado que asumo que son titulos comunes.
	                                                       and fecha_snapshot <= '#{@fecha_de_estudio.to_s}'
	                                                         order by fecha_snapshot desc
	                                                 ) select fecha_snapshot,
	                                                          precio_mercado as precio,
	                                                          round((precio_mercado / lead(precio_mercado) over ()),9) - 1 as variacion,
	                                                          precio_mercado - lead(precio_mercado) over () as variacion_absoluta,
	                                                          round( ln(precio_mercado / lead(precio_mercado) over ()),10) as rendimiento
	                                                    from CTE1
	                                               QUERY
	                                               ActiveRecord::Base.connection.select_all(sql).to_a
	                                             else
	                                               serie.map {|s| {'fecha_snapshot' => s['fecha_snapshot'], 'precio' => s['precio'].to_f, 'variacion' => s['variacion'].to_f, 'variacion_absoluta' => s['variacion_absoluta'].to_f, 'rendimiento' => s['rendimiento'] }}
	                                             end

	  end

	  # -------------------------------------------------------------------------------------------------------------------------------------
	  # Métodos usados por la simulación de montecarlo
	  def serie_precios_mercado
	    @serie_precios_mercado ||= serie_fecha_y_precios_mercado.map {|s| s['precio'].to_f}
	  end

	  def serie_fecha_y_precios_mercado
	    @serie_fecha_y_precios_mercado ||= if @rm_inversion_codigo.present?
	                                     # En este caso no podemos reutilizar la serie debido a la posible existencia de huecos en
	                                     # la cartera xxx (negociacion, vencimiento, fideicomiso, etc)
	                                     # Unicamente se basa en los precios mercado
	                                     sql = <<-QUERY
	                                       select precio_mercado as precio, fecha_snapshot
	                                         from rm_precios_mercado
	                                           where codigo_titulo = '#{@rm_inversion_codigo}' -- dado que asumo que son títulos comunes.
	                                           and fecha_snapshot <= '#{@fecha_de_estudio.to_s}'
	                                             order by fecha_snapshot desc
	                                     QUERY
	                                     ActiveRecord::Base.connection.select_all(sql).to_a
	                                   else
	                                     # Para el portafolio se basa en la serie
	                                     serie.map {|s| {'fecha_snapshot' => Date.parse(s['fecha_snapshot']) , 'precio' => s['precio'].to_f} }
	                                   end
	  end
	  # -------------------------------------------------------------------------------------------------------------------------------------

		# Este método modifica la serie calculada con el fin de desplazarla para backtesting, así como también desplaza
	  # la serie de la desviación estandar para el caso del var de títulos individuales.
		# La serie no puede ser reconstruida a menos que se instancie un nuevo objeto
		def serie_shift!
			serie_variaciones.shift # Se extrae la fecha más reciente (cabeza de la serie de desviacion estandar) para provocar un desplazamiento hacía abajo. Este caso es para var de titulo individual
			serie.shift # Se extrae la fecha más reciente (cabeza de la serie) para provocar un desplazamiento hacía abajo
	    nil # no devuelve nada intencionalmente!
		end

	  # Este método es usado por la clase RmAnalisisPortafolio::ReporteConsolidado
		def titulos_en_cartera_a_la_fecha_de_estudio # Titulos en cartera para la fecha de estudio
			# Las tablas de carteras según RmAnalisisPortafolio::TipoCartera.listar_tabla son:
			# [["rm_cartera_negociacion", 0], ["rm_cartera_vencimiento", 1], ["rm_cartera_fideicomiso_vencimiento", 20], ["rm_cartera_sucursal_negociacion", 30], ["rm_cartera_sucursal_vencimiento", 40]]
			sql = <<-QUERY
				select distinct(rm_inversion_codigo) titulo
					from #{RmAnalisisPortafolio::TipoCartera.tabla(@tipo_cartera)}
				 where fecha_snapshot = '#{@fecha_de_estudio}' and posicion is not null
				 order by titulo
			QUERY
			@titulos_en_cartera_a_la_fecha_de_estudio ||= ActiveRecord::Base.connection.select_all(sql).to_a.map { |h| h['titulo'] }
		end

	  def titulos_en_cartera_que_no_existen_en_precios_mercado
	    # Sólo se dejan los títulos de la cartera que no existen en RM_PRECIOS_MERCADO
	    titulos_en_cartera_a_la_fecha_de_estudio - RmPrecioMercado.titulos.map{ |h| h['codigo_titulo']}
	  end

	  def no_hay_concidencia_entre_maxima_fecha_en_serie_y_maxima_fecha_en_variaciones_precios_mercado?
	    maxima_fecha_del_titulo_en_serie_precios_mercado_y_variaciones != maxima_fecha_del_titulo_en_serie
	  end

	  def maxima_fecha_del_titulo_en_serie_precios_mercado_y_variaciones
	    Date.parse(serie_precios_mercado_y_variaciones.first['fecha_snapshot'])
	  end

	  def maxima_fecha_del_titulo_en_serie
	    Date.parse(serie.first['fecha_snapshot'])
	  end

	  private

	  # pivote_gp_nr: Este método se usa en la generación de la serie debido a una nueva regla de negocio
	  # implementada por BNC para el cálculo del GP_NR: La nueva regla indica que:
	  # (((valor_nominal * precio_ponderado) / 100) - X) donde
	  # X -> sum(valor_libros) si la cartera es "AL VENCIMIENTO (BANCO)"
	  # X -> sum(valor_libros) si la cartera es "FIDEICOMISO AL VENCIMIENTO"
	  def pivote_gp_nr
	    case @tipo_cartera
	      when 1, 20  # AL VENCIMIENTO y "FIDEICOMISO AL VENCIMIENTO"
	        'posicion' # -> sum(valor_libros)
	      else
	        'valor_adquisicion'
	    end
	  end

	end
end
