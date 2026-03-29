/proc/familytree_is_clergy(datum/job/job)
	if(!job)
		return FALSE
	return SSfamilytree.is_job_of_type(job, SSfamilytree.clergy_job_types)

/datum/controller/subsystem/familytree
	var/list/clergy_job_types = list(
		/datum/job/roguetown/priest,
		/datum/job/roguetown/templar,
		/datum/job/roguetown/monk,
		/datum/job/roguetown/sexton,
		/datum/job/roguetown/keeper,
		/datum/job/roguetown/martyr,
		/datum/job/roguetown/druid,
	)

	var/list/high_clergy_job_types = list(
		/datum/job/roguetown/priest,
	)

	var/list/mid_clergy_job_types = list(
		/datum/job/roguetown/templar,
		/datum/job/roguetown/druid,
	)

#define SOCIAL_RANK_LOW 1
#define SOCIAL_RANK_MID 2
#define SOCIAL_RANK_HIGH 3

/proc/familytree_get_clergy_rank(mob/living/carbon/human/priest)
	var/datum/job/job = SSfamilytree.get_familytree_job(priest)
	if(!job)
		return SOCIAL_RANK_LOW

	if(SSfamilytree.is_job_of_type(job, SSfamilytree.high_clergy_job_types))
		return SOCIAL_RANK_HIGH
	if(SSfamilytree.is_job_of_type(job, SSfamilytree.mid_clergy_job_types))
		return SOCIAL_RANK_MID

	return SOCIAL_RANK_LOW

/proc/familytree_get_social_rank(mob/living/carbon/human/H)
	if(familytree_get_estate(H) == ESTATE_NOBLE)
		return SOCIAL_RANK_HIGH

	var/tier = familytree_get_role_tier(H)
	if(tier == ROLE_TIER_LOW)
		return SOCIAL_RANK_LOW

	return SOCIAL_RANK_MID

/proc/familytree_ritual_adopt(mob/living/carbon/human/parent, mob/living/carbon/human/child)
	if(!parent || !child)
		return FALSE
	if(!parent.family_datum)
		return FALSE
	if(child.family_datum == parent.family_datum)
		return FALSE

	var/datum/family_member/parent_member = parent.family_member_datum
	if(!parent_member)
		return FALSE

	parent.family_datum.AddToFamily(child, parent_member, null, TRUE)
	return TRUE

/proc/familytree_vampire_bind(mob/living/carbon/human/sire, mob/living/carbon/human/progeny)
	if(!sire || !progeny)
		return FALSE

	if(!sire.family_datum)
		var/datum/heritage/new_family = new /datum/heritage(sire, null)
		sire.family_datum = new_family
		SSfamilytree.families += new_family

	sire.family_datum.AddToFamily(progeny, sire.family_member_datum, null, TRUE)
	return TRUE
