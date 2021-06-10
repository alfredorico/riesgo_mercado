ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'rm_precio_mercado', 'rm_precios_mercado'
  inflect.irregular 'rm_analisis_portafolio', 'rm_analisis_portafolio'
  inflect.irregular 'rm_parametros_var_mercado', 'rm_parametros_var_mercado'
  inflect.irregular 'rm_antecedente_titulo','rm_antecedentes_titulos'
  inflect.irregular 'rm_simulacion_montecarlo','rm_simulacion_montecarlo'
  inflect.irregular 'rm_duration','rm_duration'
  inflect.uncountable %w( rm_parametros_duration )
  inflect.irregular 'rm_cvar','rm_cvar'
  inflect.irregular 'rm_precio_mercado', 'rm_precios_mercado'  
  inflect.uncountable 'consulta_precios'
  inflect.irregular 'carga_masiva', 'carga_masiva'
  
end
