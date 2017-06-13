
/datum/game_mode/stranded
	name = "Stranded"
	config_tag = "Stranded"
	required_players = 0
	required_enemies = 0
	end_on_antag_death = 0
	end_on_protag_death = 0
	round_description = "UNSC personnel are stranded on a distant alien world. Now hordes of horrific parasitic aliens are attacking and there is only limited time to setup defences. Can you survive until the rescue team arrives?"
	hub_descriptions = list("marooned on a distant alien world","cut off struggling to survive on the fringe of known space","stranded on an alien hellhole waiting for evacuation")

	var/wave_num = 0
	var/area/planet/daynight/planet_area
	var/list/flood_spawn_turfs = list()
	var/list/flood_assault_turfs = list()

	var/is_spawning = 0	//0 = rest, 1 = spawning
	var/spawns_per_tick_base = 1
	var/spawns_per_tick_current = 1
	var/bonus_spawns = 0
	var/spawn_wave_multi = 1.1
	var/wave_dur_multi = 1//1.25
	var/rest_dur_multi = 1//0.9
	var/spawn_feral_chance = 0.1
	var/time_next_spawn_tick = 0
	var/spawn_interval = 30
	var/is_daytime = 1
	var/duskdawn_threshold = 0.65

	//deciseconds
	var/duration_wave_base = 3000
	var/duration_wave_current = 3000
	var/duration_rest_base = 6000
	var/duration_rest_current = 6000
	var/duration_day = 12000
	var/duration_night = 12000
	//
	var/time_wave_cycle = 9999
	var/daynight_start = 0
	var/daynight_end = 0
	var/time_pelican_arrive = 9999

	var/worldtime_offset = 0

/datum/game_mode/stranded/pre_setup()
	for(var/obj/effect/landmark/flood_spawn/F in world)
		flood_spawn_turfs.Add(get_turf(F))

	for(var/obj/effect/landmark/flood_assault_target/F in world)
		flood_assault_turfs.Add(get_turf(F))

	planet_area = locate() in world
	set_ambient_light(1,1,1)
	return ..()

/datum/game_mode/stranded/post_setup()
	time_pelican_arrive = world.time + 24000 + 24000 * rand()
	daynight_start = world.time
	daynight_end = world.time + duration_day
	time_wave_cycle = world.time + duration_rest_base

/datum/game_mode/stranded/process()
	//day night processing
	var/daynight_progress = (worldtime_offset + world.time - daynight_start) / duration_day
	daynight_progress = max(daynight_progress, 0)
	daynight_progress = min(daynight_progress, 1)
	//world << "daynight progress: [daynight_progress]"
	if(daynight_progress > duskdawn_threshold)
		if(is_daytime)
			if(daynight_progress == 1)
				daynight_start = world.time
				daynight_end = world.time + duration_night
				//
				is_daytime = 0
				world << "<span class='danger'>It is now [is_daytime ? "daytime" : "nighttime"]!</span>"
			spawn(0)
				var/ambient_light_level = 1 - (daynight_progress - duskdawn_threshold) / (1 - duskdawn_threshold)
				//world << "	ambient_light_level: [ambient_light_level]"
				set_ambient_light(ambient_light_level, ambient_light_level, ambient_light_level)
		else
			if(daynight_progress == 1)
				daynight_start = world.time
				daynight_end = world.time + duration_day
				//
				is_daytime = 1
				world << "<span class='danger'>It is now [is_daytime ? "daytime" : "nighttime"]!</span>"
			spawn(0)
				var/ambient_light_level = (daynight_progress - duskdawn_threshold) / (1 - duskdawn_threshold)
				//world << "	ambient_light_level: [ambient_light_level]"
				set_ambient_light(ambient_light_level, ambient_light_level, ambient_light_level)

	if(is_spawning)
		//wave is currently ongoing
		if(world.time > time_wave_cycle)
			//end the wave and start the rest period
			is_spawning = 0
			time_wave_cycle = world.time + duration_rest_current
			duration_rest_current *= rest_dur_multi
			world << "<span class='danger'>Flood spawns have stopped! Rest and recuperate before the next wave...</span>"

		if(world.time > time_next_spawn_tick)
			time_next_spawn_tick = world.time + spawn_interval
			spawn(0)
				spawn_attackers_tick(spawns_per_tick_current)
	else
		//rest period is currently ongoing
		if(world.time > time_wave_cycle)
			//end the rest period and start the wave
			is_spawning = 1
			time_wave_cycle = world.time + duration_wave_current
			duration_wave_current *= wave_dur_multi
			world << "<span class='danger'>Flood spawns have started! Get back to your base and dig in...</span>"
			//
			wave_num++
			spawns_per_tick_current = wave_num * spawn_wave_multi
			spawn_feral_chance = wave_num * 0.2

	if(world.time > time_pelican_arrive)
		//force an immediate wave to spawn
		wave_num++
		spawns_per_tick_current = wave_num * spawn_wave_multi
		spawn_feral_chance = wave_num * 0.2
		time_wave_cycle = world.time + 3000
		time_pelican_arrive += 9999999		//round is about to end anyway so meh
		is_spawning = 1
		world << "<span class='danger'>The evacuation pelican has arrived!</span>"

/datum/game_mode/stranded/proc/spawn_attackers_tick(var/amount = 1)
	set background = 1
	bonus_spawns += bonus_spawns
	while(amount > 0)
		if(amount < 1)
			spawn_attackers(, 1)
			amount = 0
		else
			var/number_to_spawn
			var/spawn_type
			if(prob(33))
				number_to_spawn = 1
				spawn_type = /mob/living/simple_animal/hostile/flood/combat_human
			else if(prob(50))
				number_to_spawn = 2
				spawn_type = /mob/living/simple_animal/hostile/flood/carrier
			else
				number_to_spawn = rand(4,6)
				spawn_type = /mob/living/simple_animal/hostile/flood/infestor
			spawn_attackers(spawn_type, number_to_spawn)
			amount -= 1
	bonus_spawns = max(amount, 0)

/datum/game_mode/stranded/proc/spawn_attackers(var/spawntype, var/amount)
	//world << "spawn_attackers([type],[amount])"
	if(flood_spawn_turfs.len)
		for(var/i = 0, i < amount, i++)
			//world << "	check3"
			var/turf/spawn_turf = pick(flood_spawn_turfs)
			var/mob/living/simple_animal/hostile/flood/F = new spawntype(spawn_turf)
			if(flood_assault_turfs.len)
				F.set_assault_target(pick(flood_assault_turfs))
				//world << "	check4"
			else
				log_admin("Error: gamemode unable to find any /obj/effect/landmark/flood_assault_target/")
	else
		log_admin("Error: gamemode unable to find any /obj/effect/landmark/flood_spawn/")

/datum/game_mode/stranded/get_mode_time()
	if(is_daytime)
		return time2text(daynight_start)
	return time2text(daynight_start + duration_day)
/*
	if(!roundstart_hour) roundstart_hour = pick(2,7,12,17)
	return timeshift ? time2text(time+(36000*roundstart_hour), "hh:mm") : time2text(time, "hh:mm")
	*/
	return
	/*
	var/duration_day = 12000
	var/duration_night = 12000
	var/daynight_start = 0
	var/daynight_end = 0
	var/is_daytime
	*/
