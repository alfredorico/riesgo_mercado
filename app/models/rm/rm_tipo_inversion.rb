module Rm
	class RmTipoInversion < ActiveRecord::Base
		self.table_name = 'rm_tipos_inversiones'
		validates :codigo, :presence => true, :uniqueness => true
		validates :nombre, :presence => true

		rails_admin do
			parent RmBaseCalculo
      label_plural 'Tipos de Inversiones'
      object_label_method do
        :nombre
      end
		end
	end
end
