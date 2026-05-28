/datum/job/roguetown/lost_grenzel
	title = "Lost Grenzel"
	flag = BANDIT
	department_flag = ANTAGONIST
	faction = "Station"
	total_positions = 0
	spawn_positions = 0
	antag_job = TRUE
	
	tutorial = "Long ago you did a crime worthy of your bounty being hung on the wall outside of the local inn. You now live with your fellow lost grenzels in the bog, and generally get up to no good."

	outfit = null
	outfit_female = null

	obsfuscated_job = TRUE

	display_order = JDO_BANDIT
	announce_latejoin = FALSE
	min_pq = 25
	max_pq = null
	round_contrib_points = null

	advclass_cat_rolls = list(CTAG_BANDIT = 20)
	PQ_boost_divider = 10

	wanderer_examine = TRUE
	advjob_examine = TRUE
	always_show_on_latechoices = FALSE
	job_reopens_slots_on_death = FALSE
	job_traits = list(TRAIT_SELF_SUSTENANCE, TRAIT_STEELHEARTED)
	vice_restrictions = list(/datum/charflaw/noeyer, /datum/charflaw/noeyel, /datum/charflaw/mute, /datum/charflaw/limbloss/arm_r, /datum/charflaw/limbloss/arm_l)
	same_job_respawn_delay = 30 MINUTES
	cmode_music = 'sound/music/cmode/antag/combat_deadlyshadows.ogg'
	job_subclasses = list(
		/datum/advclass/brigand,
		/datum/advclass/hedgealchemist,
		/datum/advclass/hedgeknight,
		/datum/advclass/hedgemage,
		/datum/advclass/iconoclast,
		/datum/advclass/knave,
		/datum/advclass/sellsword,
		/datum/advclass/twilight_afreet
	)

/datum/job/roguetown/lost_grenzel/after_spawn(mob/living/L, mob/M, latejoin = TRUE)
	..()
	if(L)
		var/mob/living/carbon/human/H = L
		if(!H.mind)
			return
		H.ambushable = FALSE

/datum/outfit/job/roguetown/lost_grenzel/pre_equip(mob/living/carbon/human/H)
	. = ..()
	H.verbs |= /mob/proc/haltyell_exhausting

/datum/outfit/job/roguetown/lost_grenzel/post_equip(mob/living/carbon/human/H)
	..()
	if(H.mind)
		var/datum/antagonist/new_antag = new /datum/antagonist/bandit()
		H.mind.add_antag_datum(new_antag)
		H.grant_language(/datum/language/thievescant)
		addtimer(CALLBACK(H, TYPE_PROC_REF(/mob/living/carbon/human, choose_name_popup), "BANDIT"), 5 SECONDS)
		var/wanted = list("I am a notorious criminal", "I am a nobody")
		var/wanted_choice = input("Are you a known criminal?") as anything in wanted
		switch(wanted_choice)
			if("I am a notorious criminal") //Extra challenge for those who want it
				bandit_select_bounty(H)
				ADD_TRAIT(H, TRAIT_KNOWNCRIMINAL, TRAIT_GENERIC)
			if("I am a nobody") //Nothing ever happens
				return

/datum/round_event_control/antagonist/migrant_wave/lost_grenzel
	name = "Lost Grenzel Migration"
	typepath = /datum/round_event/migrant_wave/lost_grenzel
	wave_type = /datum/migrant_wave/bandit
	max_occurrences = 2
	weight = 0
	earliest_start = 5 MINUTES
	min_players = 30
	tags = list(
		TAG_COMBAT,
		TAG_VILLIAN,
	)

/datum/round_event_control/antagonist/migrant_wave/lost_grenzel/canSpawnEvent(players_amt, gamemode, fake_check)
	if(SSmapping.config.map_name != "Desert Town")
		return FALSE
	if(!istype(SSgamemode.current_storyteller, /datum/storyteller/astrata))
		return FALSE
	return ..()

/datum/round_event_control/antagonist/migrant_wave/lost_grenzel/preRunEvent()
	if(is_storyteller_soft_antag_blocked())
		return EVENT_CANT_RUN
	return ..()

/datum/round_event/migrant_wave/lost_grenzel/start()
	var/datum/job/lg_job = SSjob.GetJob("Lost Grenzel")
	var/lg_maxcap = max(SSgamemode.story_antag_slot_cap(/datum/antagonist/bandit), lg_job.total_positions)
	lg_job.total_positions = min(lg_job.total_positions + 4, lg_maxcap)
	lg_job.spawn_positions = min(lg_job.spawn_positions + 4, lg_maxcap)
	if(lg_job.total_positions < lg_maxcap)
		SSmapping.retainer.bandit_goal += 1 * rand(200, 400)
		SSrole_class_handler.bandits_in_round = TRUE
		lg_job.always_show_on_latechoices = TRUE
		for(var/mob/dead/new_player/player as anything in GLOB.new_player_list)
			if(!player.client)
				continue
			to_chat(player, span_danger("Astrata calls for justice! The degenerates who dared to deny her right to rule the Pantheon must be subdued!"))