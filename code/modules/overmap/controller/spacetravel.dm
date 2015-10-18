
/datum/controller/process/overmap/proc/overmap_spacetravel(var/turf/space/T, var/atom/movable/A)

	//todo: make a complete list of stuff banned from travelling... most stuff can be just deleted (lost to deep space)
	if(istype(A, /obj/effect))
		return

	var/obj/effect/overmapobj/M = map_sectors["[T.z]"]

	if (!M)
		return
	var/mapx = M.x
	var/mapy = M.y
	var/nx = 1
	var/ny = 1
	var/nz = M.map_z

	if(T.x <= TRANSITIONEDGE)
		nx = world.maxx - TRANSITIONEDGE - 2
		ny = rand(TRANSITIONEDGE + 2, world.maxy - TRANSITIONEDGE - 2)
		mapx = max(1, mapx-1)

	else if (A.x >= (world.maxx - TRANSITIONEDGE - 1))
		nx = TRANSITIONEDGE + 2
		ny = rand(TRANSITIONEDGE + 2, world.maxy - TRANSITIONEDGE - 2)
		mapx = min(world.maxx, mapx+1)

	else if (T.y <= TRANSITIONEDGE)
		ny = world.maxy - TRANSITIONEDGE -2
		nx = rand(TRANSITIONEDGE + 2, world.maxx - TRANSITIONEDGE - 2)
		mapy = max(1, mapy-1)

	else if (A.y >= (world.maxy - TRANSITIONEDGE - 1))
		ny = TRANSITIONEDGE + 2
		nx = rand(TRANSITIONEDGE + 2, world.maxx - TRANSITIONEDGE - 2)
		mapy = min(world.maxy, mapy+1)

	testing("[A] moving from [M] ([M.x], [M.y]) to ([mapx],[mapy]).")

	var/turf/map = locate(mapx,mapy,OVERMAP_ZLEVEL)
	var/obj/effect/overmapobj/TM = locate() in map
	if(TM)
		nz = TM.map_z
		testing("Destination: [TM]")
	else
		if(cached_space.len)
			var/obj/effect/overmapobj/temporary_sector/cache = cached_space[cached_space.len]
			cached_space -= cache
			nz = cache.map_z
			cache.x = mapx
			cache.y = mapy
			testing("Destination: *cached* [TM]")
		else
			world.maxz++
			nz = world.maxz
			admin_notice("<span class='danger'>Adding new temporary space sector (zlevel)...</span>", R_DEBUG)
			TM = new /obj/effect/overmapobj/temporary_sector(mapx, mapy, nz)
			testing("Destination: *new* [TM]")

	var/turf/dest = locate(nx,ny,nz)
	if(dest)
		A.loc = dest

	if(istype(M, /obj/effect/overmapobj/temporary_sector))
		var/obj/effect/overmapobj/temporary_sector/source = M
		if (source.can_die())
			testing("Catching [M] for future use")
			source.loc = null
			cached_space += source
