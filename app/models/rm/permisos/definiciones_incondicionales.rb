module Rm
  module Permisos::DefinicionesIncondicionales

    def accesos_incondicionales
      cannot [:new, :destroy], RmParametrosVarMercado
    end

  end
end
