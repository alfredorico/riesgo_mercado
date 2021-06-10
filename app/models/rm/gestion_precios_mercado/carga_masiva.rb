module Rm
  module GestionPreciosMercado
    class CargaMasiva
      # ---------------------------------------      
      include ActiveModel::Model
      attr_reader :archivo, :ruta_archivo_precios_mercado_subido, :error_de_carga,:ruta_archivo, :separador
      validate :debe_seleccionar_un_archivo
  		# ---------------------------------------            
  
      def initialize(parametros = {})
        if parametros.blank?        
          @separador = ArchivoPreciosMercado::SEPARADORES.first
        else
          @archivo = parametros[:archivo]
          @separador = parametros[:separador]        
        end
      end
      
      def cargar_archivo
        CargaMasiva::ArchivoPreciosMercado.new(ruta_archivo, @separador).cargar
        true
      rescue => e
        @error_de_carga = e
        # Para efectos de formulario
        errors.add(:archivo,"El archivo #{@ruta_archivo} no pudo ser cargado" )
        false
      end
       
       def ruta_archivo
         @ruta_archivo ||= preparar_archivo_subido(@archivo)
       end
                   
      private
      
      def debe_seleccionar_un_archivo
        unless @archivo
          errors.add(:archivo, 'Debe seleccionar un archivo')        
        end
      end
            
      def preparar_archivo_subido(obj_http_uploaded_file)
        raise "Para el archivo plano de precios mercado subido, se espera un objeto de tipo ActionDispatch::Http::UploadedFile" unless obj_http_uploaded_file.is_a?(ActionDispatch::Http::UploadedFile)
        tmp = obj_http_uploaded_file.tempfile
        @ruta_archivo_precios_mercado_subido = File.join('/tmp', obj_http_uploaded_file.original_filename)
        FileUtils.cp tmp.path, @ruta_archivo_precios_mercado_subido
        File.chmod(0664, @ruta_archivo_precios_mercado_subido)
        return @ruta_archivo_precios_mercado_subido
      end
  
    end
  end
end
