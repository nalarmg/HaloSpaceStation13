
/obj/machinery/overmap_vehicle/Destroy()
	. = ..()

	disable_cruise()

	//clean up references
	qdel(pixel_transform)
	qdel(overmap_object.pixel_transform)
	qdel(overmap_object)
	qdel(vehicle_controls)
	qdel(internal_atmosphere)

	//recycle the cruise transit area
	if(transit_area)
		transit_area.sprite_area_dark()
		transit_area.overmap_eject_object = null

		overmap_controller.virtual_areas_used -= transit_area
		overmap_controller.virtual_areas_unused += transit_area
		transit_area = null

	for(var/obj/machinery/overmap_vehicle/V in tracked_vehicles)
		stop_tracking_vehicle(V)
