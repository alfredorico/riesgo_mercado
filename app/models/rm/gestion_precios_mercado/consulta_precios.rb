module Rm
  module GestionPreciosMercado
    class ConsultaPrecios
      # ---------------------------------------      
      include ActiveModel::Model
      validate :validar_fecha_especifica
      validate :validar_rangos_de_fechas
  		# ---------------------------------------      

      # Este hash es canónico
      TIPO_CONSULTA_PRECIOS_MERCADO = {
        consulta_fecha_especifica: 'Precios mercado de todos los títulos a la fecha indicada',
        consulta_rango_de_fechas: 'Histórico de precios para un título indicado'
      }

      # Para ser mostrados en el formulario
      attr_reader :fecha_hasta, :fecha_desde, :fecha_snapshot, :codigo_titulo, :tipo_consulta_precios, :rm_precios_mercado_ids
      
      def initialize(parametros = {})
        if parametros.blank?
          @tipo_consulta_precios = :consulta_fecha_especifica
          @fecha_snapshot = RmPrecioMercado.maximum(:fecha_snapshot)
          @fecha_desde = @fecha_snapshot - 2.years 
          @fecha_hasta = @fecha_snapshot
        else 
          @tipo_consulta_precios = parametros[:tipo_consulta_precios].to_sym 
          @fecha_snapshot = Util::Fecha.objeto_fecha(parametros[:fecha_snapshot]) 
          @fecha_desde = Util::Fecha.objeto_fecha(parametros[:fecha_desde])
          @fecha_hasta = Util::Fecha.objeto_fecha(parametros[:fecha_hasta])
          @codigo_titulo = parametros[:codigo_titulo] 
        end
      end
      
      def titulos_consultados
        @titulos_consultados ||= if valid?
                                   case @tipo_consulta_precios
                                     when :consulta_fecha_especifica
                                       ConsultaPrecios::PreciosEnUnDia.new({fecha_snapshot: @fecha_snapshot}).buscar
                                     when :consulta_rango_de_fechas
                                       ConsultaPrecios::HistoricoPreciosPorTitulo.new({fecha_desde: @fecha_desde, fecha_hasta: @fecha_hasta, codigo_titulo: @codigo_titulo}).buscar
                                   end
                                 else
                                   []
                                 end          
      end
      
      def self.codigos_titulos
        RmPrecioMercado.select(:codigo_titulo).distinct.order(:codigo_titulo).pluck(:codigo_titulo)
      end
      
      
      def consulta_fecha_especifica?
			    @tipo_consulta_precios == :consulta_fecha_especifica
		  end
		
  		def consulta_rango_de_fechas?
  			@tipo_consulta_precios == :consulta_rango_de_fechas
  		end
      
      private			
      # Validadores --------------------------------------------------------------------------------
      def validar_rangos_de_fechas
        if consulta_rango_de_fechas?  
          if @codigo_titulo.blank?
            errors.add(:codigo_titulo, 'Debe seleccionar un título')
          end
          if @fecha_desde.present? and @fecha_hasta.present?           
            if @fecha_desde >= @fecha_hasta
              errors.add(:fecha_desde, 'Las fechas de consulta están solapadas')
            end
          else
            if @fecha_desde.blank?
              errors.add(:fecha_desde, 'Debe seleccionar una fecha inicial de consulta')
            end
            if @fecha_hasta.blank?
              errors.add(:fecha_hasta, 'Debe selecionar una fecha final de consulta')
            end						
          end				
        end
      end
      
      def validar_fecha_especifica
        if consulta_fecha_especifica?
          if @fecha_snapshot.blank?
            errors.add(:fecha_snapshot, 'Debe seleccionar la fecha de consulta')					
          elsif @fecha_snapshot > RmPrecioMercado.maximum(:fecha_snapshot)
            errors.add(:fecha_snapshot, "No hay precios mercado con fecha superior a: #{ RmPrecioMercado.maximum(:fecha_snapshot).try(:strftime,"%d/%m/%Y")}")
          end			
        end
      end      
      
      

    end
  end
end
