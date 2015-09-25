var/datum/antagonist/innie/innies
//
/datum/antagonist/innie
	id = MODE_INNIE
	role_text = "Insurrectionist"
	role_text_plural = "Insurrectionists"
	restricted_jobs = list("Cyborg")
	protected_jobs = list("Military Police", "Warden", "Detective", "ONI Agent", "Chief Security Officer", "Captain")
	flags = ANTAG_SUSPICIOUS | ANTAG_RANDSPAWN | ANTAG_VOTABLE
	max_antags = 5 // No upper limit.

	var/list/innie_uniforms = list(
		/obj/item/clothing/under/color/red,
		/obj/item/clothing/under/color/blue,
		/obj/item/clothing/under/lightblue,
		/obj/item/clothing/under/color/yellow,
		/obj/item/clothing/under/lightbrown,
		/obj/item/clothing/under/color/orange,
		)

	var/list/innie_shoes = list(
		/obj/item/clothing/shoes/jackboots,
		/obj/item/clothing/shoes/workboots,
		/obj/item/clothing/shoes/marine
		)

	var/list/innie_glasses = list(
//		/obj/item/clothing/glasses/thermal //not sure if the innies should have thesse or not
		)

	var/list/innie_helmets = list(
		/obj/item/clothing/head/helmet/marine
		)

	var/list/innie_suits = list(
		/obj/item/clothing/suit/armor/marine,
		/obj/item/clothing/suit/armor,
		)

	var/list/innie_guns = list(
		/obj/item/weapon/gun/projectile/magnum,
		/obj/item/weapon/gun/projectile/automatic/assault,
		)

	var/list/innie_holster = list(
		/obj/item/clothing/accessory/holster/armpit,
		/obj/item/clothing/accessory/holster/waist,
		/obj/item/clothing/accessory/holster/hip
		)


/datum/antagonist/innie/New()
	..()
	innies = src

/datum/antagonist/innie/equip(var/mob/living/carbon/human/player)

	var/new_shoes =   pick(innie_shoes)
	var/new_uniform = pick(innie_uniforms)
	var/new_glasses = pick(innie_glasses)
	var/new_helmet =  pick(innie_helmets)
	var/new_suit =    pick(innie_suits)

	player.equip_to_slot_or_del(new new_shoes(player),slot_shoes)
	player.equip_to_slot_or_del(new new_uniform(player),slot_w_uniform)
	player.equip_to_slot_or_del(new new_glasses(player),slot_glasses)
	player.equip_to_slot_or_del(new new_helmet(player),slot_head)
	player.equip_to_slot_or_del(new new_suit(player),slot_wear_suit)
	player.update_icons()
	equip_weapons()

/datum/antagonist/innie/proc/equip_weapons(var/mob/living/carbon/human/player)
	var/new_gun = pick(innie_guns)
	var/innie_special = /obj/item/weapon/gun/energy/railrifle/innie

	player.put_in_any_hand_if_possible(new_gun)

	if(prob(1))
		player.put_in_any_hand_if_possible(innie_special)
