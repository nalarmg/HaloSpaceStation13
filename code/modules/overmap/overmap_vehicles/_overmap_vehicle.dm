
/obj/machinery/overmap_vehicle
	name = "vehicle"
	desc = "A vehicle"
	//icon = 'longsword_test.dmi'
	//icon_state = "longsword_test0"
	dir = 1
	density = 1
	anchored = 1
	layer = MOB_LAYER

	var/hovering_underlay = "hovering"

	var/list/occupants = list()
	var/occupants_max = 1
	var/move_dir = 0
	var/turn_dir = 0
	var/autobraking = 0

	var/mob/living/pilot

	var/iff_faction_broadcast			//set this to a faction
	var/sensor_icon_state = "unknown"	//the icon state for this vehicle on other vehicle's sensors
	var/time_next_sensor_update = 0
	var/sensor_update_delay = 0			//just update every process()
	var/list/tracked_vehicles = list()
	var/list/all_sensor_objects = list()
	var/list/mobs_tracking = list()
	var/iff_faction_colours = 1

	var/obj/effect/overmapobj/vehicle/overmap_object
	var/obj/effect/virtual_area/transit_area

	var/armour = 100
	var/hull_remaining = 100
	var/hull_max = 100
	var/max_speed = 32			//pixels per ms
	var/accel_duration = 10		//how long until max speed in ms
	var/yaw_speed = 5

	var/cruise_speed = 4		//overmap pixels per ms

	var/damage_state = 0
	var/icon/damage_overlay

	var/datum/pixel_transform/pixel_transform

	var/default_controlscheme_type = /datum/vehicle_controls
	var/datum/vehicle_controls/vehicle_controls
	var/datum/gas_mixture/internal_atmosphere

	var/list/my_turrets = list()
	var/list/my_observers = list()

	var/main_update_start_time = -1
	var/update_interval = 1

	var/next_shot_loc = 0

	//forward motion on nongravity/space turfs
	//pixels per sec
	/*var/datum/overmap_vehicle_component/thruster = new()
	//turn rate on nongravity/space turfs
	//degrees per sec
	var/datum/overmap_vehicle_component/thruster_turn = new()
	//forward motion on on gravity turfs
	//pixels per sec
	var/datum/overmap_vehicle_component/wheels = new()
	//turn rate on gravity turfs
	//degrees per sec
	var/datum/overmap_vehicle_component/wheels_turn = new()
	//speed in slipspace
	//pixels tiles per sec
	var/datum/overmap_vehicle_component/slipspace = new()
	//main energy generator
	//watts per sec
	var/datum/overmap_vehicle_component/power_gen = new()*/

/obj/machinery/overmap_vehicle/New()
	//InitComponents()

	pixel_transform = init_pixel_transform(src)
	pixel_transform.my_observers = my_observers
	pixel_transform.heading = dir2angle(dir)
	pixel_transform.max_pixel_speed = max_speed

	vehicle_controls = new default_controlscheme_type(src)

	layer += 0.1

	//just have approx 1 atm internal pressure along with a decent supply of air
	internal_atmosphere = new/datum/gas_mixture
	internal_atmosphere.temperature = T20C
	internal_atmosphere.group_multiplier = 1
	var/internal_cells = (bound_width * bound_height) / (32 * 32)
	internal_atmosphere.volume = CELL_VOLUME * internal_cells
	internal_atmosphere.adjust_multi("oxygen", MOLES_O2STANDARD * internal_cells, "carbon_dioxide", 0, "nitrogen", MOLES_N2STANDARD * internal_cells, "phoron", 0)

	//world << "[src] internal pressure: [internal_atmosphere.return_pressure()] kpa"

	overmap_object = new(src)//locate(src.x, src.y, OVERMAP_ZLEVEL)
	var/obj/effect/overmapobj/overmapobj = map_sectors["[src.z]"]
	if(overmapobj)
		overmap_object.loc = overmapobj.loc
	overmap_object.name = src.name
	overmap_object.overmap_vehicle = src
	pixel_transform.my_overmap_object = overmap_object
	//vehicle.overmap_icon_base = overmap_object.icon

	//verbs -= /obj/machinery/overmap_vehicle/verb/disable_cruise

	processing_objects.Add(src)

	//initiate tracking sensors
	var/obj/effect/zlevelinfo/curz = locate("zlevel[src.z]")
	curz.objects_preventing_recycle.Add(src)
	enter_new_zlevel(curz)

/obj/machinery/overmap_vehicle/process()

	//update the iff sensor overlays
	//todo: tweak the update delay
	if(world.time >= time_next_sensor_update)
		time_next_sensor_update = world.time + sensor_update_delay
		update_tracking_overlays()

	/*var/delta_time = world.time - time_last_process
	time_last_process = world.time*/

	//if(hovering)
		//check fuel

	//if(move_dir from gravity turfs to nongravity turfs)
	//	lose control unless we have space capable thrusters

	//if(move_dir from nongravity turfs to nongravity turfs)
		//if(check to see if we fall 1 or more zlevels)
			//move down zlevels
			//take falling damage when we eventually hit
			//unless it's space, in which case transfer to overmap and start drifting away from the ship
		//else if(if we are stationary)
			//just settle nice and gently onto the ground

		//if(abs(O.pixel_speed_x) + abs(O.pixel_speed_y) <= 32)
/*
/obj/machinery/overmap_vehicle/proc/InitComponents()
	//setup component verbs here
	if(thruster)
		if(!thruster.rate)
			thruster.rate = max_speed
		verbs += /datum/overmap_vehicle_component/verb/enable_hover
	//setup component stats in child objs
	*/

/obj/machinery/overmap_vehicle/relaymove(mob/user, direction)
	if(user == pilot)
		vehicle_controls.relay_move(user, direction)
	else
		user << "<span class='warning'>You are not the pilot of [src]!</span>"

/obj/machinery/overmap_vehicle/proc/vehicle_thrust(var/mob/user)
	if(user == pilot)
		vehicle_controls.move_vehicle(NORTH)
	else
		user << "<span class='warning'>You are not the pilot of [src]!</span>"

/obj/machinery/overmap_vehicle/proc/vehicle_thrust_toggle(var/mob/user)
	if(user == pilot)
		vehicle_controls.move_toggle(NORTH)
	else
		user << "<span class='warning'>You are not the pilot of [src]!</span>"

/obj/machinery/overmap_vehicle/proc/update(var/my_update_start_time = -1)

	if(!src || !src.loc)
		main_update_start_time = -1
		return

	if(main_update_start_time < 0)
		my_update_start_time = world.time
		main_update_start_time = world.time
	else if(my_update_start_time != main_update_start_time)
		return

	var/continue_update = 0

	//apply thrust if we've got it toggled on
	if(handle_auto_moving())
		continue_update = 1

	//if we are cruising, force auto-accelerate forwards
	if(handle_auto_cruising())
		continue_update = 1

	//if the player wants us to automatically orient to face a direction
	if(handle_auto_turning())
		continue_update = 1

	//apply brake otherwise
	if(autobraking)
		if(pixel_transform.is_still())
			autobraking = 0
		else
			pixel_transform.brake(get_relative_directional_thrust(NORTH))
			continue_update = 1

	//update the sprite
	if(pixel_transform.update(update_interval))
		continue_update = 1

	//only spawn another update if there's something that needs updating
	if(continue_update)
		spawn(update_interval)
			update(my_update_start_time)
	else
		main_update_start_time = -1

//override in children if necessary
/obj/machinery/overmap_vehicle/proc/handle_auto_turning()
	//world << "/obj/machinery/overmap_vehicle/shuttle/handle_auto_turning() turn_dir:[turn_dir]"
	if(turn_dir)
		vehicle_controls.turn_vehicle(pilot, turn_dir)
		var/datum/pixel_transform/target_transform = pixel_transform
		if(is_cruising())
			target_transform = overmap_object.pixel_transform

		if(target_transform.heading == dir2angle(turn_dir))
			turn_dir = 0
		else
			return 1
	return 0

//override in children if necessary
/obj/machinery/overmap_vehicle/proc/handle_auto_cruising()
	if(is_cruising())
		overmap_object.pixel_transform.accelerate_forward(cruise_speed)
		return 1

	return 0

//override in children if necessary
/obj/machinery/overmap_vehicle/proc/handle_auto_moving()
	if(move_dir)
		vehicle_controls.move_vehicle(pilot, move_dir)
		return 1
	return 0

/obj/machinery/overmap_vehicle/proc/get_absolute_directional_thrust(var/direction)
	//north = north on the map

	return get_relative_directional_thrust(direction)

/obj/machinery/overmap_vehicle/proc/get_relative_directional_thrust(var/direction)
	//north = front of the shuttle

	var/accel = max_speed
	/*if(hovering || no_grav())
		accel = thruster.rate
	else
		accel = wheels.rate*/
	accel /= accel_duration

	return accel

/obj/machinery/overmap_vehicle/proc/fall()
	//fall!
	visible_message("<span class='warning'><b>[src] drops out of the air!</b></span>")

	//process() will handle destruction checks
	//todo: actually move the vehicle down zlevels if it is high above the ground
	//todo: scale damage with number of zlevels fallen
	hull_remaining -= 10

/obj/machinery/overmap_vehicle/proc/no_grav()
	//just check if we're in space or not
	var/turf/T = get_turf(src)
	if(T.is_space())
		return 1

	return 0

/obj/machinery/overmap_vehicle/proc/make_pilot(var/mob/living/H)
	if(pilot && pilot.machine == src)
		if(pilot == H)
			H << "\icon[src] <span class='info'>You already control [src].</span>"
		else
			H << "\icon[src] <span class='info'>[src] is already being piloted by [pilot]</span>"
	else
		pilot = H
		usr << "\icon[src] <span class='info'>You are now the pilot!</span>"
		add_tracking_overlays(H)

//so passengers dont asphyxiate or die of pressure loss
/obj/machinery/overmap_vehicle/return_air()
	return internal_atmosphere
