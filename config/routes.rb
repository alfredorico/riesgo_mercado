Rm::Engine.routes.draw do
  resources :rm_analisis_portafolio, :only => [:new, :create] do
    get "listar_titulos", on: :collection
  end
  resources :rm_antecedentes_titulos, :only => [:new, :index, :create, :destroy] do
    # Realmente el parametro id se corresponde es con codigo_titulo. No con la columna id en sí.
    get 'grafica_comportamiento_historico', :on => :member, :constraints => { :id => /.+/ }
  end
  resources :rm_simulacion_montecarlo, :only => [:new, :index, :create] do
    get "listar_titulos", on: :collection
    get "descargar_valores_aleatorios", on: :collection
  end
  
  resources :rm_parametros_duration  do
    get 'editar', :on => :collection
    post 'actualizar', :on => :collection 
    get 'lista', :on => :collection   
  end
  resources :rm_duration, :only => [:new, :create]

  resources :rm_cvar, :only => [:new, :create] do
    get "listar_titulos", on: :collection
  end
  
  namespace :gestion_precios_mercado do
    resources :consulta_precios, only: [:new, :create] do
      delete 'eliminar_titulos_consultados', on: :collection
    end
    resources :rm_precios_mercado, except: [:index]
    resources :carga_masiva, only: [:new, :create]
    resources :borrado_masivo_fecha, only: [:new, :create]
    resources :borrado_masivo_titulo, only: [:new, :create]
  end
  

end
