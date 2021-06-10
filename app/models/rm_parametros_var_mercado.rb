class RmParametrosVarMercado < ActiveRecord::Base
	has_paper_trail
 validates :numero_muestras_desviacion_estandar, :presence => true, numericality:{ :greater_than => 0, :only_integer => true}
 validates :numero_muestras_volatilidad_titulos, :presence => true, numericality:{ :greater_than => 0, :only_integer => true}
 validates :maxima_cantidad_muestras_backtesting, :presence => true, numericality:{ :greater_than => 0, :only_integer => true}
 rails_admin do
	 navigation_label "Riesgo de Mercado"
	 label 'Parametro VaR Mercado'
	 label_plural 'Parametros VaR Mercado'
 end
end
