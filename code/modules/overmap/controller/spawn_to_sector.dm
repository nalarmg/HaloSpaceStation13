
//note: source_obj is optional and the code will handle fine without it, but the destination and spawn location (or spawn edge) will be randomised
/datum/controller/process/overmap/proc/spawn_to_sector(var/turf/overmap_turf, var/atom/movable/A, var/obj/effect/overmapobj/source_obj, var/skip_recycle = 0)
	//world << "spawn_to_sector([overmap_turf], [A], [source_obj])"

	//first check if we can "lose" the object in deepspace and not have to do all this processing
	if(!skip_recycle && overmap_controller.attempt_recycle_deepspace_atom(A))
		return 2

	//attempt to locate a pre-existing object to spawn to (avoiding the source)
	var/obj/effect/overmapobj/spawn_obj = get_destination_object(overmap_turf)

	//calculate the x and y coordinates to spawn in on
	//TRANSITIONEDGE is defined at 7 whereas 1 pixel on the overmap represents 7.9 turfs so this shouldn't result in a jolt on the overmap
	var/spawnx = 0
	var/spawny = 0
	if(source_obj)
		//reverse engineer sector coordinates from the pixel offset of the source object
		spawnx = world.maxx * ((16 + source_obj.pixel_x) / 32)
		spawny = world.maxy * ((16 + source_obj.pixel_y) / 32)

		//make sure values are valid
		spawnx = Clamp(spawnx, TRANSITIONEDGE, world.maxx - TRANSITIONEDGE)
		spawny = Clamp(spawny, TRANSITIONEDGE, world.maxy - TRANSITIONEDGE)
	else
		//pick random coordinates
		spawnx = rand(TRANSITIONEDGE, world.maxx - TRANSITIONEDGE)
		spawny = rand(TRANSITIONEDGE, world.maxy - TRANSITIONEDGE)

	//grab the actual spawnsector and direction to start drifting in
	var/throwdir = 0
	var/obj/effect/zlevelinfo/target_zlevel
	if(spawn_obj && spawn_obj.linked_zlevelinfos.len)
		//pick a random zlevel to come into
		target_zlevel = pick(spawn_obj.linked_zlevelinfos)

		//spawn on the closest edge
		//there might be a more concise way to do this (one that avoids repetition) but at least this should run fairly fast
		if(spawnx < world.maxx / 2)
			//left half of the map
			if(spawny < world.maxy / 2)
				//bottom left quadrant
				if(spawnx < spawny)
					//left edge
					spawnx = TRANSITIONEDGE + 1
					//spawnturf = locate(TRANSITIONEDGE + 1, spawny, deep_space_sector.map_z)
					throwdir = EAST
				else
					//bottom edge
					spawny = TRANSITIONEDGE + 1
					//spawnturf = locate(spawnx, TRANSITIONEDGE + 1, deep_space_sector.map_z)
					throwdir = NORTH
			else
				//top left quadrant
				if(spawnx < world.maxy - spawny)
					//left edge
					spawnx = TRANSITIONEDGE + 1
					//spawnturf = locate(TRANSITIONEDGE + 1, spawny, deep_space_sector.map_z)
					throwdir = EAST
				else
					//top edge
					spawny = world.maxy - TRANSITIONEDGE - 1
					//spawnturf = locate(spawnx, world.maxy - TRANSITIONEDGE - 1, deep_space_sector.map_z)
					throwdir = SOUTH
		else
			//right half of the map
			if(spawny < world.maxy / 2)
				//bottom right quadrant
				if(world.maxx - spawnx < spawny)
					//right edge
					spawnx = world.maxx - TRANSITIONEDGE - 1
					//spawnturf = locate(world.maxx - TRANSITIONEDGE - 1, spawny, deep_space_sector.map_z)
					throwdir = WEST
				else
					//bottom edge
					spawny = TRANSITIONEDGE + 1
					//spawnturf = locate(spawnx, TRANSITIONEDGE + 1, deep_space_sector.map_z)
					throwdir = NORTH
			else
				//top right quadrant
				if(world.maxx - spawnx < world.maxy - spawny)
					//right edge
					spawnx = world.maxx - TRANSITIONEDGE - 1
					//spawnturf = locate(world.maxx - TRANSITIONEDGE - 1, spawny, deep_space_sector.map_z)
					throwdir = WEST
				else
					//top edge
					spawny = world.maxy - TRANSITIONEDGE - 1
					//spawnturf = locate(spawnx, world.maxy - TRANSITIONEDGE - 1, deep_space_sector.map_z)
					throwdir = SOUTH
	else
		//otherwise we're going to spawn to a temporary deepspace sector
		target_zlevel = get_or_create_cached_zlevel()
		target_zlevel.name = "Temporary space sector"

		//create a corresponding deep space sector so we can be found
		testing("	Adding new temporary space sector...")
		spawn_obj = new /obj/effect/overmapobj/temporary_sector(overmap_turf.x, overmap_turf.y, target_zlevel.z)
		spawn_obj.linked_zlevelinfos.Add(target_zlevel)
		map_sectors["[target_zlevel.z]"] = spawn_obj

		//testing("Destination: z[nz] [target_obj]")
		target_zlevel.objects_preventing_recycle.Add(A)

		//throw in the approximate direction we are travelling - this will clamp to 45 degree increments but that's ok because tile based movement
		//todo: it might not handle diagonal dirs nicely, so test this to make sure (restrict to cardinals if not)
		if(source_obj && istype(source_obj, /obj/effect/overmapobj/vehicle))
			var/obj/effect/overmapobj/vehicle/V = source_obj
			throwdir = angle2dir(V.pixel_transform.heading)
		else
			throwdir = pick(cardinal)

	//spawn in at the target location at the sector
	//world << "spawning to sector [spawnx],[spawny],[spawnz]"
	var/turf/spawn_turf = locate(spawnx, spawny, target_zlevel.z)
	A.loc = spawn_turf

	//if we're a mob start floating off in the calculated direction
	//todo: hack in throwcode here so that objs drift as well (most objs should have been already recycled at the start of this proc tho)
	A.last_move = throwdir
	spawn_turf.inertial_drift(A)

	if(istype(A, /obj/machinery/overmap_vehicle))
		var/obj/machinery/overmap_vehicle/V = A
		V.enter_new_zlevel(target_zlevel)

	//inform the unfortunate atom they've been left behind
	if(source_obj)
		A << "\icon[source_obj] <span class='warning'>[source_obj] disappears into the distance. You drift into [spawn_obj].</span>"
	else
		A << "<span class='warning'>You drift into [spawn_obj].</span>"

	return 1
