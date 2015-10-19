
datum/controller/process/overmap/proc/load_precreated(var/mapname)
	if(!mapname)
		return null

	//get random coords
	var/sector_x = rand(OVERMAP_EDGE, world.maxx - OVERMAP_EDGE)
	var/sector_y = rand(OVERMAP_EDGE, world.maxy - OVERMAP_EDGE)

	var/obj/effect/overmapobj/loaded_sector

	if(!cached_space.len)
		//if not enough empty zlevels are loaded, create a new one
		world.maxz++
		admin_notice("<span class='danger'>Adding new zlevel for map [mapname]...</span>", R_DEBUG)
		loaded_sector = new /obj/effect/overmapobj/temporary_sector(sector_x, sector_y, world.maxz)
	else
		//otherwise just grab an unused one
		admin_notice("<span class='danger'>Using cached zlevel for map [mapname]...</span>", R_DEBUG)
		loaded_sector = cached_space[cached_space.len]
		cached_space -= loaded_sector
		loaded_sector.x = sector_x
		loaded_sector.y = sector_y

	var/mapfile = file(mapname)
	if(isfile(mapfile))
		world << "<span class='danger'>Loading map [mapname] at overmap coords [sector_x],[sector_y]</span>"
		maploader.load_map(mapfile, loaded_sector.map_z)
		return loaded_sector
	else
		world << "<span class='alert'>Error: [mapname] is not a valid map file.</span>"

	return null
