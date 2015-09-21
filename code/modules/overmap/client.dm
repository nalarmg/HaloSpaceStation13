
//some extra player controls for the ship
//the numpad and arrow keys hook into standard mob controls, but this gives the players extra control
//see code\modules\mob\mob_movement.dm, code\modules\mob\mob.dm and interface\skin.dmf for that code

/client/verb/vehicle_thrust()
	set hidden = 1

	if(istype(src.mob) && istype(src.mob.machine, /obj/machinery/computer/helm))
		var/obj/machinery/computer/helm/H = src.mob.machine
		H.thrust_forward()
		return

	if(istype(src.mob) && istype(src.mob.machine, /obj/machinery/overmap_vehicle))
		var/obj/machinery/overmap_vehicle/V = src.mob.machine
		V.forward()
		return

/client/verb/vehicle_thrust_toggle()
	set hidden = 1

	if(istype(src.mob) && istype(src.mob.machine, /obj/machinery/computer/helm))
		var/obj/machinery/computer/helm/H = src.mob.machine
		H.thrust_forward_toggle()
		return

	if(istype(src.mob) && istype(src.mob.machine, /obj/machinery/overmap_vehicle))
		var/obj/machinery/overmap_vehicle/V = src.mob.machine
		V.forward_toggle()
		return
