


/////////////////////
//TELECOMMS PRESETS//
/////////////////////
//todo: check for the actual define and the headets used


/obj/machinery/telecomms/hub/preset_innie
	id = "Hub"
	network = "innie_base"
	autolinkers = list("hub_innie","broadcaster_innie","receiver_innie",\
	"processor_innie_private","processor_innie_public",\
	"server_innie_private","server_innie_private",\
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
	autolinkers = list("processor_innie_private")

/obj/machinery/telecomms/bus/preset_innie_public
	id = "Public Comms Bus"
	network = "innie_base"
	freq_listening = list()
	autolinkers = list("processor_innie_public")

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
