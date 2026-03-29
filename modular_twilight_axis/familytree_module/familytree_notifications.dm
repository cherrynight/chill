/datum/controller/subsystem/familytree/proc/notify_family_head_departure(mob/living/carbon/human/departed)
	if(!departed?.family_datum)
		return
	var/datum/heritage/house = departed.family_datum
	if(!house.founder?.person)
		return
	var/mob/living/carbon/human/head = house.founder.person
	if(head == departed)
		return
	if(!head.client)
		return

	var/datum/family_member/departed_member = house.GetFamilyMember(departed)
	if(!departed_member)
		return

	var/relation = head.family_member_datum?.GetRelationshipTo(departed_member)
	if(!relation)
		relation = "родственник"

	to_chat(head, span_warning("Ваш [relation] [departed.real_name] покинул эти земли. Вы чувствуете тревогу."))
	ftlog("NOTIFY: [head.real_name] notified about [departed.real_name] departure ([relation])")
