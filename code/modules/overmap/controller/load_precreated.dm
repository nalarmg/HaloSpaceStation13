
datum/controller/process/overmap/proc/load_precreated(var/mapname)
	if(!mapname)
		return 0

	var/mapfile = file(mapname)
	if(isfile(mapfile))
		admin_notice("<span class='alert'>Loading precreated sector...</span>", R_DEBUG)
		maploader.load_map(mapfile)
		world.log << "<span class='alert'>precreated sector loaded: [mapfile]</span>"
		admin_notice("<span class='alert'>Precreated sector loaded.</span>", R_DEBUG)
	else
		admin_notice("<span class='alert'>Error: [mapname] is not a valid map file.</span>", R_DEBUG)

