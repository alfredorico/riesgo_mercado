module Rm
	class RmParametrosDurationController < ApplicationController
		before_filter :listar_titulos, only: [:editar, :lista]
		authorize_resource :class => false

		def editar
		end

		def lista
		end

		def actualizar
			@inversiones = params[:rm_inversiones]["rm_inversiones"]
			@rm_inversiones = RmInversion.update(@inversiones.keys, @inversiones.values)
			@rm_inversiones.reject! {|inversion| inversion.errors.empty? }
			if @rm_inversiones.empty?
				redirect_to lista_rm_parametros_duration_index_path
			else
				render 'editar'
			end
		end

		private

		def listar_titulos
			@rm_inversiones = RmInversion.order(:codigo)
		end 
	end
end
