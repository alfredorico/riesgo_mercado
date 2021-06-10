module Rm
	class RmEmisor < ActiveRecord::Base
		self.table_name = 'rm_emisores'
		validates :codigo, :presence => true, :uniqueness => true
		validates :nombre, :presence => true

		rails_admin do
			parent RmBaseCalculo
      label_plural 'Emisores'
      object_label_method do
        :nombre
      end
		end
	end
end