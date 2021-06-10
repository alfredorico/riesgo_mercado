module Rm
	module Parametros::Administracion
		def self.rails_admin_included_models
			[ RmParametrosVarMercado, Rm::RmBaseCalculo, Rm::RmCategoriaInstrumento,
				Rm::RmCustodio, Rm::RmEmisor, Rm::RmTipoInstrumento, Rm::RmTipoInversion,
				Rm::RmTipoOperacion, Rm::RmTipoVencimientoPasivo,
				Rm::RmSimulacionMontecarlo::RmParametrosSimulacionMontecarlo, Rm::RmParametrosVarMercado
			]
   end
	end
end
