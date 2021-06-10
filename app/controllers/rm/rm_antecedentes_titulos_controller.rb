module Rm
  class RmAntecedentesTitulosController < ApplicationController
    authorize_resource

    def new
      @titulos_para_asignar_historia = RmAntecedenteTitulo.titulos_para_asignar_historia
    end

    def create
      @rm_antecedente_titulo = RmAntecedenteTitulo.new(rm_antecedente_titulo_params)
      if @rm_antecedente_titulo.save!
        redirect_to new_rm_antecedente_titulo_path
      else
        flash[:error] = @rm_antecedente_titulo.errors[:base].join(" ")
        render 'new'
      end
    end

    def destroy
      antecedente = RmAntecedenteTitulo.find(params[:id])
      #render text: antecedente.inspect
      if antecedente.destroy.destroyed?
        flash[:notice] = "Antecedente de título eliminado"
      else
        flash[:error] = "Ocurrió un error al intentar eliminar el antecedente"
      end
      redirect_to new_rm_antecedente_titulo_path
    end

    def grafica_comportamiento_historico
      codigo_titulo = params[:id]
      @historia_titulo_mercado = RmPrecioMercado.historia_titulo( params[:id] )
      @grafica = LazyHighCharts::HighChart.new('graph') do |grafico|
        grafico.options[:chart][:width] = "850"
        grafico.options[:chart][:height] = "450"
        grafico.options[:chart][:defaultSeriesType] = "line"
        grafico.options[:title][:text] = "Historía del título #{codigo_titulo}"
        grafico.rangeSelector({:buttons=>[{:type=>'all',:text=>'Todos'}]})
        grafico.series(:name=>'Precio de compra',:data => @historia_titulo_mercado.collect {|obj| [ "#{Time.utc(obj.fecha_snapshot.to_date.year,obj.fecha_snapshot.to_date.month,obj.fecha_snapshot.to_date.day).to_i}000".to_i, obj["precio_compra"].to_f.round(2)]},:color=>"#4278FF")
        grafico.series(:name=>'Precio del Mercado',:data => @historia_titulo_mercado.collect {|obj| [ "#{Time.utc(obj.fecha_snapshot.to_date.year,obj.fecha_snapshot.to_date.month,obj.fecha_snapshot.to_date.day).to_i}000".to_i, obj["precio_mercado"].to_f.round(2)]},:color=>"#984EFF")
      end
      respond_to do |formato|
        formato.html {render :text => @historia_titulo_mercado, :layout => false}
        formato.js
      end
    end
    
    private
    def rm_antecedente_titulo_params
      params.require(:rm_antecedente_titulo).permit(:fecha_de_estudio_asignacion,
                                                    :minima_fecha_snapshot_titulo_original,
                                                    :codigo_titulo,
                                                    :tipo_cartera,
                                                    :codigo_titulo_asignado)
    end

  end
end
