
//Space stragglers go here

/obj/effect/overmapobj/temporary_sector
	name = "Deep Space"
	icon_state = ""
	always_known = 0

/obj/effect/overmapobj/temporary_sector/New(var/nx, var/ny, var/nz)
	loc = locate(nx, ny, OVERMAP_ZLEVEL)
	map_z = nz
	map_sectors["[map_z]"] = src
	testing("Temporary sector at [x],[y] was created, corresponding zlevel is [map_z].")

/obj/effect/overmapobj/temporary_sector/Del()
	map_sectors["[map_z]"] = null
	testing("Temporary sector at [x],[y] was deleted.")
	if (can_die())
		testing("Associated zlevel disappeared.")
		world.maxz--

/obj/effect/overmapobj/temporary_sector/proc/can_die(var/mob/observer)
	testing("Checking if sector at [map_z] can die.")
	for(var/mob/M in player_list)
		if(M != observer && M.z == map_z)
			testing("There are people on it.")
			return 0
	return 1


/proc/load_prepared_sector(var/name = input("Sector name: "), var/storname = input("Storage Name: "), var/xpos as num, var/ypos as num)
	if(cached_spacepre["[name]"])
		var/obj/effect/overmapinfo/precreated/data = cached_spacepre["[name]"]
		data.mapx = xpos ? xpos : data.mapx
		data.mapy = ypos ? ypos : data.mapy
		map_sectors["[storname]"] = new data.obj_type(data)
		for(var/obj/machinery/computer/helm/H in machines)
			H.reinit()
		return TRUE
	else
		return FALSE
	return FALSE

/proc/unload_prepared_sector(var/name = input("Sector Name: "), var/storname = input("Storage Name: "))
	if(map_sectors["[storname]"] && cached_spacepre["[name]"])
		var/obj/effect/overmapobj/data = map_sectors["[storname]"]
		qdel(data)
		map_sectors -= storname
		for(var/obj/machinery/computer/helm/H in machines)
			H.reinit()
		return TRUE
	else
		return FALSE
	return FALSE
