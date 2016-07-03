
/obj/effect/overmapobj/bigasteroid/proc/step_morphing()
	set background = 1
	. = 1

	if(!spawn_type || !trigger_type)
		log_admin("alert! step_morphing() failed because it didnt spawn_type or trigger_type were not set for asteroid ([src.x],[src.y],[src.myzlevel.z])")
		return 0

	//this proc amorphously (via random flood fill) expands or contracts one of the "corner" turfs we marked earlier to make the sphere non-uniform
	//early versions were a little tentacley, so i've tweaked the config settings to avoid most of that
	var/total_weight = config.pop_weight + config.rand_weight

	if(working_turfs.len && num_processed < config.max_turfs)
		//get the next turf and remove it from the list
		//a pick tends to create tentacley blobs, while a pop tends to create flattish blocks
		//how these are weighted finds a balance between the 2
		var/turf/cur_turf
		if(prob(100 * config.rand_weight / total_weight))
			cur_turf = pick(working_turfs)
		else
			cur_turf = working_turfs[1]
		working_turfs -= cur_turf

		//get all adjacent turfs
		var/list/nearby = orange(1, cur_turf)

		//replace the current turf
		mask_turfs -= cur_turf
		mask_turfs += new spawn_type(cur_turf)

		/*var/cur_dist = get_dist(start_turf, new_turf)
		if(do_mutation)
			world << "	curdist: [cur_dist]"
			if(cur_dist >= overmap_controller.average_morph_diameter * overmap_controller.diameter_percent_trigger)
				mutation_turf = new_turf*/

		//dont overwrite any turfs we have already processed later
		//this shouldnt error if the turfs arent on the list beforehand
		corner_turfs -= nearby

		//chance to spread the asteroid onto nearby mask tiles
		while(nearby.len)
			var/turf/T = pop(nearby)
			//nearby -= T
			if(istype(T, trigger_type) && prob(config.spread_chance))
				working_turfs.Add(T)

		//dont spread too far
		num_processed++

	/*if(mutation_turf)
		world << "mutation spawned at [mutation_turf.x],[mutation_turf.y]"
		corner_turfs += mutation_turf
		if(mark_type)
			new /obj/effect/spresent(mutation_turf)*/
	else
		. = 0

/*
/obj/effect/overmapobj/bigasteroid/proc/morph_mask(var/trigger_type, var/spawn_type, var/list/corner_turfs, var/mark_type)
	set background = 1

	var/num_processed = 0
	var/turf/start_turf = pop(corner_turfs)
	var/list/working_list = list(start_turf)
	var/total_weight = config.pop_weight + config.rand_weight
	if(mark_type)
		new mark_type(start_turf)

	/*var/turf/mutation_turf
	var/do_mutation = 0
	if(prob(overmap_controller.mutation_chance))
		do_mutation = 1
		world << "do mutation near [start_turf.x],[start_turf.y]"*/

	while(working_list.len && num_processed < config.max_turfs)
		//get the next turf and remove it from the list
		var/turf/cur_turf
		if(prob(100 * config.rand_weight / total_weight))
			cur_turf = pick(working_list)
		else
			cur_turf = working_list[1]

		working_list -= cur_turf

		//get all adjacent turfs
		var/list/nearby = orange(1, cur_turf)

		//replace the current turf
		//var/turf/new_turf =
		new spawn_type(cur_turf)
		/*var/cur_dist = get_dist(start_turf, new_turf)
		if(do_mutation)
			world << "	curdist: [cur_dist]"
			if(cur_dist >= overmap_controller.average_morph_diameter * overmap_controller.diameter_percent_trigger)
				mutation_turf = new_turf*/

		//dont overwrite any turfs we have already processed later
		//this shouldnt error if the turfs arent on the list beforehand
		corner_turfs -= nearby

		//chance to spread the asteroid onto nearby mask tiles
		while(nearby.len)
			var/turf/T = pop(nearby)
			//nearby -= T
			if(istype(T, trigger_type) && prob(config.spread_chance))
				working_list.Add(T)

		//dont spread too far
		num_processed++

	/*if(mutation_turf)
		world << "mutation spawned at [mutation_turf.x],[mutation_turf.y]"
		corner_turfs += mutation_turf
		if(mark_type)
			new /obj/effect/spresent(mutation_turf)*/
*/
