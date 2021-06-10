module Rm
	class RmDuration::RmCalculoDuration
		
		attr_accessor :fecha_de_estudio, :titulos, :matriz_duration, :total_cartera, :dp, :dmp

		def initialize(atributos = {})
			@fecha_de_estudio = atributos[:fecha_de_estudio]
			@titulos = titulos @fecha_de_estudio
			@matriz_duration = calculo_duration @titulos
			@total_cartera = total_posicion_cartera
	    @dp = duration_portafolio
	    @dmp = duration_modificada_portafolio
		end

		#El universo de titulos es el que se encuentre en la cartera de negociacion
	  def titulos(fecha)
	  	sql = <<-sql
	      select distinct(rmcn.rm_inversion_codigo) as codigo 
	         from rm_cartera_negociacion rmcn
	         where rmcn.fecha_snapshot = '#{fecha.to_s}'
	      intersect 
	      select distinct(codigo_titulo) 
	         from rm_precios_mercado rmpm
	         where rmpm.fecha_snapshot = '#{fecha.to_s}'
	    sql
	  	ActiveRecord::Base.connection.select_all(sql).to_a
	  end

	  def calculo_duration(titulos)
	  	resultado = []
	    titulos.each do |titulo|
	    	x = RmDuration::RmInversionDuration.new({rm_inversion_codigo: titulo['codigo'], fecha: @fecha_de_estudio})
	    	resultado << {"codigo" => titulo['codigo'], "posicion" => x.posicion ,"rendimiento_efectivo" => x.rendimiento_efectivo, "duration" => x.duration, "duration_modificada" => x.duration_modificada}
	    end
	    resultado
	  end

	  def total_posicion_cartera
	    @matriz_duration.map{|titulo| titulo["posicion"].to_f}.sum
	  end

	  def duration_portafolio
	    total = 0
	    @matriz_duration.each do |x|
	      total+= (x["posicion"].to_f / total_posicion_cartera )*(x["duration"].to_f)
	    end
	    total
	  end

	  def duration_modificada_portafolio
	    total = 0
	    @matriz_duration.each do |x|
	      total+= (x["posicion"].to_f / total_posicion_cartera )*(x["duration_modificada"].to_f)
	    end
	    total
	  end

	end
end
