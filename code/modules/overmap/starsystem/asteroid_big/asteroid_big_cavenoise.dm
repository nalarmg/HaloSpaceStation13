//this proc is a stripped down version of datum/random_map/automata/cave_system
//some code shamelessly copied

/obj/effect/zlevelinfo/bigasteroid
	var/list/ore_turf_candidates = list()
	var/list/ore_turfs = list()
	var/current_index = 1
	var/current_iteration = 1
	var/ore_max = 0
	var/num_ore = 0

/obj/effect/zlevelinfo/bigasteroid/proc/step_seed(var/num_steps = 1)
	. = 1
	var/cur_step = 1
	for(cur_step, cur_step <= num_steps, cur_step++)
		var/turf/cur_turf = map_turfs[current_index]
		if(prob(config.cave_wall_prob))
			map_turfs[cur_turf] = "w"
		else
			map_turfs[cur_turf] = "f"

		current_index += 1
		if(current_index > map_turfs.len)
			current_index = 1
			. = 0
			break

/obj/effect/zlevelinfo/bigasteroid/proc/step_iterate(var/num_steps = 1)
	. = 1
	var/cur_step = 1
	for(cur_step, cur_step <= num_steps, cur_step++)
		var/turf/cur_turf = map_turfs[current_index++]
		var/mapval = map_turfs[cur_turf]

		var/w_count = 0
		var/f_count = 0
		if(mapval == "w")
			w_count++
		else if(mapval == "f")
			f_count++
		var/turf/tmp_cell

		//find out how many neighbors share our type
		tmp_cell = locate(cur_turf.x+1, cur_turf.y, cur_turf.z)
		if(map_turfs[tmp_cell] == "w")
			w_count++
		else if(map_turfs[tmp_cell] == "f")
			f_count++
		tmp_cell = locate(cur_turf.x, cur_turf.y+1, cur_turf.z)
		if(map_turfs[tmp_cell] == "w")
			w_count++
		else if(map_turfs[tmp_cell] == "f")
			f_count++
		tmp_cell = locate(cur_turf.x+1, cur_turf.y+1, cur_turf.z)
		if(map_turfs[tmp_cell] == "w")
			w_count++
		else if(map_turfs[tmp_cell] == "f")
			f_count++
		tmp_cell = locate(cur_turf.x-1, cur_turf.y, cur_turf.z)
		if(map_turfs[tmp_cell] == "w")
			w_count++
		else if(map_turfs[tmp_cell] == "f")
			f_count++
		tmp_cell = locate(cur_turf.x, cur_turf.y-1, cur_turf.z)
		if(map_turfs[tmp_cell] == "w")
			w_count++
		else if(map_turfs[tmp_cell] == "f")
			f_count++
		tmp_cell = locate(cur_turf.x-1, cur_turf.y-1, cur_turf.z)
		if(map_turfs[tmp_cell] == "w")
			w_count++
		else if(map_turfs[tmp_cell] == "f")
			f_count++
		tmp_cell = locate(cur_turf.x-1, cur_turf.y+1, cur_turf.z)
		if(map_turfs[tmp_cell] == "w")
			w_count++
		else if(map_turfs[tmp_cell] == "f")
			f_count++
		tmp_cell = locate(cur_turf.x+1, cur_turf.y-1, cur_turf.z)
		if(map_turfs[tmp_cell] == "w")
			w_count++
		else if(map_turfs[tmp_cell] == "f")
			f_count++

		//if there's at least 4, stay the same for next iteration otherwise flip
		//world << "	iter [current_iteration]/[total_iterations]"
		if(f_count >= 5)
			map_turfs_next[cur_turf] = "f"
			//world << "check1"
		else if(w_count >= 5 || mapval == "f")
			map_turfs_next[cur_turf] = "w"
			//world << "check2"

			//remember potential ore spawning turfs
			if(current_iteration == config.cave_iterations)
				ore_turf_candidates += cur_turf
				//world << "check2.5"
		else
			map_turfs_next[cur_turf] = mapval
			//world << "check3"

		//are we finished this iteration?
		if(current_index > map_turfs.len)
			current_index = 1
			current_iteration += 1
			//
			map_turfs = map_turfs_next
			map_turfs_next = list()

		//iterate over multiple times
		if(current_iteration > config.cave_iterations)
			current_iteration = 1
			. = 0
			break

/obj/effect/zlevelinfo/bigasteroid/proc/step_apply(var/num_steps = 1)
	. = 1
	var/cur_step = 1
	for(cur_step, cur_step <= num_steps, cur_step++)
		var/turf/cur_turf = map_turfs[current_index++]
		if(map_turfs[cur_turf] == "f")
			new/turf/simulated/floor/asteroid(cur_turf)
		else
			//"w"
			//"m"
			//also just in case any null values slip through
			if(istype(cur_turf, /turf/unsimulated/mask))
				new/turf/simulated/mineral(cur_turf)

		if(current_index > map_turfs.len)
			current_index = 1
			. = 0
			break
