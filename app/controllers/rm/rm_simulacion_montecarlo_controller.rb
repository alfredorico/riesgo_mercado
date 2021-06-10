module Rm
  class RmSimulacionMontecarloController < ApplicationController
    authorize_resource

    def new
      @rm_simulacion_montecarlo = RmSimulacionMontecarlo.new
    end

    def create
      @rm_simulacion_montecarlo = RmSimulacionMontecarlo.new(params[:rm_simulacion_montecarlo])
      if @rm_simulacion_montecarlo.valid?
        if RmAntecedenteTitulo.titulos_con_muestras_insuficientes(@rm_simulacion_montecarlo.tipo_cartera).empty? # Si no hay titulos con muestras insuficientes
          respond_to do |format|
            format.html do
              case @rm_simulacion_montecarlo.funcionalidad # --> RmSimulacionMontecarlo::FUNCIONALIDAD
                when 0 then # HISTOGRAMA 
                  render 'histograma'
                when 1 then # SIMULACION
                  render 'simulacion'
                else
                  render 'new'
              end
            end
          end
        else
          redirect_to new_rm_antecedente_titulo_path
        end
      else
        render 'new'
      end
    end

    def listar_titulos
      @titulos = RmAnalisisPortafolio::TipoCartera.titulos(params[:tipo_cartera].to_i)
      respond_to do |format|
        format.js
      end
    end  

    def descargar_valores_aleatorios
      if params[:token]    
        send_file RmSimulacionMontecarlo::Simulador.archivo_precios_aleatorios(params[:token])
      else
        redirect_to new_rm_simulacion_montecarlo_path
      end
    end

  end
end
