/datum/controller/subsystem/ParticleWeather/run_weather(datum/particle_weather/weather_datum_type, force = 0, color)
	if(!force && SSmapping && SSmapping.config && SSmapping.config.map_name == "Desert Town")
		var/path_to_check = weather_datum_type
		
		if(istext(weather_datum_type))
			for(var/V in subtypesof(/datum/particle_weather))
				var/datum/particle_weather/W = V
				if(initial(W.name) == weather_datum_type)
					path_to_check = V
					break
		
		if(ispath(path_to_check))
			var/is_allowed = FALSE
			
			// Allow fog and blood rain
			if(ispath(path_to_check, /datum/particle_weather/fog) || \
			   ispath(path_to_check, /datum/particle_weather/blood_rain_gentle) || \
			   ispath(path_to_check, /datum/particle_weather/blood_rain_storm))
				is_allowed = TRUE
				
			// If not allowed, we just return and cancel the weather
			if(!is_allowed)
				return
				
	return ..()
