module Rm
	class RmTipoVencimientoPasivo < ActiveRecord::Base
		self.table_name = 'rm_tipos_vencimientos_pasivos'
		validates :nombre, :presence => true

		rails_admin do
			parent RmBaseCalculo
      label_plural 'Tipos de Vencimientos Pasivos'
      object_label_method do
        :nombre
      end
		end
	end
end