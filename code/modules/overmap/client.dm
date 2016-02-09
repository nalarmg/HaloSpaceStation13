
//some extra player controls for the ship
//the numpad and arrow keys hook into standard mob controls, but this gives the players extra control
//see code\modules\mob\mob_movement.dm, code\modules\mob\mob.dm and interface\skin.dmf for that code

/client/verb/vehicle_thrust()
	set hidden = 1

	if(src.mob && istype(src.mob.machine, /obj/machinery/computer/helm))
		var/obj/machinery/computer/helm/H = src.mob.machine
		H.thrust_forward(src.mob)
		return

	if(src.mob && istype(src.mob.machine, /obj/machinery/computer/shuttle_helm))
		var/obj/machinery/computer/shuttle_helm/H = src.mob.machine
		H.thrust_forward(src.mob)
		return

	if(src.mob && istype(src.mob.loc, /obj/machinery/overmap_vehicle))
		var/obj/machinery/overmap_vehicle/V = src.mob.loc
		V.vehicle_thrust(src.mob)
		return

/client/verb/vehicle_thrust_toggle()
	set hidden = 1

	if(src.mob && istype(src.mob.machine, /obj/machinery/computer/helm))
		var/obj/machinery/computer/helm/H = src.mob.machine
		H.thrust_forward_toggle(src.mob)
		return

	if(src.mob && istype(src.mob.machine, /obj/machinery/computer/shuttle_helm))
		var/obj/machinery/computer/shuttle_helm/H = src.mob.machine
		H.thrust_forward_toggle(src.mob)
		return

	if(src.mob && istype(src.mob.loc, /obj/machinery/overmap_vehicle))
		var/obj/machinery/overmap_vehicle/V = src.mob.loc
		V.vehicle_thrust_toggle(src.mob)
		return
