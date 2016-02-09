
/obj/machinery/overmap_vehicle/verb/take_control()
	set name = "Take control"
	set category = "Vehicle"
	set src = usr.loc

	if(isliving(usr))
		make_pilot(usr)
	return 0

//just stop motion, we can worry about even decelleration later
//todo: replace this with a proper autobrake
/obj/machinery/overmap_vehicle/verb/halt()
	set name = "Halt movement"
	set category = "Vehicle"
	set src = usr.loc

	if(is_cruising())
		usr << "You must exit cruise before you can halt"
	else
		vehicle_transform.pixel_speed_x = 0
		vehicle_transform.pixel_speed_y = 0
		vehicle_transform.pixel_speed = 0

/obj/machinery/overmap_vehicle/verb/enter()
	set name = "Enter vehicle"
	set category = "Vehicle"
	set src in oview(1)

	if(ishuman(usr))
		var/mob/user = usr
		if(isturf(src.loc))
			if(user.loc != src)
				if(occupants_max < 1 || occupants.len < occupants_max)
					//todo: check for active jetpacks and disable the ion trail
					user.loc = src
					if(user.client)
						user.client.view = 14//double the default world.view which is 7, and dont go any larger than this
						user << "<span class='info'><b>You enter [src].</b></span>"
					user.set_machine(src)
					check_eye(user)
					occupants.Add(user)

					if(!pilot)
						make_pilot(user)

					return 1
				else
					usr << "<span class='warning'>[src] is full, it can only hold [occupants_max] people.</span>"
			else
				usr << "<span class='info'>You are already inside [src].</span>"
		else
			usr << "<span class='info'>You cannot reach [src] from here.</span>"
	else
		usr << "<span class='info'>You are unable to enter [src].</span>"

/obj/machinery/overmap_vehicle/verb/exit()
	set name = "Exit vehicle"
	set category = "Vehicle"
	set src = usr.loc

	usr.loc = src.loc
	usr << "<span class='info'><b>You exit [src].</b></span>"
	my_observers.Remove(usr)
	if(pilot == usr)
		pilot.unset_machine()
		clear_tracking_overlays(pilot)
		pilot = null
		usr << "\icon[src] <span class='info'>You are no longer the pilot!</span>"

	occupants -= usr
	my_observers -= usr
	if(usr.client)
		usr.client.view = world.view
		usr.client.eye = usr

	if(is_cruising())
		//this should handle all of the sector detection and placement logic
		overmap_controller.spawn_to_sector(overmap_object.loc, usr, overmap_object)

/obj/machinery/overmap_vehicle/verb/check_speed()
	set name = "Get speed"
	set category = "Vehicle"
	set src = usr.loc

	var/speed
	if(is_cruising())
		speed = "[world.maxx * cruise_speed / 32] (cruising)"
	else
		speed = "[vehicle_transform.get_speed()]"

	usr << "\icon[src] [src] is currently going at [speed]"

obj/machinery/overmap_vehicle/verb/toggle_iff_scanner()
	set name = "Toggle fighter IFF scanner"
	set category = "Vehicle"
	set src = usr.loc

	var/mob/user = usr
	if(user == pilot)
		if(mobs_tracking.Find(user))
			clear_tracking_overlays(user)
			user << "\icon[src] Identify friend/foe sensors toggled <span class='warning'>OFF</span>"
		else
			add_tracking_overlays(user)
			user << "\icon[src] Identify friend/foe sensors toggled <span class='notice'>ON</span>"
	else
		user << "<span class='warning'>You are not the pilot of [src]</span>"

obj/machinery/overmap_vehicle/verb/cycle_iff_colours()
	set name = "Cycle IFF colours"
	set category = "Vehicle"
	set src = usr.loc

	var/mob/user = usr
	if(user == pilot)
		//switch the colours
		iff_faction_colours = !iff_faction_colours
		if(iff_faction_colours)
			user << "\icon[src] Identify friend/foe sensor colours cycled to <span class='info'>FACTION</span> colours"
		else
			user << "\icon[src] Identify friend/foe sensor colours cycled to <span class='info'>FRIEND/FOE</span> colours"

		//reset all tracking images
		var/list/checked_vehicles = list()
		for(var/obj/machinery/overmap_vehicle/V in tracked_vehicles)
			stop_tracking_vehicle(V)
			checked_vehicles.Add(V)
		for(var/obj/machinery/overmap_vehicle/V in checked_vehicles)
			start_tracking_vehicle(V)
	else
		user << "<span class='warning'>You are not the pilot of [src]</span>"
