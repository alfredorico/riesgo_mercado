module Rm
  class RmCvarController < ApplicationController
    authorize_resource

    def new
      @rm_cvar = RmCvar.new
    end

    def create
      @rm_cvar = RmCvar.new(params[:rm_cvar])
      if @rm_cvar.valid?      
        if RmAntecedenteTitulo.titulos_con_muestras_insuficientes(@rm_cvar.tipo_cartera).present? # 
          redirect_to new_rm_antecedente_titulo_path
        else
          respond_to do |format|
            format.html
            format.xlsx { send_file RmCvar::Excel.exportar_cvar(@rm_cvar.resultado_cvar) }
          end
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
