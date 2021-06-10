module Rm
  module GestionPreciosMercado
    class CargaMasivaController < ApplicationController
      authorize_resource
      def new
        @carga_masiva = CargaMasiva.new
      end

      def create
        @carga_masiva  = CargaMasiva.new(params[:gestion_precios_mercado_carga_masiva])
        unless @carga_masiva.cargar_archivo
          render 'new'
        end  
      end
      
    end
  end
end
