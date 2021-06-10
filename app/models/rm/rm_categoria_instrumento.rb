module Rm
	class RmCategoriaInstrumento < ActiveRecord::Base
		self.table_name = 'rm_categorias_instrumentos'
		#has_paper_trail
		validates :codigo, :presence => true, :uniqueness => true
		validates :nombre, :presence => true

		rails_admin do
			parent RmBaseCalculo
      label_plural 'Categorias Instrumentos'
      object_label_method do
        :nombre
      end
		end
	end
end