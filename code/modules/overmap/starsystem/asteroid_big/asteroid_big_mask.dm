
/obj/effect/overmapobj/bigasteroid/proc/step_masking()
	set background = 1
	. = 1

	//optimised start
	if(gen_x < centre_turf.x - config.target_radius)
		gen_x = centre_turf.x - config.target_radius
	if(gen_y < centre_turf.y - config.target_radius)
		gen_y = centre_turf.y - config.target_radius

	//fill in the next turf inside a circle around centre_turf
	current_turf = locate(gen_x, gen_y, myzlevel.z)
	var/dx = current_turf.x - centre_turf.x
	var/dy = current_turf.y - centre_turf.y
	var/val = dx*dx + dy*dy

	//if we're within the radius, put a mask down
	if(val <= rsq)
		var/turf/unsimulated/mask/M = new(current_turf)
		map_turfs += M

		/*if(mask_turfs.len > 20)
			return 0*/

		//if we're on the edge of the radius, mark us as a "corner" turf
		//corners are various points spread around the circumference for us to morph later
		if(val >= corner_dist)
			corner_turfs += M
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

/*
/obj/effect/overmapobj/bigasteroid/proc/generate_asteroid_mask(var/zlevel_num)
	set background = 1

	//loop over space turfs

	var/max_dist = 80
	var/turf/centre_turf = locate(127, 127, zlevel_num)

	//loop over all the space turfs and setup the asteroid

	//not true corners, but a series of points scattered around the circle
	var/list/corner_turfs = list()
	var/corner_dist = max_dist * max_dist
	var/rsq = max_dist * (max_dist+0.5)
	for(var/curx = 1, curx <= world.maxx, curx++)
		for(var/cury = 1, cury <= world.maxy, cury++)
			var/turf/cur_turf = locate(curx, cury, zlevel_num)

			var/dx = cur_turf.x - centre_turf.x
			var/dy = cur_turf.y - centre_turf.y
			var/val = dx*dx + dy*dy

			if(val <= rsq)
				var/turf/unsimulated/mask/M = new(cur_turf)
				if(val >= corner_dist)
					corner_turfs += M
					if(overmap_controller.mark_points_of_interest)
						new /obj/effect/spider/cocoon(M)

	//quick and dirty morph algorithm to make the asteroid non-spherical
	//loop over the "corner" turfs (a handful of turfs scattered around the edge of the asteroid)
	//each one will have either expand or contract the asteroid shape so that it looks vaguely natural
	var/total_weight = overmap_controller.expand_weight + overmap_controller.contract_weight + overmap_controller.skip_weight
	//overmap_controller.average_morph_diameter = sqrt(overmap_controller.max_turfs)

	while(corner_turfs.len)

		var/repeats = rand(overmap_controller.repeats_lower, overmap_controller.repeats_upper)
		var/last_dir = 0

		if(prob(100 * (overmap_controller.expand_weight / total_weight)) && last_dir < 1)
			//expand
			last_dir = 1
			while(repeats > 0 && corner_turfs.len)
				var/mark_type
				if(overmap_controller.mark_points_of_interest)
					mark_type = /obj/effect/rune
				morph_mask(/turf/space, /turf/unsimulated/mask, corner_turfs, mark_type)
				repeats--

		else if(prob(100 * (overmap_controller.contract_weight / total_weight)) && last_dir > -1)
			//contract
			last_dir = -1
			while(repeats > 0 && corner_turfs.len)
				var/mark_type
				if(overmap_controller.mark_points_of_interest)
					mark_type = /obj/effect/golemrune
				morph_mask(/turf/unsimulated/mask, /turf/space, corner_turfs, mark_type)
				repeats--

		else
			//skip
			last_dir = 0
			repeats = rand(overmap_controller.skips_lower, overmap_controller.skips_upper)
			while(repeats > 0 && corner_turfs.len)
				pop(corner_turfs)
				repeats--
*/

/*
/obj/effect/overmapobj/bigasteroid/verb/generate_masks()
	//set src in view(7)
	set background = 1

	generate_asteroid_mask(src.z)
*/
