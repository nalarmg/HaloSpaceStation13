
//===================================================================================
//Controller to build and update overmap
//===================================================================================

//see code\controllers\Processes\overmap.dm

var/global/datum/controller/process/overmap/overmap_controller
var/global/list/map_sectors = list()		//array of strings w/ all zlevel numbers stored as strings, each string indexes the associated overmap obj for that zlevel
var/global/list/cached_zlevels = list()		//unused and empty zlevels in case they are needed for something

/datum/controller/process/overmap
	name = "overmap controller"
	var/list/map_sectors_reference
	var/list/cached_zlevels_reference
	var/list/moving_levels = list()

	var/obj/effect/overmapobj/protagonist_home
	var/obj/effect/overmapobj/antagonist_home

	var/protagonist_faction = "UNSC"
	var/galaxy_travel_enabled = 0

/datum/controller/process/overmap/doWork()
	//see temporary_sector.dm
	process_temp_sectors()
