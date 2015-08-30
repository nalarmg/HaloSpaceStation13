
//------------------------------------------------------
// MultiZ 2.0
//------------------------------------------------------

/*
Thanks to Sukasa/Googolplexed for the original code.

When loading sectors, all sectors with matching sector_name will be considered part of the same sector
If the maps for each zlevel are loaded out of order however, they will be inaccessable via normal means (ladders, stairs, travelup/traveldown etc)
Mappers just make sure the maps are next to each other in the map list so they're loaded correctly

Notes: the previous implementation used '11' as down and '12' as up
Remember this in case its important later (byond defines up as 16 and down as 32, i've switched 11 and 12 over to 16 and 32 in most cases)
Disposal pipes state value remains as 11 and 12 because they're not strictly referring to z direction, just 2 unique pipe states which happen to be up and down
*/

//------------------------------------------------------
// Cross-z interaction checks
//------------------------------------------------------

/turf/proc/ztransit_enabled(var/checkdir)
	if(checkdir & UP)
		return ztransit_enabled_up()
	if(checkdir & DOWN)
		return ztransit_enabled_down()
	return 0

//Check turf above
/turf/proc/ztransit_enabled_up()
	return check_ztransit_up(src.z)

/proc/check_ztransit_up(var/curZ)
	if(curZ == 1)
		return 0

	//world << "check_ztransit_up()"

	var/obj/effect/mapinfo/cur_level = locate("sector[curZ]")
	/*if(cur_level)
		world << "cur_level.z: [cur_level.z] sectorname: [cur_level.sectorname]"
	else
		world << "\red could not find cur_level"*/
	var/obj/effect/mapinfo/target_level = locate("sector[curZ - 1]")
	/*if(target_level)
		world << "target_level.z: [target_level.z] sectorname: [target_level.sectorname]"
	else
		world << "\red could not find target_level"*/

	if(cur_level && cur_level && \
	target_level.sectorname && target_level.sectorname && \
	target_level.sectorname == target_level.sectorname)
		return 1

	return 0

//Check turf below
/turf/proc/ztransit_enabled_down()
	return check_ztransit_down(src.z)

/proc/check_ztransit_down(var/curZ)

	//world << "check_ztransit_down()"

	var/obj/effect/mapinfo/cur_level = locate("sector[curZ]")
	/*if(cur_level)
		world << "cur_level.z: [cur_level.z] sectorname: [cur_level.sectorname]"
	else
		world << "\red could not find cur_level"*/
	var/obj/effect/mapinfo/target_level = locate("sector[curZ + 1]")
	/*if(target_level)
		world << "target_level.z: [target_level.z] sectorname: [target_level.sectorname]"
	else
		world << "\red could not find target_level"*/

	if(cur_level && cur_level && \
	target_level.sectorname && target_level.sectorname && \
	target_level.sectorname == target_level.sectorname)
		return 1

	return 0
