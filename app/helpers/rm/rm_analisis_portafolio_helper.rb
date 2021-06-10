module Rm
  module RmAnalisisPortafolioHelper
    def precio_mercado_o_nulo(precio_mercado)
      if precio_mercado
        "#{number_with_precision(precio_mercado.to_f, :delimiter => ".", :separator => ",", :precision => 4)} %"
      else
        " --- SIN PRECIO ---- "
      end
    end

    def resaltar_excepcion_backtesting(_hash, columna_calculo)
      if _hash[columna_calculo].to_f > _hash['var+'].to_f
        "excepcion_sobre_lo_estimado"
      elsif _hash[columna_calculo].to_f < _hash['var-'].to_f
        "excepcion_bajo_lo_estimado"
      else
        ""
      end
    end

  end
end
