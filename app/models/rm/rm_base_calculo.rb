module Rm
	class RmBaseCalculo < ActiveRecord::Base
		self.table_name = 'rm_bases_calculos'
		validates :nombre, :presence => true
		validates :dias_vencimiento, :presence => true, :numericality => {:greater_than => 0}
		validates :dias_interes, :presence => true, :numericality => {:greater_than => 0}

		rails_admin do
			navigation_label 'Riesgo de Mercado'
      label_plural 'Bases de Calculo'
      object_label_method do
        :nombre
      end
		end
	end
end