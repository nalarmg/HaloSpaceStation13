
//some generation config settings (todo: move these to the config controller or something? idk)
/datum/big_asteroid_generation_settings
	var/spread_chance = 75
	var/max_turfs = 1000
	//var/mark_points_of_interest = 1
	//
	/*var/average_morph_diameter = 1		//recalculated each step
	var/diameter_percent_trigger = 0.3
	var/mutation_chance = 15*/
	//
	var/pop_weight = 0
	var/rand_weight = 1
	//
	var/expand_weight = 2
	var/contract_weight = 1
	var/skip_weight = 1
	//
	var/repeats_lower = 2
	var/repeats_upper = 4
	//
	var/skips_lower = 1
	var/skips_upper = 2
	//
	var/target_radius = 80
	//
	var/smoothing_passes = 1
	var/asteroid_steps_per_process = 3000

/*
/turf/space/verb/call_asteroid_process()
	set src in view(7)
	set background = 1

	for(var/obj/effect/overmapobj/bigasteroid/bigasteroid in world)
		var/starttime = world.time
		world << "processing asteroidfield at: ([bigasteroid.x],[bigasteroid.x],[bigasteroid.myzlevel.z]) with stage: [bigasteroid.gen_stage]"
		spawn(0)
			var/steps_this_process = 0
			while(steps_this_process < overmap_controller.big_asteroid_generation_settings.asteroid_steps_per_process && bigasteroid.step_generation())
				steps_this_process++
			world << "	done [(world.time - starttime)/10]s final stage: [bigasteroid.gen_stage]"
*/
/*
/turf/space/verb/call_asteroid_cavemapdraw()
	set src in view(7)
	set background = 1

	for(var/obj/effect/overmapobj/bigasteroid/bigasteroid in world)
		bigasteroid.cave_ore_map.display_map()
*/