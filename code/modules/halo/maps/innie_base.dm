

/////////
//AREAS//
/////////


//engineering
/area/asteroid_base/tcomms
	name = "\improper Telecommunications Server Room"
	icon_state = "tcomsatcham"

/area/asteroid_base/engine
	name = "\improper Base Power Generators"
	icon_state = "engine"

/area/asteroid_base/atmos
	name = "\improper Atmospherics Processing"
	icon_state = "atmos"

/area/asteroid_base/storage_atmos
	name = "\improper Atmospherics Storage"
	icon_state = "atmos_storage"

/area/asteroid_base/storage_eng
	name = "\improper Atmospherics Storage"
	icon_state = "engineering_storage"


//civilian
/area/asteroid_base/west_dorms
	name = "\improper Dormitories"
	icon_state = "Sleep"

/area/asteroid_base/east_dorms
	name = "\improper Dormitories"
	icon_state = "Sleep"

/area/asteroid_base/mess_hall
	name = "\improper Cafeteria"
	icon_state = "cafeteria"

/area/asteroid_base/kitchen
	name = "\improper Kitchen"
	icon_state = "kitchen"

/area/asteroid_base/medbay
	name = "\improper Medbay"
	icon_state = "medbay"

/area/asteroid_base/storage_medbay
	name = "\improper Medbay Storage"
	icon_state = "medbay2"


//misc
/area/asteroid_base/storage_primary
	name = "\improper Primary Storage"
	icon_state = "primarystorage"

/area/asteroid_base/armoury_1
	name = "\improper Armoury 1"
	icon_state = "armory"

/area/asteroid_base/armoury_2
	name = "\improper Armoury 2"
	icon_state = "armory"

/area/asteroid_base/armoury_3
	name = "\improper Armoury 3"
	icon_state = "armory"

/area/asteroid_base/armoury_4
	name = "\improper Armoury 4"
	icon_state = "armory"

/area/asteroid_base/vault
	name = "\improper Secure Storage Vault"
	icon_state = "firingrange"


//hallways
/area/asteroid_base/central_hallway_1
	name = "\improper Main Hallway Deck 1"
	icon_state = "hallC1"


//hangars airlocks
/area/asteroid_base/north_airlock_1
	name = "\improper North Airlock Deck 1"
	icon_state = "eva"

/area/asteroid_base/south_airlock_1
	name = "\improper South Airlock Deck 1"
	icon_state = "eva"


/////////////////////
//TELECOMMS PRESETS//
/////////////////////
//todo: check for the actual define and the headets used


/obj/machinery/telecomms/hub/preset_innie
	id = "Hub"
	network = "innie_base"
	autolinkers = list("hub_innie","broadcaster_innie","receiver_innie",\
	"processor_innie_private","processor_innie_public",\
	"server_innie_private","server_innie_public",\
	)

/obj/machinery/telecomms/receiver/preset_innie
	id = "Public Comms Receiver"
	network = "innie_base"
	autolinkers = list("receiver_innie")
	freq_listening = list(SYND_FREQ)

	//Common and other radio frequencies for people to freely use
	New()
		for(var/i = PUBLIC_LOW_FREQ, i < PUBLIC_HIGH_FREQ, i += 2)
			freq_listening |= i
		..()

/obj/machinery/telecomms/bus/preset_innie_private
	id = "Encrypted Comms Bus"
	network = "innie_base"
	freq_listening = list(SYND_FREQ)
	autolinkers = list("processor_innie_private","server_innie_private")

/obj/machinery/telecomms/bus/preset_innie_public
	id = "Public Comms Bus"
	network = "innie_base"
	freq_listening = list()
	autolinkers = list("processor_innie_public","server_innie_public")

/obj/machinery/telecomms/bus/preset_innie_public/New()
	for(var/i = PUBLIC_LOW_FREQ, i < PUBLIC_HIGH_FREQ, i += 2)
		freq_listening |= i
	..()

/obj/machinery/telecomms/processor/preset_innie_private
	id = "Encrypted Comms Processor"
	network = "innie_base"
	autolinkers = list("processor_innie_private")

/obj/machinery/telecomms/processor/preset_innie_public
	id = "Public Comms Processor"
	network = "innie_base"
	autolinkers = list("processor_innie_public")

/obj/machinery/telecomms/server/preset_innie_private
	id = "Encrypted Comms Server"
	network = "innie_base"
	freq_listening = list(SYND_FREQ)
	autolinkers = list("server_innie_private")

/obj/machinery/telecomms/server/preset_innie_public
	id = "Public Comms Server"
	network = "innie_base"
	freq_listening = list()
	autolinkers = list("server_innie_public")

/obj/machinery/telecomms/server/preset_innie_public/New()
	for(var/i = PUBLIC_LOW_FREQ, i < PUBLIC_HIGH_FREQ, i += 2)
		freq_listening |= i
	..()

/obj/machinery/telecomms/broadcaster/preset_innie
	id = "Broadcaster"
	network = "innie_base"
	autolinkers = list("broadcaster_innie")


///////////////////
//TELECOMMS COMPS//
///////////////////


/obj/machinery/computer/telecomms/traffic/innie
	network = "innie_base"
	req_access = list(access_innie_boss)

/obj/machinery/computer/telecomms/monitor/innie
	network = "innie_base"
	req_access = list(access_innie_boss)

/obj/machinery/computer/telecomms/server/innie
	network = "innie_base"
	req_access = list(access_innie)
