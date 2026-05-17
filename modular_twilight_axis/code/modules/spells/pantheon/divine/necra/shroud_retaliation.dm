#define TRANQUILITY_SHROUD_RETALIATION_FIRE_STACKS 6
#define TRANQUILITY_SHROUD_RETALIATION_DURATION 5 SECONDS

/datum/status_effect/tranquility_shroud/proc/on_shroud_broken_by_undead(mob/living/undead_source)
	if(retaliation_used)
		return
	if(shroud_mode != TRANQUILITY_SHROUD_MODE_RESTLESS || shroud_tier < CLERIC_T1)
		return
	if(QDELETED(undead_source) || undead_source.stat == DEAD)
		return
	if(!isliving(undead_source))
		return
	retaliation_used = TRUE
	var/turf/undead_turf = get_turf(undead_source)
	playsound(undead_turf, 'sound/magic/whiteflame.ogg', 60, TRUE)
	new /obj/effect/temp_visual/explosion(undead_turf)
	undead_source.Stun(TRANQUILITY_SHROUD_RETALIATION_DURATION)
	undead_source.adjust_fire_stacks(TRANQUILITY_SHROUD_RETALIATION_FIRE_STACKS, /datum/status_effect/fire_handler/fire_stacks/divine)
	undead_source.ignite_mob()
	if(owner && !QDELETED(owner))
		to_chat(owner, span_notice("Necra's ward flashes white, stunning and burning the undead assailant."))
		owner.visible_message(span_warning("[owner]'s pale ward bursts into white flame around [undead_source]!"))
