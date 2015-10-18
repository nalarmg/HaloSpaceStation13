
//===================================================================================
//Overmap object representing a zlevel or other notable object
//===================================================================================

/obj/effect/overmapobj
	name = "map object"
	icon = 'sector_icons.dmi'
	icon_state = ""		//default warning signal to show a missing sprite
	var/map_z = 0
	var/area/shuttle/shuttle_landing
	var/always_known = 1
	var/heading = 0
	dir = 1
	var/list/my_observers = list()
	var/list/my_turrets = list()

/obj/effect/overmapobj/New(var/obj/effect/overmapinfo/data)
	map_z = data.zlevel
	name = data.name
	always_known = data.known
	if (data.icon != 'icons/mob/screen1.dmi')
		icon = data.icon
		icon_state = data.icon_state
	if(data.desc)
		desc = data.desc
	var/new_x = data.mapx ? data.mapx : rand(OVERMAP_EDGE, world.maxx - OVERMAP_EDGE)
	var/new_y = data.mapy ? data.mapy : rand(OVERMAP_EDGE, world.maxy - OVERMAP_EDGE)
	loc = locate(new_x, new_y, OVERMAP_ZLEVEL)

	if(data.landing_area)
		shuttle_landing = locate(data.landing_area)

/obj/effect/overmapobj/CanPass(atom/movable/A)
	//testing("[A] attempts to enter sector\"[name]\"")
	return 1

/obj/effect/overmapobj/Crossed(atom/movable/A)
	//testing("[A] has entered sector\"[name]\"")
	if (istype(A,/obj/effect/overmapobj/ship))
		var/obj/effect/overmapobj/ship/S = A
		S.current_sector = src

/obj/effect/overmapobj/Uncrossed(atom/movable/A)

	//testing("[A] has left sector\"[name]\"")
	if (istype(A,/obj/effect/overmapobj/ship))
		var/obj/effect/overmapobj/ship/S = A
		S.current_sector = null

/obj/effect/overmapobj/bullet_act(var/obj/item/projectile/P, def_zone)
	if(P.firer == src)
		world << "overmap projectile skipping source [src]"
		return PROJECTILE_CONTINUE

	world << "[src] has been hit by [P]"

/obj/effect/overmapobj/sector
	name = "generic sector"
	desc = "Sector with some stuff in it."
	anchored = 1
