
/obj/machinery/overmap_vehicle
	name = "vehicle"
	desc = "A vehicle"
	icon = 'longsword_test.dmi'
	icon_state = "longsword_test0"
	dir = 1
	density = 1
	anchored = 1
	layer = MOB_LAYER

	var/hovering_underlay = "hovering"

	var/list/passengers = list()
	var/max_passengers = 0
	var/hovering = 0
	var/thrusting = 0

	var/mob/living/pilot

	var/landing_gear_extended = 1
	var/extendable_landing_gear = 0

	var/armour = 100
	var/hull_remaining = 100
	var/hull_max = 100
	var/max_speed = 1
	var/max_speed_hover = 0.5
	var/yaw_speed = 5

	var/datum/vehicle_transform/vehicle_transform
	var/list/my_turrets = list()
	var/list/my_observers = list()

	var/last_thrust_update = 0

	var/next_shot_loc = 0

	//forward motion on nongravity/space turfs
	//pixels per sec
	var/datum/overmap_vehicle_component/thruster = new()
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
	var/datum/overmap_vehicle_component/power_gen = new()

/obj/machinery/overmap_vehicle/New()
	InitComponents()
	//processing_objects.Add(src)

	vehicle_transform = init_vehicle_transform(src)
	vehicle_transform.my_observers = my_observers
	vehicle_transform.heading = dir2angle(dir)
	vehicle_transform.max_pixel_speed = max_speed

	layer += 0.1

//obj/machinery/overmap_vehicle/process()

	/*var/delta_time = world.time - time_last_process
	time_last_process = world.time*/

	//if(hovering)
		//check fuel

	//if(moving from gravity turfs to nongravity turfs)
	//	lose control unless we have space capable thrusters

	//if(moving from nongravity turfs to nongravity turfs)
		//if(check to see if we fall 1 or more zlevels)
			//move down zlevels
			//take falling damage when we eventually hit
			//unless it's space, in which case transfer to overmap and start drifting away from the ship
		//else if(if we are stationary)
			//just settle nice and gently onto the ground

		//if(abs(O.pixel_speed_x) + abs(O.pixel_speed_y) <= 32)

/obj/machinery/overmap_vehicle/proc/InitComponents()
	//setup component verbs here
	if(thruster && thruster.rate)
		verbs += /datum/overmap_vehicle_component/verb/enable_hover
	//setup component stats in child objs

/obj/machinery/overmap_vehicle/relaymove(mob/user, direction)
	//accelerate to 10% of max speed
	var/accel = 0
	if(hovering || no_grav())
		accel = thruster.rate
	else
		accel = wheels.rate
	accel /= 10

	//thrust in direction
	if(direction in cardinal)
		vehicle_transform.add_pixel_speed_direction(accel, direction)
	else
		//if we're sending diagonals, just rotate
		//var/rotate_angle = shortest_angle_to_dir(vehicle_transform.heading, diagonal_to_cardinal(direction), yaw_speed)
		var/rotate_angle = vehicle_transform.turn_to_dir(diagonal_to_cardinal(direction), yaw_speed)
		if(rotate_angle != 0)
			//update the heading
			/*heading += rotate_angle
			while(heading > 360)
				heading -= 360
			while(heading < 0)
				heading += 360*/

			//world << "rotating [heading_change * rotate_speed] degrees from heading [heading] ([angle2dir(heading)]) to face heading [target_heading] ([angle2dir(target_heading)])"

			//inform our turrets we about the new heading so they can update their targetting overlays
			for(var/obj/machinery/overmap_turret/T in my_turrets)
				T.rotate_targetting_overlay(rotate_angle)

			//rotate the sprite
			/*var/icon/I = new (src.icon, src.icon_state)
			I.Turn(heading)
			src.icon = I*/

/obj/machinery/overmap_vehicle/proc/forward_toggle()
	thrusting = !thrusting
	thrust_loop()

/obj/machinery/overmap_vehicle/proc/thrust_loop()
	if(thrusting)
		forward()
		spawn(1)
			thrust_loop()

/obj/machinery/overmap_vehicle/proc/forward()
	//accelerate to 10% of max speed
	var/accel = max_speed / 10
	if(hovering)
		accel = max_speed_hover / 10
	vehicle_transform.add_pixel_speed_forward(accel)

/*/obj/machinery/overmap_vehicle/proc/thrust(var/thrust_direction)
	//standard checks
	if(thruster && thruster.integrity > 0 && thruster.rate > 0)
		//check fuel
		//

		if(dir_last_update)
			dir_next_update = dir_last_update | thrust_direction
		dir_last_update |= thrust_direction

		//world << "thrusting in dir [direction]"

/obj/machinery/overmap_vehicle/proc/ground_thrust(var/thrust_direction)
	//standard checks
	if(wheels && wheels.integrity > 0 && wheels.rate > 0)
		//check fuel
		//

		//check if we have traction
		//

		world << "moving in dir [thrust_direction]"*/

/obj/machinery/overmap_vehicle/proc/set_landing_gear(var/extended)
	if(extendable_landing_gear)
		landing_gear_extended = extended
		if(landing_gear_extended)
			visible_message("[src] extends its landing gear.")
			verbs -= /datum/overmap_vehicle_component/verb/extend_landing_gear
			verbs += /datum/overmap_vehicle_component/verb/retract_landing_gear
		else
			visible_message("[src] retracts its landing gear.")
			verbs -= /datum/overmap_vehicle_component/verb/retract_landing_gear
			verbs += /datum/overmap_vehicle_component/verb/extend_landing_gear

/obj/machinery/overmap_vehicle/proc/set_hovering(var/hovering_state)
	if(hovering_state)
		if(thruster && thruster.rate > 0)
			if(thruster.integrity > 0)
				usr << "<span class='info'>You switch the thrusters over to hover mode.</span>"
				hovering = 1
				vehicle_transform.max_pixel_speed = max_speed_hover
				verbs -= /datum/overmap_vehicle_component/verb/enable_hover
				verbs += /datum/overmap_vehicle_component/verb/disable_hover
				if(hovering_underlay)
					underlays += hovering_underlay
			else
				usr << "<span class='info'>Thrusters are too damaged to enter hover mode.</span>"
		else
			verbs -= /datum/overmap_vehicle_component/verb/enable_hover
	else
		//let's do a safety check if we're not going fast enough to stay aloft
		if(vehicle_transform.get_speed() <= 32)
			if(alert("Please confirm you want to disable hovering at this time", "Disable hover alert", "Continue", "Cancel")  == "Cancel")
				return
		usr << "<span class='info'>You switch the thrusters from hover mode to thrust mode.</span>"
		hovering = 0
		vehicle_transform.max_pixel_speed = max_speed
		verbs -= /datum/overmap_vehicle_component/verb/disable_hover
		if(thruster && thruster.rate > 0)
			verbs += /datum/overmap_vehicle_component/verb/enable_hover
		if(hovering_underlay)
			underlays -= hovering_underlay

/obj/machinery/overmap_vehicle/bullet_act(obj/item/projectile/P, def_zone)
	//todo: chance of component damage on hit
	//todo: targetting of specific components via def_zone
	if(P.damage >= armour)
		hull_remaining -= P.damage / armour
		health_update()

/obj/machinery/overmap_vehicle/proc/health_update()
	if(hull_remaining <= 0)
		//destroy the vehicle
		var/turf/centre_turf = get_step(src.loc, NORTHEAST)		//spawn the explosion on the centre turf
		for(var/mob/M in contents)
			M.loc = get_step_rand(centre_turf)
			M.unset_machine()
		//	proc/explosion(turf/epicenter, devastation_range, heavy_impact_range, light_impact_range, flash_range, adminlog = 1)
		qdel(src)
		explosion(centre_turf, 2, 3, 4, 5)

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

/obj/machinery/overmap_vehicle/verb/enter()
	set name = "Enter vehicle"
	set category = "Object"
	set src in oview(1)

	if(ishuman(usr))
		if(isturf(src.loc))
			if(usr.loc != src)
				usr << "<span class='info'><b>You enter [src].</b></span>"
				usr.loc = src
				if(!pilot)
					pilot = usr
					pilot.set_machine(src)
					usr << "<span class='info'>You are now the pilot!.</span>"
				my_observers.Add(usr)
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
		pilot = null
		usr << "<span class='info'>You are no longer the pilot!.</span>"

//just stop motion, we can worry about even decelleration later
/obj/machinery/overmap_vehicle/verb/halt()
	set name = "Halt movement"
	set category = "Vehicle"
	set src = usr.loc

	vehicle_transform.pixel_speed_x = 0
	vehicle_transform.pixel_speed_y = 0
