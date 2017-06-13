/var/list/lighting_update_lights = list()
/var/list/lighting_update_overlays = list()

/area/var/lighting_use_dynamic = 1

// duplicates lots of code, but this proc needs to be as fast as possible.
/proc/create_lighting_overlays(zlevel = 0)
	set background = 1
	var/area/A
	if(zlevel == 0) // populate all zlevels
		for(var/turf/T in world)
			if(T.dynamic_lighting)
				A = T.loc
				if(A.lighting_use_dynamic)
					var/atom/movable/lighting_overlay/O = PoolOrNew(/atom/movable/lighting_overlay, T)
					T.lighting_overlay = O

	else
		for(var/x = 1; x <= world.maxx; x++)
			for(var/y = 1; y <= world.maxy; y++)
				var/turf/T = locate(x, y, zlevel)
				if(T.dynamic_lighting)
					A = T.loc
					if(A.lighting_use_dynamic)
						var/atom/movable/lighting_overlay/O = PoolOrNew(/atom/movable/lighting_overlay, T)
						T.lighting_overlay = O

var/ambient_red = 0
var/ambient_green = 0
var/ambient_blue = 0
/proc/set_ambient_light(var/new_ambient_red, var/new_ambient_green, var/new_ambient_blue)
	set background = 1
	for(var/atom/movable/lighting_overlay/O in world)
		O.lum_r += new_ambient_red - ambient_red
		O.lum_g += new_ambient_green - ambient_green
		O.lum_b += new_ambient_blue - ambient_blue

		O.update_overlay()

	ambient_red = new_ambient_red
	ambient_green = new_ambient_green
	ambient_blue = new_ambient_blue
