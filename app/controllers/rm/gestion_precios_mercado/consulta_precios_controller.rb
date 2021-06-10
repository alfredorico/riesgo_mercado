module Rm
  module GestionPreciosMercado
    class ConsultaPreciosController < ApplicationController
      authorize_resource class: ConsultaPrecios
      def new
        @consulta_precios = ConsultaPrecios.new
        unless RmPrecioMercado.any?
          redirect_to baseweb.root_path, notice: "Debe cargar un histórico de precios mercado para gestionar los precios"
        end 
      end

      def create
        #render plain: params.inspect
        @consulta_precios = ConsultaPrecios.new(params[:gestion_precios_mercado_consulta_precios])
        unless @consulta_precios.valid?        
          render 'new'
        end         
      end
      
      def eliminar_titulos_consultados
        RmPrecioMercado.delete(params[:rm_precios_mercado_ids])
      end
      
    end
  end
end
