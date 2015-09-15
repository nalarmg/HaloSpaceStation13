/datum/species/elite
	name = "Elite"
	name_plural = "Elites"
	icobase = 'code/modules/halo/icons/elite.dmi'
	deform = 'icons/mob/human_races/r_def_vox.dmi'
	default_language = "Sol Common"
	language = "Galactic Common"
	unarmed_types = list(/datum/unarmed_attack/stomp, /datum/unarmed_attack/kick,  /datum/unarmed_attack/claws/strong, /datum/unarmed_attack/bite/strong)
	rarity_value = 2
	blurb = "The Sangheili are one of the Covenant's founding species, present when the Writ of Union was drawn up in 852 BCE.\
	Most Sangheili followed the San 'Shyuum without hesitation after the decleration of war on Humanity. \
	However some veterans are beginning to question this, with some (OOC NOTE: VERY VERY FEW) even considering humans as equals."

	speech_sounds = list('sound/voice/shriek1.ogg')
	speech_chance = 20


	cold_level_1 = 80
	cold_level_2 = 50
	cold_level_3 = 0

	eyes = "vox_eyes_s"

	siemens_coefficient = 0.2

	flags = CAN_JOIN | HAS_EYE_COLOR | IS_ELITE
	spawn_flags = IS_RESTRICTED

	blood_color = "#4b0082"
	flesh_color = "#808080"

	inherent_verbs = list(
		/mob/living/carbon/human/proc/leap
		)

	has_organ = list(
		"heart" =    /obj/item/organ/heart,
		"second heart" = /obj/item/organ/secondary_heart,
		"lungs" =    /obj/item/organ/lungs,
		"liver" =    /obj/item/organ/liver,
		"kidneys" =  /obj/item/organ/kidneys,
		"brain" =    /obj/item/organ/brain,
		"eyes" =     /obj/item/organ/eyes
		)

/datum/species/elite/get_random_name(var/gender)
	var/datum/language/species_language = all_languages[default_language]
	return species_language.get_random_name(gender)
