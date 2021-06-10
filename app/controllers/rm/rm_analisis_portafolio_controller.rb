module Rm
  class RmAnalisisPortafolioController < ApplicationController
    authorize_resource

    def new
      @rm_analisis_portafolio = RmAnalisisPortafolio.new
    end

    def create
      @rm_analisis_portafolio = RmAnalisisPortafolio.new(params[:rm_analisis_portafolio])
      if @rm_analisis_portafolio.valid?
        if RmAntecedenteTitulo.titulos_con_muestras_insuficientes(@rm_analisis_portafolio.tipo_cartera).empty? # Si no hay titulos con muestras insuficientes
          respond_to do |format|
            format.html do
              case @rm_analisis_portafolio.tipo_de_gestion
              when 0 then # 'REPORTE CONSOLIDADO'
                render 'reporte_consolidado'
              when 1 then #'VAR TITULOS'
                render 'var'
              when 2,3 then # 'BACKTESTING POSICION - BACKTESTING PRECIOS'
                render 'backtesting'
              else
                render 'new'
              end
            end
            format.xlsx { send_file RmAnalisisPortafolio::Excel.exportar_reporte_consolidado(@rm_analisis_portafolio.reporte_consolidado) }
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

  end
end
