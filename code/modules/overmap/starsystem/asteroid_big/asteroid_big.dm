
/obj/effect/overmapobj/bigasteroid
	name = "large asteroid"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "large"
	opacity = 1
	var/datum/asteroidfield/owner
	var/obj/effect/zlevelinfo/bigasteroid/myzlevel
	sensor_icon_state = "asteroids_mine"

/obj/effect/overmapobj/bigasteroid/New()
	if(prob(50))
		icon_state = "small"
	desc = pick("It must be almost a kilometre across!",\
	"This asteroid is huge, dwarfing the others around it.",\
	"It's an enormous asteroid, easily the same size as a warship.")

	overmap_init()

/obj/effect/overmapobj/bigasteroid/proc/get_zlevel()
	//see if our zlevel has finished generating
	if(myzlevel && myzlevel.gen_stage == BIGASTEROID_CAVES_FINISH)
		//bigasteroid.myzlevel = null
		linked_zlevelinfos.Add(myzlevel)
		testing("	Space travel destination is newly finished asteroid")
		return linked_zlevelinfos[1]

	else
		//see if we can get one that's finished loading and assign it
		var/obj/effect/zlevelinfo/bigasteroid/newzlevel = overmap_controller.get_finished_asteroid_zlevel()
		if(newzlevel)
			//replace the old one with this newer finished one
			if(myzlevel)
				overmap_controller.asteroid_zlevels_loading_unassigned.Add(myzlevel)
			myzlevel = newzlevel
			linked_zlevelinfos.Add(newzlevel)
			testing("	Space travel destination is new pregen asteroid")
			return myzlevel
		else
			//see if this asteroid has even been assigned a zlevel first
			if(!myzlevel)
				//ok lets take whatever zlevel is available... might be a finished one, might be one still generating, might be a new blank zlevel
				myzlevel = overmap_controller.get_or_create_asteroid_zlevel()

				//warning, nothing setup yet to handle in case a new ordinary temp zlevel got assigned
				//

			//prioritise this one for loading
			overmap_controller.asteroid_zlevel_loading = myzlevel

			testing("	Asteroid ([src.x],[src.y]) still loading, prioritising...")

			//todo: at some point block the player from space travelling here or force them into a temp sector
			//doing this means that players are able to actually space travel to an asteroid while it is still generating and see it in progress
			//this is obviously breaking the 4th wall... commenting this line out should handily disable it
			return myzlevel

/obj/effect/zlevelinfo/bigasteroid
	name = "random asteroid level"
	var/list/morphturfs = list()
	var/list/morphmarkers = list()
	//
	var/datum/asteroid_gen_config/config

	//generation
	var/gen_x = 1
	var/gen_y = 1
	var/turf/current_turf
	var/gen_stage = BIGASTEROID_STOP
	var/generating = 1

	//generated bounds
	var/max_gen_x = 1
	var/min_gen_x = 255
	var/max_gen_y = 1
	var/min_gen_y = 255

	//masking
	var/turf/centre_turf
	var/list/corner_turfs = list()
	var/corner_dist = 1
	var/rsq = 1
	//var/list/mask_turfs = list()
	var/list/map_turfs = list()
	var/list/map_turfs_next = list()

	//morphing
	var/repeats_left = 0
	var/last_dir = ""
	var/trigger_type
	var/spawn_type
	var/turf/morph_turf
	var/list/morphing_turfs = list()
	var/num_processed = 0
	var/num_this_morph = 1

	//smoothing
	var/num_smoothes = 0

	var/list/mineral_spawn_list = list()

/obj/effect/zlevelinfo/bigasteroid/proc/update_overlays()
	//set src in view(7)

	var/starttime = world.time
	log_admin("update_overlays()...")
	for(var/turf/simulated/mineral/M in world)
		M.updateMineralOverlays()
	for(var/turf/simulated/floor/asteroid/M in world)
		M.updateMineralOverlays()
	log_admin("	Done update_overlays() ([(world.time - starttime) / 10]s).")



//some map helper stuff to speed up generation

/obj/effect/morphmarker
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	var/indexnum = 0
	var/obj/effect/zlevelinfo/bigasteroid/asteroid_zlevel
	invisibility = 101		//until i figure out a way to easily clear them afterwards

/obj/effect/morphmarker/initialize()
	..()
	//indexnum = text2num(src.name)
	//name = "morphmarker"
	//tag = "[z]_[name]"
	asteroid_zlevel = locate("zlevel[z]")
	if(asteroid_zlevel && istype(asteroid_zlevel))
		asteroid_zlevel.morphmarkers.Add(src)
		//world << "indexnum:[indexnum]"
		//insert at the correct location
		var/success = 0
		if(asteroid_zlevel.morphturfs.len)
			//only do first 15 for testing
			/*if(asteroid_zlevel.morphmarkers.len >= 15)
				return*/

			for(var/curindex = 1, curindex <= asteroid_zlevel.morphturfs.len, curindex++)
				var/turf/unsimulated/mask/curmask = asteroid_zlevel.morphturfs[curindex]
				//world << "	curindex:[curindex]: curmask:[curmask] [curmask.type]"
				if(curmask && istype(curmask))
					var/obj/effect/morphmarker/marker = asteroid_zlevel.morphturfs[curmask]
					//world << "		marker:[marker] [marker.type]"
					if(marker && marker.indexnum > src.indexnum)
						asteroid_zlevel.morphturfs.Insert(curindex, src.loc)
						asteroid_zlevel.morphturfs[src.loc] = src
						success = 1
						//world << "			success"
						break

		if(!success)
			asteroid_zlevel.morphturfs[src.loc] = src

	//qdel(src)

var/global/asteroid_masks = list()

/turf/unsimulated/mask/New()
	var/list/zlevel_asteroid_masks = asteroid_masks["[src.z]"]
	if(!zlevel_asteroid_masks)
		zlevel_asteroid_masks = list()
		asteroid_masks["[src.z]"] = zlevel_asteroid_masks
	zlevel_asteroid_masks.Add(src)
