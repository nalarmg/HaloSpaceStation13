
/proc/init_vehicle_transform(var/atom/movable/new_mover)
	var/datum/vehicle_transform/vehicle_transform = new()
	vehicle_transform.control_object = new_mover
	vehicle_transform.heading = dir2angle(new_mover.dir)
	new_mover.animate_movement = 0

	//vehicle_transform.icon_base = new(new_mover.icon)
	//vehicle_transform.icon_state = new_mover.icon_state
	//vehicle_transform.icon_state_original = vehicle_transform.icon_state

	return vehicle_transform

/datum/vehicle_transform
	var/atom/movable/control_object

	//var/icon/icon_base

	//var/icon_state
	//var/icon_state_original
	var/icon_state_thrust
	var/icon_state_brake
	var/thrust_left = 0

	var/obj/effect/overmapobj/vehicle/my_overmap_object
	var/icon/overmap_icon_base
	var/overmap_icon_state

	//var/obj/effect/loctracker

	var/pixel_speed_x = 0
	var/pixel_speed_y = 0
	var/pixel_progress_x = 0
	var/pixel_progress_y = 0

	/*var/omap_pixel_x = 0
	var/omap_pixel_y = 0*/

	var/heading = 180

	var/pixel_speed = 0
	var/max_pixel_speed = 10

	var/list/my_observers = list()

	var/update_interval = 1
	var/main_update_start_time = -1

/*/datum/vehicle_transform/New()
	loctracker = new /obj/effect(src)
	loctracker.name = "loctracker"
	loctracker.layer = MOB_LAYER
	loctracker.icon = 'icons/obj/inflatable.dmi'
	loctracker.icon_state = "door_opening"*/

//unused for now
/*
/datum/vehicle_transform/proc/set_pixel_speed(var/new_speed_x, var/new_speed_y)
	pixel_speed_x = new_speed_x
	pixel_speed_y = new_speed_y

	if(!is_still())
		update()
		*/

/datum/vehicle_transform/proc/accelerate_forward(var/acceleration)
	add_pixel_speed_angle(acceleration, heading)

/datum/vehicle_transform/proc/brake(var/acceleration)

	//can we take a shortcut here?
	if(pixel_speed <= acceleration)
		pixel_speed_x = 0
		pixel_speed_y = 0
		pixel_speed = 0
	else
		//calculate the exact speed loss
		var/target_speed = pixel_speed - acceleration
		var/speed_multiplier = target_speed / pixel_speed

		var/accel_x = pixel_speed_x * speed_multiplier - pixel_speed_x
		var/accel_y = pixel_speed_y * speed_multiplier - pixel_speed_y

		add_pixel_speed(accel_x, accel_y)

/datum/vehicle_transform/proc/add_pixel_speed_direction(var/acceleration, var/direction)
	add_pixel_speed_angle(acceleration, dir2angle(direction))

/datum/vehicle_transform/proc/add_pixel_speed_direction_relative(var/acceleration, var/relative_direction)
	add_pixel_speed_angle(acceleration, dir2angle(relative_direction) + heading)

/datum/vehicle_transform/proc/add_pixel_speed_angle(var/acceleration, var/angle)
	//work out the x and y components according to our heading
	var/x_accel = sin(angle) * acceleration
	var/y_accel = cos(angle) * acceleration

	add_pixel_speed(x_accel, y_accel)

	if(angle == heading)
		spawn_thrust()

/datum/vehicle_transform/proc/add_pixel_speed(var/accel_x, var/accel_y)
	pixel_speed_x += accel_x
	pixel_speed_y += accel_y

	recalc_speed()
	limit_speed()

	if(!is_still())
		try_update()

/datum/vehicle_transform/proc/limit_speed()
	//work out if we're getting close to max speed
	if(max_pixel_speed > 0)
		var/total_speed = get_speed()
		//world << "current speed: [total_speed]/[max_pixel_speed]"

		//we're over max speed, so normalise then cap the speed
		if(total_speed > max_pixel_speed)
			pixel_speed_x /= total_speed
			pixel_speed_x *= max_pixel_speed
			pixel_speed_y /= total_speed
			pixel_speed_y *= max_pixel_speed
			//world << "normalised down to: [get_speed()]"

			recalc_speed()

/datum/vehicle_transform/proc/set_new_maxspeed(var/new_max_speed)
	var/total_speed = get_speed()
	max_pixel_speed = new_max_speed

	if(total_speed)
		pixel_speed_x /= total_speed
		pixel_speed_x *= max_pixel_speed
		pixel_speed_y /= total_speed
		pixel_speed_y *= max_pixel_speed
		recalc_speed()

/datum/vehicle_transform/proc/is_still()
	return !(pixel_speed_x || pixel_speed_y)

/datum/vehicle_transform/proc/get_speed()
	return pixel_speed

/datum/vehicle_transform/proc/recalc_speed()
	pixel_speed = sqrt(pixel_speed_x * pixel_speed_x + pixel_speed_y * pixel_speed_y)

/datum/vehicle_transform/proc/spawn_thrust()
	if(thrust_left)
		thrust_left = 8
	else
		thrust_left = 4
		control_object.overlays += icon_state_thrust

/*
/datum/vehicle_transform/proc/enter_new_zlevel(var/obj/effect/overmapobj/target_obj)
	//if we have a separate overmap object, update its turf on the overmap
	if(my_overmap_object)

		//update the pixel_x offset
		my_overmap_object.pixel_x = 32 * (control_object.x / 255) - 16
		my_overmap_object.pixel_y = 32 * (control_object.y / 255) - 16
		/*if(my_overmap_object.x < target_obj.x)
			my_overmap_object.pixel_x = 0
		else if(my_overmap_object.x > target_obj.x)
			my_overmap_object.pixel_x = 32
		//update the pixel_y offset
		if(my_overmap_object.y < target_obj.y)
			my_overmap_object.pixel_y = 0
		else if(my_overmap_object.y > target_obj.y)
			my_overmap_object.pixel_y = 32*/

		//update the turf loc
		my_overmap_object.Move(target_obj.loc)
		//loctracker.loc = my_overmap_object.loc
*/
