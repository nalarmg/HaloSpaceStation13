/datum/controller/process/overmap/setup()
	name = "overmap controller"

	if(!overmap_controller && config.use_overmap)
		overmap_controller = new

/datum/controller/process/overmap/doWork()
	overmap_controller.process()
