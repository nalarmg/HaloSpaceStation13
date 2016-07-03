
/obj/effect/overmapobj/bigasteroid/proc/step_smoothing()
	. = 1

	//loop over the morphed masks and smooth them out so they dont look ugly

	//grab the current turf
	current_turf = locate(gen_x, gen_y, myzlevel.z)
	var/same_nearby = 0
	var/masks_nearby = 0
	for(var/turf/T in orange(1, current_turf))
		//check our neighbors to see what type they all are
		if(T.type == current_turf.type)
			same_nearby++
		if(istype(T, /turf/unsimulated/mask))
			masks_nearby++

	//if there's not enough of the same turf type nearby, "smooth" it by changing it to match its neighbors
	if(same_nearby < pick(3,4))
		if(masks_nearby > 3)
			mask_turfs += new /turf/unsimulated/mask(current_turf)
		else
			mask_turfs -= current_turf
			new /turf/space(current_turf)

	//increment the coords for the next step
	gen_x += 1
	if(gen_x > world.maxx)
		gen_x = 1
		gen_y += 1

	//reset everything if we're done smoothing
	if(gen_y > world.maxy)
		gen_y = 1
		. = 0
