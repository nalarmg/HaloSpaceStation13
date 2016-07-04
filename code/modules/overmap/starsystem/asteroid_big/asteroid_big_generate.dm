
/obj/effect/overmapobj/bigasteroid/proc/begin_generation()
	centre_turf = locate(127, 127, myzlevel.z)
	gen_stage = BIGASTEROID_MASKING

	config = overmap_controller.big_asteroid_generation_settings

	//lets start in a little bit as a shortcut
	gen_x = max(127 - config.target_radius - 5, 1)
	gen_y = max(127 - config.target_radius - 5, 1)
	corner_dist = config.target_radius * config.target_radius
	rsq = config.target_radius * (config.target_radius + 0.5)

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
#define BIGASTEROID_CAVES_SEED 5
#define BIGASTEROID_CAVES_ITER 6
#define BIGASTEROID_CAVES_ORE 7
#define BIGASTEROID_CAVES_APPLY 8
*/

/obj/effect/overmapobj/bigasteroid/proc/step_generation()
	. = 1
	switch(gen_stage)
		if(BIGASTEROID_STOP)
			. = 0

		if(BIGASTEROID_MASKING)
			. = 2
			if(!step_masking())
				gen_stage = BIGASTEROID_PICKMORPH

		if(BIGASTEROID_PICKMORPH)
			//pick_new_morph is very quick so lets just call the step again after
			if(pick_new_morph())
				gen_stage = BIGASTEROID_MORPHING
				. = step_morphing()
			else
				gen_stage = BIGASTEROID_SMOOTHING
				. = step_generation()

		if(BIGASTEROID_MORPHING)
			. = 4
			if(!step_morphing())
				gen_stage = BIGASTEROID_PICKMORPH

		if(BIGASTEROID_SMOOTHING)
			//this one is fairly quick in total, but we'll step it out anyway
			if(!step_smoothing())
				num_smoothes += 1
				if(num_smoothes >= config.smoothing_passes)
					gen_stage = BIGASTEROID_CAVES_SEED

		if(BIGASTEROID_CAVES_SEED)
			if(!step_seed(1))
				gen_stage = BIGASTEROID_CAVES_ITER

		if(BIGASTEROID_CAVES_ITER)
			if(!step_iterate(1))
				gen_stage = BIGASTEROID_CAVES_ORE

		if(BIGASTEROID_CAVES_ORE)
			if(!step_ore(1))
				gen_stage = BIGASTEROID_CAVES_APPLY

		if(BIGASTEROID_CAVES_APPLY)
			if(!step_apply(1))

				//final step
				gen_stage = BIGASTEROID_STOP
				message_admins("Finished generating asteroid at ([src.x],[src.y],[src.myzlevel.z])")
				. = 0
