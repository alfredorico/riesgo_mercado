module Rm
  module GestionPreciosMercado
    class ConsultaPrecios::PreciosEnUnDia
      def initialize(parametros)
        @fecha_snapshot = parametros.fetch(:fecha_snapshot)
      end
      
      def buscar
        sql = <<-SQL 
          select id, fecha_snapshot, codigo_titulo, nombre, monto, precio_compra, precio_mercado, fecha_vencimiento, tasa_cupon
            from rm_precios_mercado
           where fecha_snapshot = '#{@fecha_snapshot.to_s}'
           order by codigo_titulo
        SQL
        @buscar ||= ActiveRecord::Base.connection.select_all(sql).to_a        
      end
      
    end
  end
end
