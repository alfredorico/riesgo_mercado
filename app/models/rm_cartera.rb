# encoding: utf-8
class RmCartera < ActiveRecord::Base
	# Sólo se listan las que estén activas
	def self.listar
		where(activo: true)
	end
end