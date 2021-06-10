module Rm
	class RmSimulacionMontecarlo::RmParametrosSimulacionMontecarlo < ActiveRecord::Base
		#has_paper_trail 
		self.table_name = 'rm_parametros_simulacion_montecarlo'

		rails_admin do
			parent RmBaseCalculo
      label_plural 'Parametros Simulacion de Montecarlo'
		end
	end
end
