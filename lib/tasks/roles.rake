namespace :roles do
  desc 'Crear roles predeterminados para riesgo mercado'
  task rm: [:environment] do
    ActiveRecord::Base.transaction do
      ActiveRecord::Base.connection.execute <<-SQL
        delete from permisos_asignados where rol_id in (100);
        delete from roles where id in (100);
      SQL
      r = Baseweb::Rol.create(id: 100, nombre: 'ROL_RIESGO_MERCADO', predeterminado: true)
      r.permisos_asignados.create(permiso: 'gestion_catalogos_riesgo_mercado')
      r.permisos_asignados.create(permiso: 'auditoria_catalogos_riesgo_mercado')      
      r.permisos_asignados.create(permiso: 'carga_masiva')
      r.permisos_asignados.create(permiso: 'editar_transaccion_precios_mercado')
      r.permisos_asignados.create(permiso: 'eliminar_transaccion_precios_mercado')
      r.permisos_asignados.create(permiso: 'eliminacion_masiva_precios_mercado')
      r.permisos_asignados.create(permiso: 'consulta_precios')
      r.permisos_asignados.create(permiso: 'rm_analisis_portafolio')
      r.permisos_asignados.create(permiso: 'rm_antecedentes_titulos')
      r.permisos_asignados.create(permiso: 'auditoria_rm_antecedentes_titulos')
      r.permisos_asignados.create(permiso: 'rm_cvar')
      r.permisos_asignados.create(permiso: 'rm_duration')
      r.permisos_asignados.create(permiso: 'rm_parametros_duration')
      r.permisos_asignados.create(permiso: 'rm_simulacion_montecarlo')
    end
  end
end
