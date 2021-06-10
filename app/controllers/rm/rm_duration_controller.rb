module Rm
	class RmDurationController < ApplicationController
		authorize_resource

		def new
			@rm_duration = RmDuration.new
		end

		def create
			@rm_duration = RmDuration.new(params[:rm_duration])
			unless @rm_duration.valid?
				render 'new'
			end			
		end
			
	end
end
