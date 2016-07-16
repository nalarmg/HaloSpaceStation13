//this proc is a stripped down version of datum/random_map/automata/cave_system
//some code shamelessly copied

/datum/random_asteroid
	var/list/map_turfs
	var/list/map_turfs_next = list()
	var/list/ore_turf_candidates = list()
	var/initial_wall_cell = 55
	var/current_index = 1
	var/current_iteration = 1
	var/total_iterations = 5
	var/ore_count = 0
	var/ore_max = 1

/datum/random_asteroid/proc/seed_steps(var/num_steps = 1)
	. = 1
	var/cur_step = 1
	for(cur_step, cur_step <= num_steps, cur_step++)
		var/turf/cur_turf = map_turfs[current_index++]
		if(prob(initial_wall_cell))
			map_turfs[cur_turf] = "w"
		else
			map_turfs[cur_turf] = "f"

		if(current_index > map_turfs.len)
			current_index = 1
			ore_max = round(map_turfs.len / 20)
			. = 0
			break

/datum/random_asteroid/proc/iterate_steps(var/num_steps = 1)
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
		if(f_count >= 5)
			map_turfs_next[cur_turf] = "f"
		else if(w_count >= 5)
			map_turfs_next[cur_turf] = "w"

			//remember potential ore spawning turfs
			if(current_iteration == total_iterations)
				ore_turf_candidates += cur_turf
		else
			map_turfs_next[cur_turf] = mapval

		//are we finished this iteration?
		if(current_index > map_turfs.len)
			current_index = 1
			current_iteration += 1
			//
			map_turfs = map_turfs_next
			map_turfs_next = list()

		//iterate over multiple times
		if(current_iteration > total_iterations)
			current_iteration = 1
			. = 0
			break

/datum/random_asteroid/proc/ore_steps(var/num_steps)
	. = 1
	var/cur_step = 1
	for(cur_step, cur_step <= num_steps, cur_step++)

		var/turf/chosen_candidate = pick(ore_turf_candidates)
		ore_turf_candidates -= chosen_candidate

		//ordinary or rich mineral turf
		if(prob(75))
			map_turfs[chosen_candidate] = "m"
		else
			map_turfs[chosen_candidate] = "r"

		ore_count++

		if(ore_count >= ore_max)
			. = 0
			break

/datum/random_asteroid/proc/apply_steps(var/num_steps = 1)
	. = 1
	var/cur_step = 1
	for(cur_step, cur_step <= num_steps, cur_step++)
		var/turf/cur_turf = map_turfs[current_index++]
		switch(map_turfs[cur_turf])
			if("w")
				new/turf/simulated/mineral(cur_turf)
			if("f")
				new/turf/simulated/floor/asteroid(cur_turf)
			if("m")
				new/turf/simulated/mineral/random(cur_turf)
			if("r")
				new/turf/simulated/mineral/random/high_chance(cur_turf)

		if(current_index > map_turfs.len)
			current_index = 1
			. = 0
			break

/*
/turf/space/verb/print_map_turfs()
	set src in view(7)

	for(var/obj/effect/overmapobj/bigasteroid/bigasteroid in world)
		var/datum/random_asteroid/random_asteroid = bigasteroid.cave_ore_map
		for(var/turf/cur_turf in random_asteroid.map_turfs)
			world << "([cur_turf.x],[cur_turf.y]) [random_asteroid.map_turfs[cur_turf]]"

/turf/space/verb/print_map_turfs_next()
	set src in view(7)

	for(var/obj/effect/overmapobj/bigasteroid/bigasteroid in world)
		var/datum/random_asteroid/random_asteroid = bigasteroid.cave_ore_map
		for(var/turf/cur_turf in random_asteroid.map_turfs_next)
			world << "([cur_turf.x],[cur_turf.y]) [random_asteroid.map_turfs_next[cur_turf]]"
*/
