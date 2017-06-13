
/mob/living/simple_animal/hostile
	var/turf/assault_target
	var/target_margin = 0
	var/feral = 0

/mob/living/simple_animal/hostile/flood
	attack_sfx = list(\
		'sound/effects/attackblob.ogg',\
		'sound/effects/blobattack.ogg'\
		)

/mob/living/simple_animal/hostile/proc/set_assault_target(var/turf/T)
	assault_target = T
	if(assault_target)
		target_margin = rand(12,2)

/mob/living/simple_animal/hostile/flood/New()
	..()
	if(prob(75))
		idle_wander = 1
		stop_automated_movement = 0

/mob/living/simple_animal/hostile/flood/death(gibbed, deathmessage = "dies!")
	. = ..()
	walk(src, 0)

/mob/living/simple_animal/hostile/flood/Life()
	..()

	if(assault_target && stance == HOSTILE_STANCE_IDLE)
		spawn(rand(-1,20))
			dir = get_dir(src, assault_target)
			Move(get_step_towards(src,assault_target))

		if(get_dist(assault_target, src) < target_margin)
			set_assault_target(0)
			if(prob(75))
				idle_wander = 0
				stop_automated_movement = 1

/mob/living/simple_animal/hostile/flood/infestor
	name = "Flood infestor"
	icon = 'code/modules/halo/flood/flood_infection.dmi'
	icon_state = "static"
	icon_living = "static"
	icon_dead = "dead"
	//
	move_to_delay = 30
	health = 1
	maxHealth = 1
	melee_damage_lower = 1
	melee_damage_upper = 5
	attacktext = "leapt at"
	jitter_move = 1
	/*mob_bump_flag = 0
	mob_swap_flags = 0
	mob_push_flags = 0*/

/mob/living/simple_animal/hostile/flood/infestor/New()
	..()
	pixel_x = rand(-8,8)
	pixel_y = rand(-8,8)

/mob/living/simple_animal/hostile/flood/infestor/death(gibbed, deathmessage = "bursts!")
	. = ..()
	//killing a spore can kill others nearby
	for(var/mob/living/simple_animal/hostile/flood/infestor/S in view(1,src))
		if(prob(33))
			S.health = 0

/mob/living/simple_animal/hostile/flood/infestor/Bump(atom/movable/AM, yes)
	if(isliving(AM))
		return
	else
		return ..()

/mob/living/simple_animal/hostile/flood/carrier
	name = "Flood carrier"
	icon = 'code/modules/halo/flood/flood_carrier.dmi'
	icon_state = "static"
	icon_living = "static"
	icon_dead = ""
	//
	move_to_delay = 30
	health = 10
	maxHealth = 10
	melee_damage_lower = 5
	melee_damage_upper = 15

/mob/living/simple_animal/hostile/flood/carrier/AttackingTarget()
	if(!Adjacent(target_mob))
		return

	health = 0

/mob/living/simple_animal/hostile/flood/carrier/death(gibbed, deathmessage = "bursts!")
	src.visible_message("<span class='danger'>[src] bursts, propelling flood spores in all directions!</span>")
	playsound(src.loc, 'sound/weapons/heavysmash.ogg', 50, 0, 0)
	icon_state = "burst"

	var/turf/spawn_turf = src.loc
	spawn(0)
		var/sporesleft = rand(3,9)
		while(sporesleft > 0)
			var/mob/living/simple_animal/hostile/flood/infestor/S = new(spawn_turf)
			sporesleft -= 1
			walk_towards(S, pick(range(7, spawn_turf)), 0, 1)
			spawn(30)
				if(S)
					walk(S, 0)

	spawn(3)
		qdel(src)
	return ..(0,deathmessage)

/mob/living/simple_animal/hostile/flood/combat_human
	name = "Flood infested human"
	icon = 'code/modules/halo/flood/flood_combat_human.dmi'
	icon_state = "marine_infested"
	icon_living = "marine_infested"
	icon_dead = "marine_dead"
	//
	move_to_delay = 2
	health = 40
	maxHealth = 40
	melee_damage_lower = 25
	melee_damage_upper = 35
	attacktext = "bashed"
