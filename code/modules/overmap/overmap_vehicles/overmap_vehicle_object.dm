
/obj/effect/overmapobj/vehicle
	icon = 'code/modules/overmap/overmap_vehicles/overmap_vehicles.dmi'
	animate_movement = 0
	var/obj/machinery/overmap_vehicle/overmap_vehicle
	layer = 3.1
	var/datum/vehicle_transform/vehicle_transform

/obj/effect/overmapobj/vehicle/New()
	vehicle_transform = init_vehicle_transform(src)
	//vehicle_transform.my_observers = my_observers
	vehicle_transform.heading = dir2angle(dir)
	vehicle_transform.my_observers = my_observers
	//vehicle_transform.max_pixel_speed = max_speed

/obj/effect/overmapobj/vehicle/observe_space(var/mob/user)
	//stop the vehicle from taking back control
	overmap_vehicle.my_observers.Remove(user)

	//regularly update the pixel offset
	my_observers.Add(user)

	//get mob/life code to check up on us periodically via check_eye(mob/user) to make sure everything is ok
	user.set_machine(src)

	//call it immediately to speed things up
	check_eye(user)

/obj/effect/overmapobj/vehicle/check_eye(var/mob/user)
	//if the parent proc didn't succeed, check if the player is inside us (a vehicle)
	if(user && user in my_observers)
		if(user.client && user.client.eye != src)
			user.reset_view(src, 0)

		return 0

	warning("[src] /obj/effect/overmapobj/vehicle/check_eye([user]) reset view unexpectedly")
	return -1

/obj/effect/overmapobj/vehicle/cancel_camera(var/mob/user)
	return overmap_vehicle.cancel_camera(user)

/obj/effect/overmapobj/vehicle/relaymove(mob/user, direction)
	overmap_vehicle.relaymove(user, direction)

/obj/effect/overmapobj/vehicle/spawn_overmap_meteor()
	//very low chance for it to actually hit the fighter
	if(prob(5))
		overmap_vehicle.impact_occupants_major("\icon[src] <span class='warning'>You have been hit by a meteor!</span>")

		var/fulldamage = pick(10, 25, 50) * rand(5,10)
		overmap_vehicle.hull_remaining -= fulldamage / overmap_vehicle.armour
		overmap_vehicle.health_update()
