/datum/job/roguetown/bathmaster
	title = "Bathmaster"
	flag = BATHMASTER
	department_flag = BURGHERS
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	f_title = "Bathmatron"
	forbidden_races = list(RACES_DESPISED)
	tutorial = "You are renting out the bathhouse in a joint operation with the Innkeep. You provide security for the bathwenches and help them to find work--when you're not being a trouble-making rake that others suffer to tolerate."
	allowed_sexes = list(MALE, FEMALE)
	outfit = /datum/outfit/job/roguetown/bathmaster
	display_order = JDO_BATHMASTER
	give_bank_account = 20
	min_pq = 3
	max_pq = null
	bypass_lastclass = TRUE
	round_contrib_points = 3
	cmode_music = 'sound/music/cmode/nobility/combat_spymaster.ogg'

	job_traits = list(TRAIT_SEEPRICES, 
		TRAIT_CICERONE, 
		TRAIT_NUTCRACKER,
		TRAIT_GOODLOVER, 
		TRAIT_HOMESTEAD_EXPERT)

	advclass_cat_rolls = list(CTAG_BATHMOM = 2)
	job_subclasses = list(
		/datum/advclass/bathmaster
	)


/datum/advclass/bathmaster
	name = "Bathmaster"
	tutorial = "You are renting out the bathhouse in a joint operation with the Innkeep. You provide security for the bathwenches and help them to find work--when you're not being a trouble-making rake that others suffer to tolerate."
	outfit = /datum/outfit/job/roguetown/bathmaster/basic
	category_tags = list(CTAG_BATHMOM)
	subclass_languages = list(/datum/language/thievescant)
	subclass_stats = list(
		STATKEY_WIL = 2,
		STATKEY_STR = 1,
		STATKEY_CON = 1,
		STATKEY_INT = -1
	)
	subclass_skills = list(
		/datum/skill/combat/wrestling = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/unarmed = SKILL_LEVEL_EXPERT,
		/datum/skill/combat/whipsflails = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/reading = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/sneaking = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/stealing = SKILL_LEVEL_EXPERT,
		/datum/skill/misc/lockpicking = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/climbing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/medicine = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/riding = SKILL_LEVEL_APPRENTICE,
		/datum/skill/misc/swimming = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/athletics = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/combat/knives = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/craft/cooking = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_NOVICE,
	)

/datum/outfit/job/roguetown/bathmaster/basic/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_blindness(-3)
	head = /obj/item/lockpick/goldpin/silver
	shoes = /obj/item/clothing/shoes/roguetown/boots
	belt = /obj/item/storage/belt/rogue/leather/black
	shirt = /obj/item/clothing/suit/roguetown/shirt/tunic/purple
	wrists = /obj/item/storage/keyring/bathmaster
	neck = /obj/item/storage/belt/rogue/pouch/merchant/coins
	pants = /obj/item/clothing/under/roguetown/trou/leather
	beltl = /obj/item/rogueweapon/whip

	backl = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/reagent_containers/food/snacks/grown/rogue/swampweeddry = 2,
		/obj/item/reagent_containers/powder/moondust = 2,
		/obj/item/reagent_containers/powder/spice = 1,
		/obj/item/mini_flagpole/bathhouse,
		)

	if(should_wear_masc_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/armor/leather/vest/sailor/nightman
		H.dna.species.soundpack_m = new /datum/voicepack/male/zeth()
	else if(should_wear_femme_clothes(H))
		armor = /obj/item/clothing/suit/roguetown/armor/armordress/alt
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/massage)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/takeapprentice)

// TA DESERT TOWN EDIT BEGIN
/datum/job/roguetown/bathmaster/after_spawn(mob/living/H, mob/M, latejoin)
	..()
	var/client/player = H?.client
	if(!player && M)
		player = M.client
	if(player?.prefs)
		if(SSmapping.config.map_name == "Desert Town")
			if(!istype(player.prefs.virtue_origin, /datum/virtue/origin/raneshen) && !istype(player.prefs.virtue_origin, /datum/virtue/origin/naledi) && !istype(player.prefs.virtue_origin, /datum/virtue/origin/zybantian))
				var/list/new_origins = list("Raneshen" = /datum/virtue/origin/raneshen, 
				"Naledi" = /datum/virtue/origin/naledi,
				"Zybantu" = /datum/virtue/origin/zybantian)
				var/new_origin
				var/choice = input(player, "Your origins are not compatible with the Sultanat. Where do you hail from?", "ANCESTRY") as anything in new_origins
				if(choice)
					new_origin = new_origins[choice]
				else
					to_chat(player, span_notice("No choice detected. Picking a random compatible origin."))
					new_origin = pick(/datum/virtue/origin/raneshen, /datum/virtue/origin/naledi, /datum/virtue/origin/zybantian)
				var/datum/virtue/origin/applied_origin = new new_origin()
				player.prefs.virtue_origin = applied_origin
				apply_virtue(H, applied_origin)
// TA DESERT TOWN EDIT END