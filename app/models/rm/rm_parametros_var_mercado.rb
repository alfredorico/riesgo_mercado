module Rm
	class RmParametrosVarMercado < ActiveRecord::Base
 		self.table_name = 'rm_parametros_var_mercado' #has_paper_trail
 		validates :numero_muestras_desviacion_estandar, :presence => true, numericality:{ :greater_than => 0, :only_integer => true}
 		validates :numero_muestras_volatilidad_titulos, :presence => true, numericality:{ :greater_than => 0, :only_integer => true}
 		validates :maxima_cantidad_muestras_backtesting, :presence => true, numericality:{ :greater_than => 0, :only_integer => true}
		
		rails_admin do
			parent RmBaseCalculo
      label_plural 'Parametros Var Mercado'
		end

	end
end