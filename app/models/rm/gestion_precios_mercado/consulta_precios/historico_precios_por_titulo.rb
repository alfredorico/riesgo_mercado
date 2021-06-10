module Rm
  module GestionPreciosMercado
    class ConsultaPrecios::HistoricoPreciosPorTitulo
      def initialize(parametros = {})
        @fecha_desde = parametros.fetch(:fecha_desde)
        @fecha_hasta = parametros.fetch(:fecha_hasta)
        @codigo_titulo = parametros.fetch(:codigo_titulo)
      end
      
      def buscar
        sql = <<-SQL 
          select id, fecha_snapshot, codigo_titulo, nombre, monto, precio_compra, precio_mercado, fecha_vencimiento, tasa_cupon
            from rm_precios_mercado
           where fecha_snapshot between '#{@fecha_desde.to_s}' and '#{@fecha_hasta.to_s}'
             and codigo_titulo = '#{@codigo_titulo}'
        SQL
        @buscar ||= ActiveRecord::Base.connection.select_all(sql).to_a
      rescue
        []        
      end
      
    end
  end
end
