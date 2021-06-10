module Rm
  module GestionPreciosMercado
    class CargaMasiva::ArchivoPreciosMercado
      
      SEPARADORES = ['|',';',',']      
      attr_reader :ruta_archivo
      
      def initialize(ruta_archivo, separador = SEPARADORES.first)
        @ruta_archivo = ruta_archivo  
        @separador = SEPARADORES.include?(separador) ? separador : SEPARADORES.first              
      end
  
      def cargar
        sql =<<-QUERY
          SELECT cargar_archivo_precios_mercado('#{archivo_precios_mercado}','#{@separador}');
        QUERY
        ActiveRecord::Base.connection.execute(sql)
      ensure
        File.delete(@ruta_archivo) if File.exist?(archivo_precios_mercado)  
      end
      
      private      
      def archivo_precios_mercado
        extension = File.extname(@ruta_archivo).downcase
        case extension
        when '.csv'
          @ruta_archivo
        when '.xls','.xlsx'  
          convertir_excel_a_csv
          ruta_archivo_csv_tmp
        else
          raise "Debe subir un archivo Excel (XLSX) o CSV"
        end
      end     
      
      def convertir_excel_a_csv
        worksheet = RubyXL::Parser.parse(@ruta_archivo).first
        cantidad_columnas = worksheet.sheet_data[0].cells.size
        raise "Cantidad de columnas incorrectas en el archivo. Deben ser 8 columnas - Hay #{cantidad_columnas}" if cantidad_columnas != 8
        indice_ultima_fila = worksheet.sheet_data.size - 1
        csv = CSV.open(ruta_archivo_csv_tmp, "w",col_sep: @separador, quote_char: "\x00")
        csv << worksheet.sheet_data[0].cells.map{|c| c.value.strip }
        1.upto(indice_ultima_fila) do |i|
          @i = i + 1 # Para captura el número de línea en que posiblemente ocurrió el error.
        	celdas = worksheet.sheet_data[i].cells
        	#       FECHA_SNAPSHOT												CODIGO_TITULO	         NOMBRE	                MONTO	                PRECIO_COMPRA 	       PRECIO_MERCADO 	     FECHA_VENCIMIENTO	                   TASA_CUPON 
        	csv << [celdas[0].value.strftime("%d/%m/%Y"), celdas[1].value.strip, celdas[2].value.strip, celdas[3].value.to_f, celdas[4].value.to_f,  celdas[5].value.to_f, celdas[6].value.strftime("%d/%m/%Y"), celdas[7].value.to_f ]
        end
        csv.close        
      rescue => e 
        raise "Formato inválido en alguna columna de la línea #{@i} -> #{e.message}"
      end
      
      def ruta_archivo_csv_tmp
        "/tmp/rmpm.csv"
      end          
           
    end
  end
end
