module Rm
  module GestionPreciosMercado
    class RmPreciosMercadoController < ApplicationController
      load_and_authorize_resource
      before_action :set_rm_precio_mercado, only: [:show, :edit, :update, :destroy]
      def new
        @rm_precio_mercado = RmPrecioMercado.new
      end
      
      def create
        @rm_precio_mercado = RmPrecioMercado.new(rm_precio_mercado_params)
        if @rm_precio_mercado.save
          redirect_to gestion_precios_mercado_rm_precio_mercado_path(@rm_precio_mercado), notice: "Transacción de título #{@rm_precio_mercado.codigo_titulo} insertada"
        else 
          render 'new'
        end
      end
      
      def edit
      end
      
      def show
      end

      def update
        if @rm_precio_mercado.update(rm_precio_mercado_params)
          redirect_to gestion_precios_mercado_rm_precio_mercado_path(@rm_precio_mercado), notice: "Transacción de título #{@rm_precio_mercado.codigo_titulo} actualizada"
        else
          render :edit
        end
      end

      def destroy
        codigo_titulo = @rm_precio_mercado.codigo_titulo
        @rm_precio_mercado.destroy
        redirect_to new_gestion_precios_mercado_consulta_precios_url, notice: "Transacción de título #{codigo_titulo} actualizada"
      end

      
      private
      # Use callbacks to share common setup or constraints between actions.
      def set_rm_precio_mercado
        @rm_precio_mercado = RmPrecioMercado.find(params[:id])
      end

      # Only allow a trusted parameter "white list" through.
      def rm_precio_mercado_params
        params.require(:rm_precio_mercado).permit(:fecha_snapshot, :codigo_titulo, :nombre, :monto, :precio_compra, :precio_mercado, :fecha_vencimiento, :tasa_cupon)
      end      
      
    end
  end
end
