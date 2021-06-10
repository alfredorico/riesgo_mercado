class RmPrecioMercado < ActiveRecord::Base
  
  validates :precio_mercado, :monto, :precio_compra, :tasa_cupon, numericality: {greater_than: 0}, presence: true
  validates :nombre, presence: true
  validates :codigo_titulo, :fecha_snapshot, presence: true, if: :new_record?
  validates :codigo_titulo, uniqueness: { scope: :fecha_snapshot, message: "Ya existe el título suministrado para la fecha indicada" }
  validate :fecha_snapshot_rmid
  
  def self.titulos
		sql = <<-SQL
       select codigo_titulo, concat(codigo_titulo,' - ',nombre) as nombre_titulo
        from rm_precios_mercado
          group by codigo_titulo, nombre
            order by codigo_titulo;
		SQL
		ActiveRecord::Base.connection.select_all sql
  end

  # Para las graficas mostradas de la historia del titulo en "Antecedentes titulos para negociar"
  def self.historia_titulo(codigo_titulo)
    sql = <<-QUERY
      select fecha_snapshot, precio_compra, precio_mercado from rm_precios_mercado
        where codigo_titulo = '#{codigo_titulo}' order by fecha_snapshot asc;
    QUERY
    ActiveRecord::Base.connection.select_all sql
  end
  
  private
  def fecha_snapshot_rmid
    if self.fecha_snapshot > RmInversionDiaria.maximum(:fecha_snapshot)
      errors.add(:fecha_snapshot, "La fecha indicada no puede ser superior a la última fecha de carga presente en RMID: #{RmInversionDiaria.maximum(:fecha_snapshot).strftime('%d/%m/%Y')}")
    end
  end

end
