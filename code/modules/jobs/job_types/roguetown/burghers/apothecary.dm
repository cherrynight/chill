/datum/job/roguetown/apothecary
	title = "Apothecary"
	flag = APOTHECARY
	department_flag = BURGHERS
	faction = "Station"
	total_positions = 2
	spawn_positions = 2

	forbidden_races = list(RACES_DESPISED)

	tutorial = "You are a fully trained and accomplished physician, well-practiced \
	in the arts of medicine and alchemy. You are quartered within the University of \
	Azuria under the authority of the Head Physician, who has graciously negotiated your \
	access to the heartbeast beneath the University - while you would do well to treat \
	it with caution, it is a source of vital heartsblood. Treat the sick and wounded, \
	gather herbs as is necessary to peddle your potions, and walk with Pestra's light. \
	Woe betide the one who suffers your scalpel."

	outfit = /datum/outfit/job/roguetown/apothecary

	cmode_music = 'sound/music/combat_physician.ogg'

	display_order = JDO_APOTHECARY
	give_bank_account = TRUE

	min_pq = 0
	max_pq = null
	round_contrib_points = 5

	advclass_cat_rolls = list(CTAG_APOTH = 2)
	job_traits = list(TRAIT_MEDICINE_EXPERT, TRAIT_ALCHEMY_EXPERT, TRAIT_NOSTINK, TRAIT_EMPATH)
	job_subclasses = list(
		/datum/advclass/apothecary
	)
	spells = list(/obj/effect/proc_holder/spell/invoked/takeapprentice)

/datum/advclass/apothecary
	name = "Apothecary"
	tutorial = "You are a fully trained and accomplished physician, well-practiced \
	in the arts of medicine and alchemy. You are quartered within the University of \
	Azuria under the authority of the Head Physician, who has graciously negotiated your \
	access to the heartbeast beneath the University - while you would do well to treat \
	it with caution, it is a source of vital heartsblood. Treat the sick and wounded, \
	gather herbs as is necessary to peddle your potions, and walk with Pestra's light. \
	Woe betide the one who suffers your scalpel."
	outfit = /datum/outfit/job/roguetown/apothecary/basic
	category_tags = list(CTAG_APOTH)
	subclass_stats = list(
		STATKEY_INT = 3,
		STATKEY_PER = 2,
		STATKEY_SPD = 1,
	)
	subclass_skills = list(
		/datum/skill/combat/knives = SKILL_LEVEL_APPRENTICE,
		/datum/skill/combat/polearms = SKILL_LEVEL_APPRENTICE, //enhances survival chances.
		/datum/skill/combat/wrestling = SKILL_LEVEL_NOVICE,
		/datum/skill/craft/crafting = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/athletics = SKILL_LEVEL_NOVICE,
		/datum/skill/misc/reading = SKILL_LEVEL_JOURNEYMAN,
		/datum/skill/misc/medicine = SKILL_LEVEL_MASTER,
		/datum/skill/craft/sewing = SKILL_LEVEL_APPRENTICE,
		/datum/skill/craft/alchemy = SKILL_LEVEL_EXPERT,
	)

/datum/outfit/job/roguetown/apothecary/basic/pre_equip(mob/living/carbon/human/H)
	..()
	H.adjust_blindness(-3)
	head = /obj/item/clothing/head/roguetown/roguehood/black
	pants = /obj/item/clothing/under/roguetown/trou/apothecary
	shirt = /obj/item/clothing/suit/roguetown/shirt/apothshirt
	armor = /obj/item/clothing/suit/roguetown/shirt/robe/black
	belt = /obj/item/storage/belt/rogue/leather/rope
	neck = /obj/item/storage/belt/rogue/pouch/coins/poor
	beltl = /obj/item/storage/belt/rogue/surgery_bag/full/physician
	id = /obj/item/scomstone/bad
	r_hand = /obj/item/rogueweapon/woodstaff/
	shoes = /obj/item/clothing/shoes/roguetown/boots/leather
	backr = /obj/item/storage/backpack/rogue/satchel
	backpack_contents = list(
		/obj/item/natural/worms/leech/cheele = 1,
		/obj/item/recipe_book/alchemy = 1,
		/obj/item/clothing/mask/rogue/physician = 1,
		/obj/item/mini_flagpole/apothecary = 1,
	)
	if(H.mind)
		H.mind.AddSpell(new /obj/effect/proc_holder/spell/invoked/diagnose/secular)
	if(H.mind)
		SStreasury.grant_savings(ECONOMIC_UPPER_MIDDLE_CLASS, H)
	if(SSmapping.config.map_name == "Rockhill") //TA_EDIT
		beltr = /obj/item/storage/keyring/apothecaryenigma
	else
		beltr = /obj/item/storage/keyring/apothecary

// TA DESERT TOWN EDIT BEGIN
/datum/job/roguetown/apothecary/after_spawn(mob/living/H, mob/M, latejoin)
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
