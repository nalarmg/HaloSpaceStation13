/obj/effect/zlevelinfo/bigasteroid/var/obj/effect/morphmarker/starting_morph

/obj/effect/zlevelinfo/bigasteroid/proc/step_masking()
	set background = 1
	. = 1

	//optimised start
	if(gen_x < centre_turf.x - config.target_radius)
		gen_x = centre_turf.x - config.target_radius
	if(gen_y < centre_turf.y - config.target_radius)
		gen_y = centre_turf.y - config.target_radius

	//fill in the next turf inside a circle around centre_turf
	current_turf = locate(gen_x, gen_y, src.z)
	var/dx = current_turf.x - centre_turf.x
	var/dy = current_turf.y - centre_turf.y
	var/val = dx*dx + dy*dy

	//if we're within the radius, put a mask down
	if(val <= rsq)
		var/turf/unsimulated/mask/M = new(current_turf)
		map_turfs |= M

		/*if(mask_turfs.len > 20)
			return 0*/

		//if we're on the edge of the radius, mark us as a "corner" turf
		//corners are various points spread around the circumference for us to morph later
		if(val >= corner_dist)
			corner_turfs += M
			if(!starting_morph)
				starting_morph = new /obj/effect/morphmarker(M)
			else
				new /obj/effect/morphmarker(M)
			/*if(overmap_controller.mark_points_of_interest)
				new /obj/effect/spider/cocoon(M)*/

		//a shortcut to end early
		if(gen_y > config.target_radius + centre_turf.y)
			gen_x = 1
			gen_y = 1
			return 0

	//increment the coords for the next step
	gen_x += 1
	if(gen_x > centre_turf.x + config.target_radius)
		gen_x = centre_turf.x - config.target_radius
		gen_y += 1

	//reset everything if we're done masking
	if(gen_y > centre_turf.y + config.target_radius)
		gen_y = centre_turf.y - config.target_radius
		. = 0

	/*if(map_turfs.len >= 20)
		. = 0*/

/obj/effect/zlevelinfo/bigasteroid/proc/arrange_morph_markers()
	set background = 1
	var/list/arranged_morphs = list(starting_morph)
	starting_morph.name = "1"

	var/obj/effect/morphmarker/next_morph = starting_morph
	var/list/dir_priorities = list(WEST, NORTHWEST, NORTH, NORTHEAST, EAST, SOUTHEAST, SOUTH, SOUTHWEST)
	while(next_morph)

		//world << "next_morph ([next_morph.x],[next_morph.y])"
		var/obj/effect/morphmarker/chosen_morph
		var/turf/myturf = next_morph.loc
		next_morph = null
		for(var/curdist = 1, curdist < 10, curdist++)
			//world << "	curdist:[curdist]"
			var/list/nearby = orange(curdist, myturf)

			for(var/curdir in dir_priorities)
				//world << "		curdir:[curdir]"

				for(var/obj/effect/morphmarker/check_morph in nearby)
					if(check_morph in arranged_morphs)
						continue

					var/checkdir = get_dir(myturf, check_morph)
					//world << "			checkdir:[checkdir] ([check_morph.x],[check_morph.y])"
					if(curdir == checkdir)
						chosen_morph = check_morph
						chosen_morph.name = "[arranged_morphs.len + 1]"
						arranged_morphs.Add(chosen_morph)
						next_morph = chosen_morph
						//world << "				success! ([next_morph.x],[next_morph.y])"
						break

				if(chosen_morph)
					break

			if(chosen_morph)
				break

		sleep(1)
