
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
	return HasAbove(src.z)

/proc/HasAbove(var/curZ)
	if(curZ == 1)
		return 0

	while(z_transit_enabled.len < curZ)
		z_transit_enabled.Add(0)

	if(!z_transit_enabled[curZ])
		return 0

	return z_transit_enabled[curZ - 1]

proc/GetAbove(var/atom/atom)
	var/turf/turf = get_turf(atom)
	if(!turf)
		return null
	if(HasAbove(turf.z))
		return locate(turf.x, turf.y, turf.z - 1)
	return null


//Check turf below
/turf/proc/ztransit_enabled_down()
	return HasBelow(src.z)

/proc/HasBelow(var/curZ)
	while(z_transit_enabled.len < curZ)
		z_transit_enabled.Add(0)

	if(!z_transit_enabled[curZ])
		return 0

	if(curZ == z_transit_enabled.len)
		return 0

	return z_transit_enabled[curZ + 1]

proc/GetBelow(var/atom/atom)
	var/turf/turf = get_turf(atom)
	if(!turf)
		return null
	if(HasBelow(turf.z))
		return locate(turf.x, turf.y, turf.z + 1)
	return null
