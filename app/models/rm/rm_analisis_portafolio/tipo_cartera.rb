module Rm
	module RmAnalisisPortafolio::TipoCartera
		def self.listar_tipos
			 RmCartera.listar.map {|c| [c.nombre, c.codigo]}
	     # Este método retorna lo siguiente:
	     # [["DE NEGOCIACION", 0], ["AL VENCIMIENTO", 1], ["FIDEICOMISO AL VENCIMIENTO", 20], ["SUCURSAL (CURAZAO) PARA NEGOCIACION", 30], ["SUCURSAL (CURAZAO) AL VENCIMIENTO", 40]]
	  end

		def self.tipo(codigo)
			validar_codigo(codigo)
			listar_tipos.find{|par| par[1] == codigo}.first
			# Se devuelve el nombre de la cartera (columna nombre de rm_carteras)
		end

		def self.listar_codigos
			listar_tipos.map{|x| x.last }
		end

		def self.listar_tablas
			RmCartera.listar.map {|c| [c.tabla, c.codigo]}
		end

		def self.tabla(codigo)
			validar_codigo(codigo)
			listar_tablas.find{|par| par[1] == codigo}.first
			# Se devuelve la tabla de base de datos de la cartera (columna tabla de rm_carteras)
		end

		# Este método es usado por la petición ajax listar_titulos en rm_analizar_portafolio_controller
		def self.titulos(codigo)
			validar_codigo(codigo)
			# Se asume que las diferentes tablas de las diferentes carteras mantienen la estructura similar
			sql = <<-QUERY
			   select distinct(rm_inversion_codigo) as rm_inversion_codigo from #{tabla(codigo)} order by rm_inversion_codigo
			QUERY
			# Sólo se listarán los títulos que existan en la cartera y que también existan en precios mercado
	    ActiveRecord::Base.connection.select_all(sql).map { |t| t['rm_inversion_codigo'] } & RmPrecioMercado.titulos.map{ |h| h['codigo_titulo']}
		end

		def self.validar_codigo(codigo)
			unless listar_codigos.include?(codigo)
				raise "Tipo de Cartera Inválida. Los códigos válidos son: #{listar_codigos.join(' - ')}"
			end
		end
	end
end
