datum/sensor_object
	var/image/pointer_image
	var/image/object_image
	var/faction
	var/atom/movable/tracking_object

datum/sensor_object/proc/create_pointer_image(var/pointer_icon_state = "dirpointer")
	if(!pointer_icon_state)
		pointer_icon_state = "dirpointer"

	//create the image
	pointer_image = image('code/modules/overmap/overmap_vehicles/overmap_vehicle_hud.dmi', src, "icon_state" = pointer_icon_state)
	pointer_image.appearance_flags = RESET_TRANSFORM|RESET_COLOR|RESET_ALPHA

	//grab the faction colour
	if(faction && overmap_controller.faction_iff_colour[faction])
		pointer_image.color = overmap_controller.faction_iff_colour[faction]

datum/sensor_object/proc/create_object_image(var/object_icon_state = "unknown")
	if(!object_icon_state)
		object_icon_state = "unknown"

	//create the image
	object_image = image('code/modules/overmap/overmap_vehicles/overmap_vehicle_hud.dmi', src, "icon_state" = object_icon_state)
	object_image.appearance_flags = RESET_TRANSFORM|RESET_COLOR|RESET_ALPHA

	//grab the faction colour
	if(faction && overmap_controller.faction_iff_colour[faction])
		object_image.color = overmap_controller.faction_iff_colour[faction]


datum/sensor_object/proc/add_viewmob(var/mob/living/M)
	if(M.client)
		M.client.images |= pointer_image
		M.client.images |= object_image

datum/sensor_object/proc/remove_viewmob(var/mob/living/M)
	if(M.client)
		M.client.images -= pointer_image
		M.client.images -= object_image


datum/sensor_object/proc/clear_self()
	qdel(pointer_image)
	qdel(object_image)

	PlaceInPool(src)
