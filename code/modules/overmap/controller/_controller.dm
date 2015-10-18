
//===================================================================================
//Controller to build and update overmap
//===================================================================================

//see code\controllers\Processes\overmap.dm

var/global/datum/controller/process/overmap/overmap_controller
var/global/list/map_sectors = list()
var/global/list/cached_spacepre = list()

/datum/controller/process/overmap
	name = "overmap controller"
	var/list/cached_space = list()
	var/list/moving_levels = list()
	var/list/map_sectors_reference
	//var/list/cached_space_prec

datum/controller/process/overmap/setup()

	/*if(!config.use_overmap)
		return kill()*/

	overmap_controller = src

	testing("Building overmap...")

	var/obj/effect/overmapinfo/data
	for(var/level in 1 to world.maxz)
		data = locate("sector[level]")
		testing("Z-Level [level] is a sector")
		if(istype(data, /obj/effect/overmapinfo/ship))							//First we'll check for ships, because they can occupy multiplie levels
			testing("Sector is a ship with tag [data.tag]!")
			var/obj/effect/overmapobj/ship/found_ship = locate("ship_[data.sectorname]")
			if(found_ship)													//If there is a ship with such a name...
				testing("Ship \"[data.sectorname]\" found at [data.mapx],[data.mapy] corresponding to zlevel [level]")
				found_ship.ship_levels += level								//Adding this z-level to the list of the ship's z-levels.
				map_sectors["[level]"] = found_ship
			else
				found_ship = new data.obj_type(data)	//If there is no ship with such name, we will create one.
				found_ship.ship_levels += level
				map_sectors["[level]"] = found_ship
				testing("Ship \"[data.sectorname]\" created \"[data.name]\" at [data.mapx],[data.mapy] corresponding to zlevel [level]")
		else if(istype(data, /obj/effect/overmapinfo/precreated))
			testing("Adding precreated ship! Tag: [data.tag] Name: [data.name] at [data.mapx],[data.mapy] corresponding to z[level]")
			//map_sectors["[level]"] = new data.obj_type(data)
			cached_spacepre["[data.name]"] = data
		else if (data)
			testing("Sector is a normal sector")
			testing("Located sector \"[data.name]\" at [data.mapx],[data.mapy] corresponding to zlevel [level]")
			map_sectors["[level]"] = new data.obj_type(data)

	for(var/obj/effect/overmapobj/ship/S in world)
		S.update_spaceturfs()

	for(var/x in 1 to 3)
		load_prepared_sector("Meteor Shower", "MeteorShower[x]")

	callHook("customOvermap", list(overmap_controller))

	//to enable debugging of map_sectors
	map_sectors_reference = list() //just in case
	map_sectors_reference = map_sectors

	for(var/obj/machinery/computer/helm/H in machines)
		H.reinit()

	return 1
