
/obj/effect/zlevelinfo/bigasteroid/proc/begin_generation(var/masks_also = 0)
	centre_turf = locate(127, 127, src.z)
	if(masks_also)
		gen_stage = BIGASTEROID_MASKING
	else
		gen_stage = BIGASTEROID_PICKMORPH//BIGASTEROID_CAVES_SEED

	corner_turfs = morphturfs
	/*for(var/obj/effect/morphmarker/marker in myzlevel.morphmarkers)
		qdel(marker)*/

	map_turfs = asteroid_masks["[src.z]"]

	config = overmap_controller.asteroid_gen_config

	//lets start in a little bit as a shortcut
	gen_x = max(127 - config.target_radius - 5, 1)
	gen_y = max(127 - config.target_radius - 5, 1)
	corner_dist = config.target_radius * config.target_radius
	rsq = config.target_radius * (config.target_radius + 0.5)

	//choose which minerals will spawn

	//abundant ores
	var/num_ores = Ceiling(all_abundant_ores.len/4)
	while(num_ores > 0 && unused_abundant_ores.len > 0)
		//pick one at random
		var/orename = pick(unused_abundant_ores)
		var/ore/ore = unused_abundant_ores[orename]
		mineral_spawn_list[orename] = ore.spawn_weight

		//remove them from the list of candidates
		unused_abundant_ores -= orename
		num_ores -= 1

	//common ores
	num_ores = Ceiling(all_common_ores.len/4)
	while(num_ores > 0 && unused_common_ores.len > 0)
		//pick one at random
		var/orename = pick(unused_common_ores)
		var/ore/ore = unused_common_ores[orename]
		mineral_spawn_list[orename] = ore.spawn_weight

		//remove them from the list of candidates
		unused_common_ores -= orename
		num_ores -= 1

	//rare ores
	num_ores = Ceiling(all_rare_ores.len/4)
	while(num_ores > 0 && unused_rare_ores.len > 0)
		//pick one at random
		var/orename = pick(unused_rare_ores)
		var/ore/ore = unused_rare_ores[orename]
		mineral_spawn_list[orename] = ore.spawn_weight

		//remove them from the list of candidates
		unused_rare_ores -= orename
		num_ores -= 1

	//cave_ore_map = new /datum/random_map/automata/cave_system(null,1,1,myzlevel.z,255,255, 0, 1, 1, "Z[myzlevel.z] asteroid ore caves")
	//cave_ore_map.start_iteration()
	//cave_ore_map = new()
	//cave_ore_map.map_turfs = mask_turfs

/*
#define BIGASTEROID_STOP 0
#define BIGASTEROID_MASKING 1
#define BIGASTEROID_PICKMORPH 2
#define BIGASTEROID_MORPHING 3
#define BIGASTEROID_SMOOTHING 4
#define BIGASTEROID_SMOOTHING_APPLY 5
#define BIGASTEROID_CAVES_SEED 6
#define BIGASTEROID_CAVES_ITER 7
#define BIGASTEROID_CAVES_ORE 8
#define BIGASTEROID_CAVES_APPLY 9
#define BIGASTEROID_CAVES_FINISH 10
*/

/obj/effect/zlevelinfo/bigasteroid/proc/step_generation(var/num_steps = 1)
	set background = 1
	. = 1

	while(num_steps > 0)
		num_steps -= 1

		switch(gen_stage)
			if(BIGASTEROID_STOP)
				. = 0

			if(BIGASTEROID_CAVES_FINISH)
				. = 0

			if(BIGASTEROID_MASKING)
				//this step is unneeded when we have a premade maskmap
				//. = 2
				if(!step_masking())
					arrange_morph_markers()
					gen_stage = BIGASTEROID_PICKMORPH

			if(BIGASTEROID_PICKMORPH)
				//pick_new_morph is very quick so lets just call the step again after
				if(pick_new_morph())
					gen_stage = BIGASTEROID_MORPHING
					. = step_generation()
				else
					gen_stage = BIGASTEROID_SMOOTHING
					. = step_generation()

			if(BIGASTEROID_MORPHING)
				//. = 3
				if(!step_morphing())
					gen_stage = BIGASTEROID_PICKMORPH

			if(BIGASTEROID_SMOOTHING)
				//loop over our random asteroid smoothing out the edges to make it look more natural
				if(!step_smoothing())
					if(num_smoothes >= config.smoothing_passes)
						gen_stage = BIGASTEROID_SMOOTHING_APPLY

			if(BIGASTEROID_SMOOTHING_APPLY)
				//this one is fairly quick in total, but we'll step it out anyway
				if(!step_smoothing_apply())
					gen_stage = BIGASTEROID_CAVES_SEED

			if(BIGASTEROID_CAVES_SEED)
				if(!step_seed(10))
					gen_stage = BIGASTEROID_CAVES_ITER

			if(BIGASTEROID_CAVES_ITER)
				if(!step_iterate(5))
					ore_max = round(map_turfs.len / 100)
					gen_stage = BIGASTEROID_CAVES_APPLY

			if(BIGASTEROID_CAVES_APPLY)
				if(!step_apply(1))
					gen_stage = BIGASTEROID_CAVES_ORE

			if(BIGASTEROID_CAVES_ORE)
				if(!step_ore(1))

					//final step
					gen_stage = BIGASTEROID_CAVES_FINISH
					message_admins("Finished generating asteroid at ([src.x],[src.y],[src.z])")
					. = 0

		if(!.)
			break
