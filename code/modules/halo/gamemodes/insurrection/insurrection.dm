/datum/game_mode/insurrection
	name = "Insurrection"
	round_description = "There is an Insurrection going on, All UNSC members must fight against the insurrection."
	config_tag = "insurrection"
	required_players = 0

	var/nuke_off_station = 0 //Used for tracking if the syndies actually haul the nuke to the station
	var/innies_didnt_escape = 0 //Used for tracking if the syndies got the shuttle off of the z-level

//map stuff

