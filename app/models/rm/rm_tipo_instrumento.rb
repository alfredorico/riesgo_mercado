module Rm
	class RmTipoInstrumento < ActiveRecord::Base
		self.table_name = 'rm_tipos_instrumentos'
		#has_paper_trail
		validates :codigo, :presence => true, :uniqueness => true
		validates :nombre, :presence => true

		rails_admin do
			parent RmBaseCalculo
      label_plural 'Tipos de Instrumentos'
      object_label_method do
        :nombre
      end
		end
	end
end