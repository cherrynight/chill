/datum/card_table_session/proc/set_game(new_game, mob/user)
	if(stage != CARD_TABLE_STAGE_LOBBY)
		return FALSE
	var/datum/card_table_player/requester = player_for_user(user)
	if(!requester || player_index(requester) != 1)
		return FALSE
	if(new_game != CARD_TABLE_GAME_FOOL && new_game != CARD_TABLE_GAME_BLACKJACK && new_game != CARD_TABLE_GAME_POKER && new_game != CARD_TABLE_GAME_SOLITAIRE)
		return FALSE
	if(players.len > max_players_for_game(new_game))
		to_chat(user, span_warning("За столом слишком много игроков для этой игры."))
		return FALSE
	game_type = new_game
	if(game_type == CARD_TABLE_GAME_BLACKJACK || game_type == CARD_TABLE_GAME_POKER)
		if(!dealer_index && players.len)
			dealer_index = 1
	else
		dealer_index = 0
	current_index = 1
	defender_index = 2
	dealer_rounds = 0
	message = "[card_table_display_name(user)] выбирает игру: [game_label()]."
	return TRUE

/datum/card_table_session/proc/set_fool_variant(new_variant, mob/user)
	if(stage != CARD_TABLE_STAGE_LOBBY || game_type != CARD_TABLE_GAME_FOOL)
		return FALSE
	var/datum/card_table_player/requester = player_for_user(user)
	if(!requester || player_index(requester) != 1)
		return FALSE
	if(new_variant != CARD_TABLE_FOOL_CLASSIC && new_variant != CARD_TABLE_FOOL_THROW_IN && new_variant != CARD_TABLE_FOOL_TRANSFER && new_variant != CARD_TABLE_FOOL_THROW_TRANSFER)
		return FALSE
	fool_variant = new_variant
	message = "[card_table_display_name(user)] выбирает вариант: [fool_variant_label()]."
	return TRUE

/datum/card_table_session/proc/set_poker_variant(new_variant, mob/user)
	if(stage != CARD_TABLE_STAGE_LOBBY || game_type != CARD_TABLE_GAME_POKER)
		return FALSE
	var/datum/card_table_player/requester = player_for_user(user)
	if(!requester || player_index(requester) != 1)
		return FALSE
	if(new_variant != CARD_TABLE_POKER_DRAW && new_variant != CARD_TABLE_POKER_TEXAS && new_variant != CARD_TABLE_POKER_OMAHA && new_variant != CARD_TABLE_POKER_STUD)
		return FALSE
	poker_variant = new_variant
	message = "[card_table_display_name(user)] выбирает вариант: [poker_variant_label()]."
	return TRUE

/datum/card_table_session/proc/set_blackjack_variant(new_variant, mob/user)
	if(stage != CARD_TABLE_STAGE_LOBBY || game_type != CARD_TABLE_GAME_BLACKJACK)
		return FALSE
	var/datum/card_table_player/requester = player_for_user(user)
	if(!requester || player_index(requester) != 1)
		return FALSE
	if(new_variant != CARD_TABLE_BLACKJACK_GRON && new_variant != CARD_TABLE_BLACKJACK_VALORIA && new_variant != CARD_TABLE_BLACKJACK_AZURE && new_variant != CARD_TABLE_BLACKJACK_GRENZELHOFT && new_variant != CARD_TABLE_BLACKJACK_KAZENGUN)
		return FALSE
	blackjack_variant = new_variant
	message = "[card_table_display_name(user)] выбирает вариант: [blackjack_variant_label()]."
	return TRUE

/datum/card_table_session/proc/set_dealer_rotation(rotates, mob/user)
	if(stage != CARD_TABLE_STAGE_LOBBY || (game_type != CARD_TABLE_GAME_BLACKJACK && game_type != CARD_TABLE_GAME_POKER))
		return FALSE
	var/datum/card_table_player/requester = player_for_user(user)
	if(!requester || player_index(requester) != 1)
		return FALSE
	dealer_rotates = text2num("[rotates]") ? TRUE : FALSE
	if(!dealer_rotates && players.len)
		dealer_index = 1
	else if(!dealer_index && players.len)
		dealer_index = 1
	message = "[card_table_display_name(user)] выбирает режим: [dealer_rotation_label()]."
	return TRUE

/datum/card_table_session/proc/dealer_player() as /datum/card_table_player
	if(dealer_index < 1 || dealer_index > players.len)
		return null
	return players[dealer_index]

/datum/card_table_session/proc/join_player(mob/user)
	if(!user || !user.ckey || stage != CARD_TABLE_STAGE_LOBBY)
		return FALSE
	if(player_for_user(user))
		return FALSE
	if(players.len >= max_players())
		to_chat(user, span_warning("There are no free player seats."))
		return FALSE
	observers -= user.ckey
	var/datum/card_table_player/player = new()
	player.ckey = user.ckey
	player.name = card_table_display_name(user)
	players += player
	if(!dealer_index && (game_type == CARD_TABLE_GAME_BLACKJACK || game_type == CARD_TABLE_GAME_POKER))
		dealer_index = players.len
	message = "[player.name] занимает место игрока."
	return TRUE

/datum/card_table_session/proc/join_observer(mob/user)
	if(!user || !user.ckey)
		return FALSE
	release_user(user, TRUE)
	if(!(user.ckey in observers))
		observers += user.ckey
	message = "[card_table_display_name(user)] watches the table."
	return TRUE

/datum/card_table_session/proc/release_user(mob/user, silent = FALSE)
	if(!user || !user.ckey)
		return FALSE
	var/changed = FALSE
	for(var/i = players.len, i >= 1, i--)
		var/datum/card_table_player/player = players[i]
		if(player.ckey == user.ckey)
			if(i == dealer_index)
				dealer_index = 0
			else if(i < dealer_index)
				dealer_index--
			players.Cut(i, i + 1)
			changed = TRUE
	if(user.ckey in observers)
		observers -= user.ckey
		changed = TRUE
	if(changed)
		if(!silent)
			message = "[card_table_display_name(user)] leaves the table."
		if(stage != CARD_TABLE_STAGE_LOBBY && players.len < min_players())
			stage = CARD_TABLE_STAGE_FINISHED
			message = "The game ends because there are not enough players."
		clamp_turns()
	return changed

/datum/card_table_session/proc/release_ckey(ckey, reason)
	if(!ckey)
		return FALSE
	var/name = ckey
	var/changed = FALSE
	for(var/i = players.len, i >= 1, i--)
		var/datum/card_table_player/player = players[i]
		if(player.ckey == ckey)
			name = player.name
			if(i == dealer_index)
				dealer_index = 0
			else if(i < dealer_index)
				dealer_index--
			players.Cut(i, i + 1)
			changed = TRUE
	if(ckey in observers)
		observers -= ckey
		changed = TRUE
	if(changed)
		var/reason_text = reason ? " ([reason])" : ""
		message = "[name] leaves the table[reason_text]."
		if(stage != CARD_TABLE_STAGE_LOBBY && players.len < min_players())
			stage = CARD_TABLE_STAGE_FINISHED
			message = "The game ends because there are not enough players."
		clamp_turns()
	return changed

/datum/card_table_session/proc/check_player_ranges()
	if(!owner)
		return
	for(var/datum/card_table_player/player in players.Copy())
		var/mob/M = card_table_find_mob_by_ckey(player.ckey)
		if(!M || get_dist(M, owner) > CARD_TABLE_LEAVE_RANGE)
			release_ckey(player.ckey, "too far")

/datum/card_table_session/proc/clamp_turns()
	if(!players.len)
		current_index = 1
		defender_index = 2
		dealer_index = 0
		return
	if(current_index < 1)
		current_index = 1
	if(current_index > players.len)
		current_index = players.len
	if(defender_index < 1)
		defender_index = min(players.len, 2)
	if(defender_index > players.len)
		defender_index = min(players.len, 2)
	if(dealer_index > players.len)
		dealer_index = 0

/datum/card_table_session/proc/advance_dealer()
	if(!players.len)
		dealer_index = 0
		return
	if(dealer_index < 1 || dealer_index > players.len)
		dealer_index = 1
		return
	dealer_index++
	if(dealer_index > players.len)
		dealer_index = 1

/datum/card_table_session/proc/draw_one()
	if(!deck.len)
		return null
	var/list/card = deck[1]
	deck.Cut(1, 2)
	return card

/datum/card_table_session/proc/deal_to(datum/card_table_player/player, amount)
	if(!player)
		return
	for(var/i = 1, i <= amount, i++)
		var/list/card = draw_one()
		if(!card)
			return
		player.hand += list(card)
