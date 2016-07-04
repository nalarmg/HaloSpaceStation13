
/obj/effect/overmapobj/bigasteroid/proc/pick_new_morph()
	. = 1

	//quick and dirty morph algorithm to make the asteroid non-spherical
	//loop over the "corner" turfs (a handful of turfs scattered around the edge of the asteroid)
	//each one will have either expand or contract the asteroid shape so that it looks vaguely natural
	//eventually i'll get around to writing a new automata random_map algorithm (which will look much nicer, see caves for an example)
	//in the meantime this will do
	if(corner_turfs.len)
		if(repeats_left > 0)
			repeats_left--
		else
			repeats_left = rand(config.repeats_lower, config.repeats_upper)
			var/total_weight = config.expand_weight + config.contract_weight + config.skip_weight

			//world << "pick_new_morph() expand:[100 * (config.expand_weight / total_weight)] contract:[100 * (config.contract_weight / total_weight)] last_dir:[last_dir] repeats_left:[repeats_left]"
			if(prob(100 * (config.expand_weight / total_weight)) && last_dir < 1)
				//expand
				last_dir = 1
				/*var/mark_type
				if(overmap_controller.mark_points_of_interest)
					mark_type = /obj/effect/rune*/

				trigger_type = /turf/space
				spawn_type = /turf/unsimulated/mask

			else if(prob(100 * (config.contract_weight / total_weight)) && last_dir > -1)
				//contract
				last_dir = -1
				/*var/mark_type
				if(overmap_controller.mark_points_of_interest)
					mark_type = /obj/effect/golemrune*/

				trigger_type = /turf/unsimulated/mask
				spawn_type = /turf/space

			else
				//skip
				last_dir = 0
				trigger_type = null
				spawn_type = null
				repeats_left = rand(config.skips_lower, config.skips_upper)
				while(repeats_left > 0 && corner_turfs.len)
					pop(corner_turfs)
					repeats_left--

		if(!last_dir)
			return pick_new_morph()

		//reset everything for the next go
		morph_turf = pop(corner_turfs)
		morphing_turfs = list(morph_turf)
		num_processed = 0

		/*if(last_dir > 0)
			new /obj/effect/rune(morph_turf)
		else if(last_dir < 0)
			new /obj/effect/golemrune(morph_turf)
		else
			new /obj/effect/spresent(morph_turf)*/

	else
		. = 0
