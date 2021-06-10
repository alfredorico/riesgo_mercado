module Rm
	class RmSimulacionMontecarlo::NumerosAleatorios
		DISTRIBUCIONES = [['NORMAL',0],['T-STUDENT',1],['LOGISTICA',2],['GAMMA',3],['BETA',4],['LOGNORMAL',5],['WEIBULL',6]]

		def initialize(atributos)
	    @distribucion_estadistica = atributos[:distribucion_estadistica]
	    @df = atributos[:df]
	    @shape1 = atributos[:shape1]
	    @shape2 = atributos[:shape2]    
	    @shape = atributos[:shape]
	    @scale = atributos[:scale]
	    @mean = atributos[:mean]
	    @stddev = atributos[:stddev]
	    @metodo_de_calculo = atributos[:metodo_de_calculo]
	    @serie_valores = atributos[:serie_valores]
	    @serie_valores_rendimientos = atributos[:serie_valores_rendimientos]
		end

	  # Utilizando lenguaje r_ruby
	  def generar_numeros_aleatorios(cantidad)    
	    r_ruby = RinRuby.new(false)
	    r_ruby.eval "library('truncdist')"
	    case @distribucion_estadistica
	      when 0
	        r_ruby.eval <<-R
	          aleatorios <- rnorm(#{cantidad}, mean = #{media_serie_valores}, sd = #{desviacion_estandar_serie_valores})
	        R
	      when 1 # T-STUDENT         
	        r_ruby.eval <<-R          
	          aleatorios <- rtrunc(#{cantidad}, spec="t", a=#{limite_inferior},b=#{limite_superior}, df = #{@df})
	        R
	      when 2 # LOGISTIC
	        r_ruby.eval <<-R          
	          aleatorios <- rtrunc(#{cantidad}, spec="logis", a=#{limite_inferior},b=#{limite_superior}, location = #{@mean}, scale = #{@scale})
	        R
	      when 3 # GAMMA
	        r_ruby.eval <<-R          
	          aleatorios <- rtrunc(#{cantidad}, spec="gamma", a=#{limite_inferior},b=#{limite_superior}, shape = #{@shape}, scale = #{@scale})
	        R
	      when 4 # BETA
	        r_ruby.eval <<-R          
	          aleatorios <- rtrunc(#{cantidad}, spec="beta", a=#{limite_inferior},b=#{limite_superior}, shape1 = #{@shape1}, shape2 = #{@shape2})
	        R
	      when 5 # LOGNORMAL
	        r_ruby.eval <<-R          
	          aleatorios <- rtrunc(#{cantidad}, spec="lnorm", a=#{limite_inferior},b=#{limite_superior}, meanlog = #{@mean}, sdlog = #{@stddev})
	        R
	      when 6 # WEIBULL
	        r_ruby.eval <<-R          
	          aleatorios <- rtrunc(#{cantidad}, spec="weibull", a=#{limite_inferior},b=#{limite_superior}, shape = #{@shape}, scale = #{@scale})
	        R
	    end 
	    aleatorios = r_ruby.pull("aleatorios")
	    r_ruby.quit
	    r_ruby = nil
	    return aleatorios
	  end

		private  
	  def limite_inferior
	    media_serie_valores - (desviacion_estandar_serie_valores*2.5)
	  end  

	  def limite_superior
	    media_serie_valores + (desviacion_estandar_serie_valores*2.5)
	  end

		# --- Métodos requeridos para la distribución
	  def media_serie_valores # promedio
	    case @metodo_de_calculo
	      when 0 # METODO DE VOLATILIDADES
	      	0 # La media es 0 para este caso
	      when 1 # METODO DE PRECIOS MERCADO
	        @serie_valores_rendimientos.sum / @serie_valores_rendimientos.size
	    end
	  end

	  def desviacion_estandar_serie_valores
	    case @metodo_de_calculo
	      when 0 # METODO DE VOLATILIDADES
	        @serie_valores_rendimientos.desviacion_estandar 
	      when 1 # METODO DE PRECIOS MERCADO
	        @serie_valores_rendimientos.desviacion_estandar
	    end
	  end

	  public
		# --------------------------------------------------
		def self.codigo_distribucion_default
			DISTRIBUCIONES[0][1] # Código 0 para distribución normal	
		end

	end
end
