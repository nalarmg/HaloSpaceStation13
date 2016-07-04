
/obj/effect/overmapobj/bigasteroid
	name = "large asteroid"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "large"
	opacity = 1
	var/datum/asteroidfield/owner
	var/obj/effect/zlevelinfo/myzlevel
	//
	var/datum/big_asteroid_generation_settings/config

	//generation
	var/gen_x = 1
	var/gen_y = 1
	var/turf/current_turf
	var/gen_stage = BIGASTEROID_STOP

	//masking
	var/turf/centre_turf
	var/list/corner_turfs = list()
	var/corner_dist = 1
	var/rsq = 1
	var/list/map_turfs = list()
	var/list/map_turfs_next = list()

	//morphing
	var/repeats_left = 0
	var/last_dir = 0
	var/trigger_type
	var/spawn_type
	var/turf/morph_turf
	var/list/morphing_turfs = list()
	var/num_processed = 0
	var/num_smoothes = 0
	var/generating = 1

	sensor_icon_state = "asteroids_mine"

	//caves, ores, oredata etc
	var/datum/random_asteroid/cave_ore_map

/obj/effect/overmapobj/bigasteroid/New()
	if(prob(50))
		icon_state = "small"
	desc = pick("It must be almost a kilometre across!",\
	"This asteroid is huge, dwarfing the others around it.",\
	"It's an enormous asteroid, easily the same size as a warship.")

	overmap_init()

/turf/space/verb/clear_masks()
	set src in view(7)
	set background = 1

	for(var/curx = 1, curx <= world.maxx, curx++)
		for(var/cury = 1, cury <= world.maxy, cury++)
			var/turf/cur_turf = locate(curx, cury, src.z)
			for(var/obj/O in cur_turf)
				qdel(O)
			new /turf/space(cur_turf)

/obj/effect/overmapobj/bigasteroid/proc/update_overlays()
	//set src in view(7)

	var/starttime = world.time
	log_admin("update_overlays()...")
	for(var/turf/simulated/mineral/M in world)
		M.updateMineralOverlays()
	for(var/turf/simulated/floor/asteroid/M in world)
		M.updateMineralOverlays()
	log_admin("	Done update_overlays() ([(world.time - starttime) / 10]s).")
