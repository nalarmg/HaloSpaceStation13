/*
UNSC Insurrection roundtype
*/

datum/objective/insurrection_nuke
	explanation_text = "Destroy the UNSC ship with a nuclear device."

datum/objective/insurrection_capture
	explanation_text = "Capture the UNSC ship by killing the crew."

/datum/game_mode/insurrection
	name = "Insurrection"
	config_tag = "insurrection"
	required_players = 0
	required_enemies = 0
	round_description = "A UNSC ship has been dispatched to eliminate a secret Insurrection base. The insurrectionists are far from defenceless however..."
	antag_tags = list(MODE_INNIE, MODE_INNIE_TRAITOR)

	var/list/innie_base_paths = list('maps/innie_base1.dmm','maps/innie_base2.dmm')		//make sure these are in the order from top level -> bottom level
	var/innie_base_discovered = 0
	var/obj/effect/overmapobj/innie_base
	var/nuke_result = -1

/*
//delete all nuke disks not on a station zlevel
/datum/game_mode/insurrection/proc/check_nuke_disks()
	for(var/obj/item/weapon/disk/nuclear/N in nuke_disks)
		if(isNotStationLevel(N.z)) qdel(N)

//checks if L has a nuke disk on their person
/datum/game_mode/insurrection/proc/check_mob(mob/living/L)
	for(var/obj/item/weapon/disk/nuclear/N in nuke_disks)
		if(N.storage_depth(L) >= 0)
			return 1
	return 0
*/

/datum/game_mode/insurrection/pre_setup()
	//load Insurrection base zlevel
	for(var/level_path in innie_base_paths)

		var/obj/effect/overmapobj/loaded_obj = overmap_controller.load_premade_map(level_path, innie_base)
		if(innie_base)
			innie_base.linked_zlevelinfos.Add(loaded_obj.linked_zlevelinfos)
			qdel(loaded_obj)
		else
			innie_base = loaded_obj

	if(innie_base)
		innie_base.name = "Insurrection Asteroid Base"
		innie_base.tag = "Insurrection Asteroid Base"
		innie_base.icon = 'sector_icons.dmi'
		innie_base.icon_state = "listening_post"
		overmap_controller.antagonist_home = innie_base

		//link all the levels together
		for(var/obj/effect/zlevelinfo/data in innie_base.linked_zlevelinfos)
			data.name = innie_base.tag

		//grab a rantom antag datum and reload the antagonist spawn locations
		//this is a really odd way of doing things
		var/datum/antagonist/antagonist = antag_templates[1]
		antagonist.get_starting_locations()

	return ..()

/*
/datum/game_mode/insurrection/can_start()
	//fail and return to lobby
	if(!innie_base)
		world << "<span class='danger'>[innie_base_paths[1]] not loaded</span>"

	return ..()
	*/

/datum/game_mode/insurrection/handle_nuke_explosion()
	//todo: rework this proc
	//0: station hit
	//1: nuke near station
	//2: nuke missed
	//lets say option 1 for innie base blown up, option 2 for UNSC ship blown up
	nuke_result = 2
	if(nuked_zlevel)
		if(overmap_controller.protagonist_home && nuked_zlevel in overmap_controller.protagonist_home.linked_zlevelinfos)
			nuke_result = 0
		else if(innie_base && nuked_zlevel in innie_base.linked_zlevelinfos)
			nuke_result = 1

	ticker.station_explosion_cinematic(nuke_result,null)
	return 1

/datum/game_mode/insurrection/declare_completion()
	if(config.objectives_disabled)
		return
	/*
	var/disk_rescued = 1
	for(var/obj/item/weapon/disk/nuclear/D in world)
		var/disk_area = get_area(D)
		if(!is_type_in_list(disk_area, centcom_areas))
			disk_rescued = 0
			break
	var/crew_evacuated = (emergency_shuttle.returned())
	*/

	var/innie_score = 0
	var/unsc_score = 0
	var/list/result_text = list()

	switch(nuke_result)
		if(0)
			//UNSC ship destroyed
			innie_score += 2
			result_text.Add("<span class='info'>- Insurrection operatives have destroyed the UNSC ship.</span>")
			/*for(var/datum/objective/insurrection_nuke/O in global_objectives)
				O.completed = 1*/
		if(1)
			//innie base destroyed
			unsc_score += 2
			result_text.Add("<span class='info'>- The UNSC have destroyed the Insurrection base.</span>")

	if(antags_are_dead)
		unsc_score += 1
		innie_score -= 1
		result_text.Add("<span class='info'>- The insurrectionists are all dead.</span>")

	if(protags_are_dead)
		innie_score += 1
		unsc_score -= 1
		result_text.Add("<span class='info'>- The UNSC crew are all dead.</span>")
		/*for(var/datum/objective/insurrection_capture/O in global_objectives)
			O.completed = 1*/

	//todo: score bonus if it was a short round

	//work out who won
	var/win_faction = ""
	var/win_type = ""
	var/winning_score = 0

	if(unsc_score > innie_score)
		winning_score = unsc_score
		win_faction = "UNSC "
	else if(innie_score > unsc_score)
		winning_score = innie_score
		win_faction = "Insurrection "
	else
		win_type = "Draw!"

	if(winning_score >= 4)
		win_type = "Supreme Victory!"
	if(winning_score >= 3)
		win_type = "Major Victory!"
	if(winning_score >= 2)
		win_type = "Moderate Victory!"
	else
		win_type = "Minor Victory!"

	feedback_set_details("round_end_result","[win_faction][win_type] - score: [winning_score]")
	world << "<span class='h1'>[win_faction][win_type]</span>"
	for(var/entry in result_text)
		world << entry

	..()
	return
