module Rm
  class RmAntecedenteTitulo < ActiveRecord::Base
    self.table_name = 'rm_antecedentes_titulos'
    validate :validar_titulos

    # Atributos injertados. Es decir no son atributos de la tabla
    attr_accessor :titulos_candidatos, :muestras, :max_fecha_snapshot, :max_id

    before_save :asignar_antecedente_a_titulo_de_precios_mercado
    before_destroy :eliminar_antecedente_a_titulo_de_precios_mercado

    def cartera
      RmAnalisisPortafolio::TipoCartera.tipo(self.tipo_cartera) # Columna tipo_cartera de la tabla rm_antecedentes_titulos
    end

    def self.titulos_con_muestras_insuficientes(tipo_cartera)
      #TODO: Rediseñar este raise para reutilizar
      RmAnalisisPortafolio::TipoCartera.validar_codigo(tipo_cartera) # Se genera excepción si se envía como parámetro un código de cartera
                                                               # inválido al que se define en rm_carteras

      # Se obtiene el nombre de la tabla (cartera) dependiendo del tipo de cual selecciono en la interfaz
      tabla_cartera = RmAnalisisPortafolio::TipoCartera.tabla(tipo_cartera)
      sql = <<-QUERY
        select codigo_titulo
          from rm_precios_mercado
            group by codigo_titulo
              having codigo_titulo in ( select distinct(rm_inversion_codigo)
                                          from #{tabla_cartera}
                                         where fecha_snapshot = (select max(fecha_snapshot) from #{tabla_cartera})
                                      )
                 and count(precio_mercado) < (select numero_muestras_volatilidad_titulos from rm_parametros_var_mercado)
            order by codigo_titulo;
      QUERY
      ActiveRecord::Base.connection.select_all(sql).to_a
    end

    def self.titulos_para_asignar_historia
      _titulos_para_asignar_historia = []
      RmAnalisisPortafolio::TipoCartera.listar_tablas.each do |tabla_cartera, tipo_cartera|
        # Debido a que listar tablas viene como: [["rm_cartera_negociacion", "0"], ["rm_cartera_vencimiento", "1"], ["rm_cartera_fideicomiso_vencimiento", "20"], ["rm_cartera_sucursal_negociacion", "30"], ["rm_cartera_sucursal_vencimiento", "40"]]
        # El each usa do |tabla_cartera, tipo_cartera| ----------- tabla_cartera -> rm_cartera_negociacion --- tipo_cartera --> 0
        sql = <<-QUERY
          select max(id) as max_id,
                 codigo_titulo,
                 count(precio_mercado) muestras,
                 min(fecha_snapshot) - 5 as minima_fecha_menos_5,
                 min(fecha_snapshot) minima_fecha_snapshot_titulo_original,
                 max(fecha_snapshot) max_fecha_snapshot
            from rm_precios_mercado
              group by codigo_titulo
                having codigo_titulo in ( select distinct(rm_inversion_codigo)
                                            from #{tabla_cartera}
                                           where fecha_snapshot = (select max(fecha_snapshot) from #{tabla_cartera})
                                        )
                   and count(precio_mercado) < (select numero_muestras_volatilidad_titulos from rm_parametros_var_mercado)
                order by codigo_titulo;
        QUERY
        titulos = ActiveRecord::Base.connection.select_all(sql).to_a
        titulos.map! do |titulo|
          sql = <<-QUERY
            with BASE_TITULO as (
            select codigo_titulo,
                   count(precio_mercado) cantidad_muestras,
                   min(fecha_snapshot) - 5 as minima_fecha_menos_5,
                   min(fecha_snapshot) minima_fecha_snapshot_titulo_original
              from rm_precios_mercado
                  where codigo_titulo = '#{titulo['codigo_titulo']}' -- al titulo de estudio
                group by codigo_titulo
                  having codigo_titulo in ( select distinct(rm_inversion_codigo)
                                              from #{tabla_cartera}
                                             where fecha_snapshot = (select max(fecha_snapshot) from rm_precios_mercado))
                          and count(precio_mercado) < (select numero_muestras_volatilidad_titulos from rm_parametros_var_mercado)
                    order by codigo_titulo
            )
            select  codigo_titulo, max(id) as max_id, count(precio_mercado) cantidad_muestras
              from rm_precios_mercado
                where fecha_snapshot <= (select minima_fecha_snapshot_titulo_original from BASE_TITULO)
                 and codigo_titulo != '#{titulo['codigo_titulo']}'
                 and codigo_titulo in (select distinct(codigo_titulo)
                                          from rm_precios_mercado
                                          where fecha_snapshot between (select minima_fecha_menos_5 from BASE_TITULO)
                                                                   and (select minima_fecha_snapshot_titulo_original from BASE_TITULO)
                                            -- Y deben excluirse los titulos que ya se les asigno una historia
                                            and codigo_titulo not in (select codigo_titulo from rm_antecedentes_titulos)
                                            order by codigo_titulo
                                      )
                  group by codigo_titulo
                    having (count(fecha_snapshot) + (select cantidad_muestras from BASE_TITULO)) >= (select numero_muestras_volatilidad_titulos from rm_parametros_var_mercado)
                      order by codigo_titulo
          QUERY
          candidatos = ActiveRecord::Base.connection.select_all(sql).to_a
          titulo['titulos_candidatos'] = candidatos.map {|h| ["#{h['codigo_titulo']} - #{RmPrecioMercado.where(codigo_titulo: h['codigo_titulo']).order('fecha_snapshot desc').limit(1).first.nombre} - (#{h['cantidad_muestras']} muestras disponibles)", h['codigo_titulo']]}
          titulo
        end

        # Para cada cartera y
        #   para cada titulo de dicha cartera -> se crea un objeto nuevo de antecedente al que debe asignarsele un candidato
        titulos.each do |t|
          antecedente = RmAntecedenteTitulo.new( codigo_titulo: t['codigo_titulo'],
                                                 minima_fecha_snapshot_titulo_original: t['minima_fecha_snapshot_titulo_original'],
                                                 fecha_de_estudio_asignacion: Date.today,
                                                 tipo_cartera: tipo_cartera )
          antecedente.max_id = "#{t['max_id']}_#{tipo_cartera}" # Se concatena con tipo_cartera, para evitar conflicto cuando el titulo necesite
                                                                # antecedente y se encuentra en mas de una cartera. Caso: VB0224
          antecedente.titulos_candidatos = t['titulos_candidatos']
          antecedente.muestras = t['muestras']
          antecedente.max_fecha_snapshot = Date.parse(t['max_fecha_snapshot'])
          _titulos_para_asignar_historia << antecedente
        end
      end # Fin -  each tipo_cartera
      _titulos_para_asignar_historia
    end

    private
    def asignar_antecedente_a_titulo_de_precios_mercado
      sql =<<-QUERY
        SELECT asignar_antecedente_a_titulo_de_precios_mercado( '#{read_attribute(:codigo_titulo)}', '#{read_attribute(:codigo_titulo_asignado)}', '#{read_attribute(:minima_fecha_snapshot_titulo_original)}');
      QUERY
      ActiveRecord::Base.connection.execute sql
    end

    def eliminar_antecedente_a_titulo_de_precios_mercado
      sql =<<-QUERY
          SELECT eliminar_antecedente_a_titulo_de_precios_mercado( '#{read_attribute(:codigo_titulo)}', '#{read_attribute(:codigo_titulo_asignado)}', '#{read_attribute(:minima_fecha_snapshot_titulo_original)}');
      QUERY
      ActiveRecord::Base.connection.execute sql
    end

    def validar_titulos
      # Validación normal en la que se debe seleccionar un título del combo.
      if codigo_titulo_asignado.blank?
        errors[:base] << "Debe seleccionar un título como antecedente"
      end
    end

  end
end
