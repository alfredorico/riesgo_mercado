module Rm
	class RmTipoProductoPasivo < ActiveRecord::Base
		self.table_name = 'rm_tipos_productos_pasivos'
		validates :nombre, :presence => true

		rails_admin do
			parent RmBaseCalculo
      label_plural 'Tipos de Productos Pasivos'
      object_label_method do
        :nombre
      end
		end
	end
end