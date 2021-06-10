module Rm
  module Permisos::Definiciones

    DESCRIPCION = 'GESTIÓN DE RIESGO DE MERCADO'
    RM_RAILS_ADMIN_CLASES = [ ]
    # ----------------------------------------------------------------
    def gestion_catalogos_riesgo_mercado
      can [:edit, :read], RmParametrosVarMercado
      parametrizacion
    end
    
    def gestion_catalogos_riesgo_mercado__desc
      {nodo_menu: 11, descripcion: 'Modificar catálogos para riesgo de mercado'}
    end

    # ----------------------------------------------------------------
    def auditoria_catalogos_riesgo_mercado
      can [:read], RmParametrosVarMercado
      parametrizacion
    end
    
    def auditoria_catalogos_riesgo_mercado__desc
      {nodo_menu: 11, descripcion: 'Auditar catálogos para riesgo de mercado'}
    end

    # ----------------------------------------------------------------
    def carga_masiva
      can [:new, :create], GestionPreciosMercado::CargaMasiva 
    end

    def carga_masiva__desc
      {nodo_menu: Baseweb::Menu.ids_menus_para_cancan(263), descripcion: 'Carga masiva de precios mercado'}
    end

    # ----------------------------------------------------------------
    def consulta_precios
      can [:new, :create], GestionPreciosMercado::ConsultaPrecios
      can :read, RmPrecioMercado      
    end

    def consulta_precios__desc
      {nodo_menu: Baseweb::Menu.ids_menus_para_cancan(262), descripcion: 'Consulta de transacciones de precios mercado (sólo lectura)'}
    end   
    
    # ----------------------------------------------------------------    
    def editar_transaccion_precios_mercado
      consulta_precios
      can [:update, :show], RmPrecioMercado
    end
     
    def editar_transaccion_precios_mercado__desc
      {nodo_menu: Baseweb::Menu.ids_menus_para_cancan(262), descripcion: 'Consulta y edición de transacciones de precios mercado'}
    end   

    # ----------------------------------------------------------------    
    def eliminar_transaccion_precios_mercado
      consulta_precios
      can [:destroy], RmPrecioMercado
    end
     
    def eliminar_transaccion_precios_mercado__desc
      {nodo_menu: Baseweb::Menu.ids_menus_para_cancan(262), descripcion: 'Consulta y eliminación de transacciones de precios mercado'}
    end   

    # ----------------------------------------------------------------    
    def eliminacion_masiva_precios_mercado
      consulta_precios
      can :eliminar_titulos_consultados,  GestionPreciosMercado::ConsultaPrecios
    end
     
    def eliminacion_masiva_precios_mercado__desc
      {nodo_menu: Baseweb::Menu.ids_menus_para_cancan(262), descripcion: 'Eliminación masiva de precios mercado consultados'}
    end   
    
    # ----------------------------------------------------------------    
    def rm_analisis_portafolio
      can [:new, :create, :listar_titulos],  RmAnalisisPortafolio      
      can [:new], RmAntecedenteTitulo # Este permiso se asgina sólo para poder redirigir a la interfaz cuando no hay muestras 
                                      # suficientes. El usuario debe tener el permiso requerido 
                                      # si desea asignar los precios mercado.
    end
     
    def rm_analisis_portafolio__desc
      { nodo_menu: Baseweb::Menu.ids_menus_para_cancan(251), 
        descripcion: <<-STR
           Análisis del portafolio de inversiones de títulos valores comprendiendo el acceso a:
           * Cálculo VaR
           * Cálculo Backtesting
           * Reporte Consolidado
        STR
      }
    end  
     
    # ----------------------------------------------------------------    
    def rm_antecedentes_titulos
      can [:new, :create, :destroy, :grafica_comportamiento_historico ],  RmAntecedenteTitulo
    end
     
    def rm_antecedentes_titulos__desc
      { nodo_menu: Baseweb::Menu.ids_menus_para_cancan(260), 
        descripcion: 'Asignación de antecedes históricos a títulos de mercado'        
      }
    end 

    # ----------------------------------------------------------------    
    def auditoria_rm_antecedentes_titulos
      can [:new, :grafica_comportamiento_historico ],  RmAntecedenteTitulo
    end
     
    def auditoria_rm_antecedentes_titulos__desc
      { nodo_menu: Baseweb::Menu.ids_menus_para_cancan(260), 
        descripcion: 'Auditar la asignación efectuada de antecedes históricos a títulos de mercado'        
      }
    end 

    # ----------------------------------------------------------------    
    def rm_cvar
      can [:new, :create ],  RmCvar
    end
     
    def rm_cvar__desc
      { nodo_menu: Baseweb::Menu.ids_menus_para_cancan(257), 
        descripcion: 'Cálculo C-VaR para el portafolio de mercado'        
      }
    end     
    
    # ----------------------------------------------------------------    
    def rm_duration
      can [:new, :create ],  RmDuration
    end
     
    def rm_duration__desc
      { nodo_menu: Baseweb::Menu.ids_menus_para_cancan(255), 
        descripcion: 'Cálculo duration para el portafolio de mercado'        
      }
    end           
    
    # ----------------------------------------------------------------    
    def rm_parametros_duration
      can [:lista, :actualizar, :editar ],  :rm_parametros_duration
    end
     
    def rm_parametros_duration__desc
      { nodo_menu: Baseweb::Menu.ids_menus_para_cancan(254), 
        descripcion: 'Ajuste de parámetros duration para el portafolio de mercado'        
      }
    end 

    # ----------------------------------------------------------------    
    def auditor_rm_parametros_duration
      can [:lista ],  :rm_parametros_duration
    end
     
    def auditor_rm_parametros_duration__desc
      { nodo_menu: Baseweb::Menu.ids_menus_para_cancan(254), 
        descripcion: 'Auditoría de los parámetros duration para el portafolio de mercado'        
      }
    end           
    
    # ----------------------------------------------------------------    
    def rm_simulacion_montecarlo
      can [:new, :create, :listar_titulos, :descargar_valores_aleatorios ],  RmSimulacionMontecarlo
    end
     
    def rm_simulacion_montecarlo__desc
      { nodo_menu: Baseweb::Menu.ids_menus_para_cancan(252), 
        descripcion: 'Simulación de Montecarlo para el cálculo VaR de títulos'        
      }
    end         

  end
end
