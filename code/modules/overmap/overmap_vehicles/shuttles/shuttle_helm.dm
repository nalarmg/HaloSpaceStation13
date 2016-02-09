/obj/machinery/computer/shuttle_helm
	name = "helm control console"
	icon_keyboard = "med_key"
	icon_screen = "steering"
	var/state = "status"
	var/obj/machinery/overmap_vehicle/shuttle/my_shuttle

/obj/machinery/computer/shuttle_helm/attack_hand(var/mob/user as mob)
	add_fingerprint(user)
	if(can_use(user))
		ui_interact(user)

/obj/machinery/computer/shuttle_helm/relaymove(var/mob/user, direction)
	if(my_shuttle)
		my_shuttle.relaymove(user,direction)

/obj/machinery/computer/shuttle_helm/proc/thrust_forward(var/mob/user)
	if(my_shuttle)
		my_shuttle.vehicle_thrust(user)

/obj/machinery/computer/shuttle_helm/proc/thrust_forward_toggle(var/mob/user)
	if(my_shuttle)
		my_shuttle.vehicle_thrust_toggle(user)

/obj/machinery/computer/shuttle_helm/ui_interact(mob/user, ui_key = "main", var/datum/nanoui/ui = null, var/force_open = 1)

	if(!my_shuttle || !can_use(user))
		if(ui)
			ui.close()
		return

	var/data[0]
	data["state"] = state

	data["user"] = "\ref[user]"
	data["shipname"] = my_shuttle.name
	data["sector"] = "Deep Space"//my_shuttle.current_sector ? my_shuttle.current_sector.name : "Deep Space"
	data["sector_info"] = "Not Available"//my_shuttle.current_sector ? my_shuttle.current_sector.desc : "Not Available"
	data["s_x"] = my_shuttle.overmap_object.x
	data["s_y"] = my_shuttle.overmap_object.y
	data["speed"] = my_shuttle.vehicle_transform.get_speed()
	data["accel"] = round(my_shuttle.get_relative_directional_thrust(NORTH))
	data["heading"] = my_shuttle.vehicle_transform.heading
	data["move_dir"] = my_shuttle.move_dir
	data["turn_dir"] = my_shuttle.turn_dir
	data["view_shuttle"] = !user.machine
	data["view_external"] = user.machine == my_shuttle
	data["view_overmap"] = user.machine == my_shuttle.overmap_object
	data["autobraking"] = my_shuttle.autobraking
	data["brake_disabled"] = my_shuttle.vehicle_transform.is_still()
	data["maglocked"] = my_shuttle.is_maglocked()

	if(my_shuttle.is_cruising())
		data["brake_disabled"] = 1
		data["cruising"] = 1
		data["heading"] = my_shuttle.overmap_object.vehicle_transform.heading

	/*var/list/locations[0]
	for (var/datum/data/record/R in known_sectors)
		var/list/rdata[0]
		rdata["name"] = R.fields["name"]
		rdata["x"] = R.fields["x"]
		rdata["y"] = R.fields["y"]
		rdata["reference"] = "\ref[R]"
		locations.Add(list(rdata))

	data["locations"] = locations*/

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data, force_open)
	if (!ui)
		ui = new(user, src, ui_key, "helm_shuttle.tmpl", "[my_shuttle.name] Helm", 380, 560)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/computer/shuttle_helm/proc/can_use(var/mob/M)
	if(M.stat || M.restrained() || M.lying || !istype(M, /mob/living) || get_dist(M, src) > 1)
		return 0
	return 1

/obj/machinery/computer/shuttle_helm/Topic(href, href_list)

	if (href_list["yaw"])
		var/mob/living/carbon/human/M = locate(href_list["user"])
		if(istype(M) && can_use(M))
			if(!my_shuttle.is_maglocked())
				var/targetdir = text2num(href_list["yaw"])
				if(my_shuttle.is_cruising())
					if(my_shuttle.turn_dir == targetdir)
						my_shuttle.turn_dir = 0
					else
						//regular update procs will handle the rest
						my_shuttle.turn_dir = targetdir
						my_shuttle.update()
				else
					//this gives a target orientation so lets find out what we'll direction actually turn
					if(targetdir != my_shuttle.dir)
						my_shuttle.turn_towards_dir(targetdir)

	if (href_list["move"])
		var/mob/living/carbon/human/M = locate(href_list["user"])
		if(istype(M) && can_use(M))
			if(!my_shuttle.is_maglocked() && !my_shuttle.is_cruising())
				var/targetdir = text2num(href_list["move"])
				//moving straight ahead or behind uses pixel based movement
				if(targetdir == my_shuttle.dir || targetdir == turn(my_shuttle.dir, 180))
					//disable autobrake and enable automave
					my_shuttle.autobraking = 0

					if(my_shuttle.move_dir == targetdir)
						my_shuttle.move_dir = 0
					else
						my_shuttle.move_dir = targetdir

					//start the shuttle update loop
					my_shuttle.update()

				else if(world.time > my_shuttle.time_last_maneuvre + my_shuttle.maneuvre_cooldown)
					//strafing uses ordinary turf based movement
					//don't use automove
					var/olddir = my_shuttle.dir
					my_shuttle.Move(get_step(my_shuttle, targetdir))
					my_shuttle.dir = olddir

					//limit how often we can strafe
					my_shuttle.time_last_maneuvre = world.time

	if (href_list["cruise"])
		var/mob/living/carbon/human/M = locate(href_list["cruise"])
		if(istype(M) && can_use(M))
			if(my_shuttle.is_cruising())
				my_shuttle.disable_cruise(M)
				my_shuttle.move_dir = my_shuttle.dir
			else if(my_shuttle.enable_cruise(M))
				my_shuttle.move_dir = 0

	if (href_list["brake"])
		var/mob/living/carbon/human/M = locate(href_list["brake"])
		if(istype(M) && can_use(M))
			if(!my_shuttle.is_maglocked() && !my_shuttle.is_cruising() && !my_shuttle.vehicle_transform.is_still())
				my_shuttle.move_dir = 0
				my_shuttle.autobraking = 1

	if (href_list["view_shuttle"])
		var/mob/living/carbon/human/M = locate(href_list["view_shuttle"])
		if(istype(M))
			//first call to exit out of overmap view
			M.cancel_camera()

			//second call to exit out of shuttle view
			M.cancel_camera()

	if (href_list["view_external"])
		var/mob/living/carbon/human/M = locate(href_list["view_external"])
		if(istype(M) && can_use(M))
			M.set_machine(my_shuttle)
			my_shuttle.check_eye(M)

	if (href_list["view_overmap"])
		var/mob/living/carbon/human/M = locate(href_list["view_overmap"])
		if(istype(M) && can_use(M))
			my_shuttle.observe_space(M)
	/*
		var/mob/living/carbon/human/M = locate(href_list["manual"])
		if(istype(M))
			if(!(M in my_shuttle.pilots))
				my_shuttle.pilots.Add(M)

			if(M.machine == my_shuttle)
				my_shuttle.cancel_camera(M)
			else if(!my_shuttle.is_maglocked())
				if(!(M in my_shuttle.pilots))
					my_shuttle.pilots.Add(M)
				M.set_machine(my_shuttle)
				my_shuttle.check_eye(M)
			else
				M << "\icon[my_shuttle] <span class='warning'>You cannot pilot [my_shuttle] while it is maglocked.</span>"
				*/

	if (href_list["maglock"])
		var/mob/living/carbon/human/M = locate(href_list["maglock"])
		if(istype(M) && can_use(M))
			if(!my_shuttle.is_cruising())
				my_shuttle.toggle_maglock(M)
