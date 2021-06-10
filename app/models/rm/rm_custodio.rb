module Rm
	class RmCustodio < ActiveRecord::Base
		self.table_name = 'rm_custodios'#has_paper_trail
		validates :codigo, :presence => true, :uniqueness => true
		validates :nombre, :presence => true

		rails_admin do
			parent RmBaseCalculo
      label_plural 'Custodios'
      object_label_method do
        :nombre
      end
		end
	end
end
