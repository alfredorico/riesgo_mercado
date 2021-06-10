module Rm
	class RmParametrosVar < ActiveRecord::Base
		self.table_name = 'rm_parametros_var'
		rails_admin do
			parent RmBaseCalculo
      label_plural 'Parametros VAR'
		end
	end
end