
/obj/machinery/overmap_vehicle/verb/take_control()
	set name = "Take control"
	set category = "Vehicle"
	set src = usr.loc

	if(isliving(usr))
		make_pilot(usr)
	return 0

//just stop motion, we can worry about even decelleration later
/obj/machinery/overmap_vehicle/verb/halt()
	set name = "Halt movement"
	set category = "Vehicle"
	set src = usr.loc

	//disable_cruise()
	vehicle_transform.pixel_speed_x = 0
	vehicle_transform.pixel_speed_y = 0

/obj/machinery/overmap_vehicle/verb/enter()
	set name = "Enter vehicle"
	set category = "Vehicle"
	set src in oview(1)

	if(ishuman(usr))
		var/mob/user = usr
		if(isturf(src.loc))
			if(user.loc != src)
				if(crew.len < max_crew)
					//todo: check for active jetpacks and disable the ion trail
					user.loc = src
					my_observers.Add(user)
					if(user.client)
						user.client.view = 14//world.view
						user << "<span class='info'><b>You enter [src].</b></span>"
					crew.Add(user)
					user.reset_view(null)

					if(!pilot)
						make_pilot(user)
				else
					usr << "<span class='warning'>[src] is full, it can only hold [max_crew] people.</span>"
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

	crew -= usr
	my_observers -= usr
	if(usr.client)
		usr.client.view = world.view
		usr.client.eye = usr

/obj/machinery/overmap_vehicle/verb/check_speed()
	set name = "Get speed"
	set category = "Vehicle"
	set src = usr.loc

	usr << "\icon[src] [src] is currently going at [vehicle_transform.get_speed()]"

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

/*
/obj/machinery/overmap_vehicle/verb/enable_cruise()
	set name = "Enable engine cruise mode"
	set category = "Vehicle"
	set src = usr.loc

	usr << "<span class='info'>You enable engine cruise mode.</span>"
	cruising = 1
	if(!move_dir)
		vehicle_controls.move_toggle(usr, NORTH)
	vehicle_transform.set_new_maxspeed(cruise_speed)
	verbs -= /obj/machinery/overmap_vehicle/verb/enable_cruise
	verbs += /obj/machinery/overmap_vehicle/verb/disable_cruise

/obj/machinery/overmap_vehicle/verb/disable_cruise()
	set name = "Disable engine cruise mode"
	set category = "Vehicle"
	set src = usr.loc

	usr << "<span class='info'>You disable engine cruise mode.</span>"
	cruising = 0
	if(move_dir)
		vehicle_controls.move_toggle(usr, NORTH)
	vehicle_transform.set_new_maxspeed(max_speed)
	verbs -= /obj/machinery/overmap_vehicle/verb/disable_cruise
	verbs += /obj/machinery/overmap_vehicle/verb/enable_cruise
*/
