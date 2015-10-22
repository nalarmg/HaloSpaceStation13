
//===================================================================================
//Metaobject for storing information about sector this zlevel is representing.
//Should be placed only once on every zlevel.
//===================================================================================

/obj/effect/overmapinfo/
	name = "map info metaobject"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	invisibility = 101
	var/obj_type		//type of overmap object it spawns
	var/landing_area 	//type of area used as inbound shuttle landing, null if no shuttle landing area
	var/zlevel
	var/mapx			//coordinates on the
	var/mapy			//overmap zlevel
	var/known = 1
	var/sectorname = "Generic Sector"
	var/icon_state_name = ""

/obj/effect/overmapinfo/New()
	tag = "sector[z]"
	zlevel = z

/obj/effect/overmapinfo/sector
	name = "generic sector"
	obj_type = /obj/effect/overmapobj/sector

/obj/effect/overmapinfo/ship
	name = "generic ship"
	obj_type = /obj/effect/overmapobj/ship
	var/ship_turfs
	var/ship_levels
	sectorname = "Generic Space Vessel"

//place this onto empty space levels to be automatically added to the cache of preloaded temporary sectors
/obj/effect/overmapinfo/cached_space
