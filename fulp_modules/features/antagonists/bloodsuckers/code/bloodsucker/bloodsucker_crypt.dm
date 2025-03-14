/obj/structure/bloodsucker
	///Who owns this structure?
	var/mob/living/owner
	/*
	 *	# Descriptions
	 *
	 *	We use vars to add descriptions to items.
	 *	This way we don't have to make a new /examine for each structure
	 *	And it's easier to edit.
	 */
	var/Ghost_desc
	var/Vamp_desc
	var/Vassal_desc
	var/Hunter_desc

/obj/structure/bloodsucker/examine(mob/user)
	. = ..()
	if(!user.mind && Ghost_desc != "")
		. += span_cult(Ghost_desc)
	if(IS_BLOODSUCKER(user) && Vamp_desc)
		if(!owner)
			. += span_cult("It is unsecured. Click on [src] while in your lair to secure it in place to get its full potential.")
			return
		. += span_cult(Vamp_desc)
	if(IS_VASSAL(user) && Vassal_desc != "")
		. += span_cult(Vassal_desc)
	if(IS_MONSTERHUNTER(user) && Hunter_desc != "")
		. += span_cult(Hunter_desc)

/// This handles bolting down the structure.
/obj/structure/bloodsucker/proc/bolt(mob/user)
	to_chat(user, span_danger("You have secured [src] in place."))
	to_chat(user, span_announce("* Bloodsucker Tip: Examine [src] to understand how it functions!"))
	owner = user

/// This handles unbolting of the structure.
/obj/structure/bloodsucker/proc/unbolt(mob/user)
	to_chat(user, span_danger("You have unsecured [src]."))
	owner = null

/obj/structure/bloodsucker/attackby(obj/item/item, mob/living/user, params)
	/// If a Bloodsucker tries to wrench it in place, yell at them.
	if(item.tool_behaviour == TOOL_WRENCH && !anchored && IS_BLOODSUCKER(user))
		user.playsound_local(null, 'sound/machines/buzz-sigh.ogg', 40, FALSE, pressure_affected = FALSE)
		to_chat(user, span_announce("* Bloodsucker Tip: Examine the Persuasion Rack to understand how it functions!"))
		return
	. = ..()

/obj/structure/bloodsucker/attack_hand(mob/user, list/modifiers)
//	. = ..() // Don't call parent, else they will handle unbuckling.
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	/// Claiming the Rack instead of using it?
	if(istype(bloodsuckerdatum) && !owner)
		if(!bloodsuckerdatum.lair)
			to_chat(user, span_danger("You don't have a lair. Claim a coffin to make that location your lair."))
			return FALSE
		if(bloodsuckerdatum.lair != get_area(src))
			to_chat(user, span_danger("You may only activate this structure in your lair: [bloodsuckerdatum.lair]."))
			return FALSE

		/// Radial menu for securing your Persuasion rack in place.
		to_chat(user, span_notice("Do you wish to secure [src] here?"))
		var/list/secure_options = list(
			"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
			"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no"))
		var/secure_response = show_radial_menu(user, src, secure_options, radius = 36, require_near = TRUE)
		if(!secure_response)
			return FALSE
		switch(secure_response)
			if("Yes")
				user.playsound_local(null, 'sound/items/ratchet.ogg', 70, FALSE, pressure_affected = FALSE)
				bolt(user)
				return FALSE
		return FALSE
	return TRUE

/obj/structure/bloodsucker/AltClick(mob/user)
	. = ..()
	if(user == owner && user.Adjacent(src))
		balloon_alert(user, "unbolt [src]?")
		var/list/unclaim_options = list(
			"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
			"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no")
			)
		var/unclaim_response = show_radial_menu(user, src, unclaim_options, radius = 36, require_near = TRUE)
		switch(unclaim_response)
			if("Yes")
				unbolt(user)
/*
/obj/structure/bloodsucker/bloodaltar
	name = "bloody altar"
	desc = "It is made of marble, lined with basalt, and radiates an unnerving chill that puts your skin on edge."
/obj/structure/bloodsucker/bloodstatue
	name = "bloody countenance"
	desc = "It looks upsettingly familiar..."
/obj/structure/bloodsucker/bloodportrait
	name = "oil portrait"
	desc = "A disturbingly familiar face stares back at you. Those reds don't seem to be painted in oil..."
/obj/structure/bloodsucker/bloodbrazier
	name = "lit brazier"
	desc = "It burns slowly, but doesn't radiate any heat."
/obj/structure/bloodsucker/bloodmirror
	name = "faded mirror"
	desc = "You get the sense that the foggy reflection looking back at you has an alien intelligence to it."
/obj/item/restraints/legcuffs/beartrap/bloodsucker
*/

/obj/structure/bloodsucker/vassalrack
	name = "persuasion rack"
	desc = "If this wasn't meant for torture, then someone has some fairly horrifying hobbies."
	icon = 'fulp_modules/features/antagonists/bloodsuckers/icons/vamp_obj.dmi'
	icon_state = "vassalrack"
	anchored = FALSE
	/// Start dense. Once fixed in place, go non-dense.
	density = TRUE
	can_buckle = TRUE
	buckle_lying = 180
	Ghost_desc = "This is a Vassal rack, which allows Bloodsuckers to thrall crewmembers into loyal minions."
	Vamp_desc = "This is the Vassal rack, which allows you to thrall crewmembers into loyal minions in your service.\n\
		Simply click and hold on a victim, and then drag their sprite on the vassal rack. Right-click on the vassal rack to unbuckle them.\n\
		To convert into a Vassal, repeatedly click on the persuasion rack. The time required scales with the tool in your off hand. This costs Blood to do.\n\
		Once you have Vassals ready, you are able to select a Favorite Vassal;\n\
		Click the Rack as a Vassal is buckled onto it to turn them into your Favorite. This can only be done once, so choose carefully!\n\
		This process costs 150 Blood to do, and will make your Vassal unable to be deconverted, outside of you reaching Final Death."
	Vassal_desc = "This is the vassal rack, which allows your master to thrall crewmembers into their minions.\n\
		Aid your master in bringing their victims here and keeping them secure.\n\
		You can secure victims to the vassal rack by click dragging the victim onto the rack while it is secured."
	Hunter_desc = "This is the vassal rack, which monsters use to brainwash crewmembers into their loyal slaves.\n\
		They usually ensure that victims are handcuffed, to prevent them from running away.\n\
		Their rituals take time, allowing us to disrupt it."
	/// So we can't spam buckle people onto the rack
	var/use_lock = FALSE
	var/mob/buckled
	/// Resets on each new character to be added to the chair. Some effects should lower it...
	var/convert_progress = 3
	/// Mindshielded and Antagonists willingly have to accept you as their Master.
	var/disloyalty_confirm = FALSE
	/// Prevents popup spam.
	var/disloyalty_offered = FALSE

/obj/structure/bloodsucker/vassalrack/deconstruct(disassembled = TRUE)
	. = ..()
	new /obj/item/stack/sheet/iron(src.loc, 4)
	new /obj/item/stack/rods(loc, 4)
	qdel(src)

/obj/structure/bloodsucker/vassalrack/bolt()
	. = ..()
	density = FALSE
	anchored = TRUE

/obj/structure/bloodsucker/vassalrack/unbolt()
	. = ..()
	density = TRUE
	anchored = FALSE

/obj/structure/bloodsucker/vassalrack/MouseDrop_T(atom/movable/movable_atom, mob/user)
	var/mob/living/living_target = movable_atom
	if(!anchored && IS_BLOODSUCKER(user))
		to_chat(user, span_danger("Until this rack is secured in place, it cannot serve its purpose."))
		to_chat(user, span_announce("* Bloodsucker Tip: Examine the Persuasion Rack to understand how it functions!"))
		return
	// Default checks
	if(!isliving(movable_atom) || !living_target.Adjacent(src) || living_target == user || !isliving(user) || use_lock || has_buckled_mobs() || user.incapacitated() || living_target.buckled)
		return
	// Don't buckle Silicon to it please.
	if(issilicon(living_target))
		to_chat(user, span_danger("You realize that this machine cannot be vassalized, therefore it is useless to buckle them."))
		return
	// Good to go - Buckle them!
	use_lock = TRUE
	if(do_mob(user, living_target, 5 SECONDS))
		attach_victim(living_target, user)
	use_lock = FALSE

/// Attempt Release (Owner vs Non Owner)
/obj/structure/bloodsucker/vassalrack/attack_hand_secondary(mob/user, modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	if(!has_buckled_mobs() || !isliving(user) || use_lock)
		return
	var/mob/living/carbon/buckled_carbons = pick(buckled_mobs)
	if(buckled_carbons)
		if(user == owner)
			unbuckle_mob(buckled_carbons)
		else
			user_unbuckle_mob(buckled_carbons, user)

/// Attempt Buckle
/obj/structure/bloodsucker/vassalrack/proc/attach_victim(mob/living/target, mob/living/user)
	// Standard Buckle Check
	target.forceMove(get_turf(src))
	if(!buckle_mob(target))
		return
	user.visible_message(
		span_notice("[user] straps [target] into the rack, immobilizing them."),
		span_boldnotice("You secure [target] tightly in place. They won't escape you now."),
	)

	playsound(src.loc, 'sound/effects/pop_expl.ogg', 25, 1)
	density = TRUE
	update_icon()

	// Set up Torture stuff now
	convert_progress = 3
	disloyalty_confirm = FALSE
	disloyalty_offered = FALSE

/// Attempt Unbuckle
/obj/structure/bloodsucker/vassalrack/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(!IS_BLOODSUCKER(user) || !IS_VASSAL(user))
		if(buckled_mob == user)
			buckled_mob.visible_message(
				span_danger("[user] tries to release themself from the rack!"),
				span_danger("You attempt to release yourself from the rack!"),
				span_hear("You hear a squishy wet noise."),
			)
		else
			buckled_mob.visible_message(
				span_danger("[user] tries to pull [buckled_mob] rack!"),
				span_danger("[user] tries to pull [buckled_mob] rack!"),
				span_hear("You hear a squishy wet noise."),
			)
		// Monster hunters are used to this sort of stuff, they know how they work, which includes breaking others out
		var/breakout_timer = IS_MONSTERHUNTER(user) ? 20 SECONDS : 10 SECONDS
		if(!do_mob(user, buckled_mob, breakout_timer))
			return
	unbuckle_mob(buckled_mob)
	. = ..()

/obj/structure/bloodsucker/vassalrack/unbuckle_mob(mob/living/buckled_mob, force = FALSE, can_fall = TRUE)
	. = ..()
	if(!.)
		return FALSE
	src.visible_message(span_danger("[buckled_mob][buckled_mob.stat == DEAD ? "'s corpse" : ""] slides off of the rack."))
	density = FALSE
	buckled_mob.Paralyze(3 SECONDS)
	update_icon()
	use_lock = FALSE // Failsafe
	return TRUE

/obj/structure/bloodsucker/vassalrack/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(!.)
		return FALSE
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	// Is there anyone on the rack & If so, are they being tortured?
	if(use_lock || !has_buckled_mobs())
		return FALSE
	var/mob/living/carbon/buckled_carbons = pick(buckled_mobs)
	/// If I'm not a Bloodsucker, try to unbuckle them.
	if(!istype(bloodsuckerdatum))
		user_unbuckle_mob(buckled_carbons, user)
		return
	var/datum/antagonist/vassal/vassaldatum = IS_VASSAL(buckled_carbons)
	// Are they our Vassal, or Dead?
	if(istype(vassaldatum) && vassaldatum.master == bloodsuckerdatum || buckled_carbons.stat >= DEAD)
		// Can we assign a Favorite Vassal?
		if(istype(vassaldatum) && !bloodsuckerdatum.has_favorite_vassal)
			if(buckled_carbons.mind.can_make_bloodsucker(buckled_carbons.mind))
				offer_favorite_vassal(user, buckled_carbons)
		use_lock = FALSE
		return

	// Not our Vassal, but Alive & We're a Bloodsucker, good to torture!
	torture_victim(user, buckled_carbons)

/**
 *	Step One: Tick Down Conversion from 3 to 0
 *	Step Two: Break mindshielding/antag (on approve)
 *	Step Three: Blood Ritual
 */

/obj/structure/bloodsucker/vassalrack/proc/torture_victim(mob/living/user, mob/living/target)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	/// Prep...
	use_lock = TRUE
	/// Conversion Process
	if(convert_progress > 0)
		to_chat(user, span_notice("You spill some blood and prepare to initiate [target] into your service."))
		bloodsuckerdatum.AddBloodVolume(-TORTURE_BLOOD_COST)
		if(!do_torture(user,target))
			to_chat(user, span_danger("<i>The ritual has been interrupted!</i>"))
		else
			/// Prevent them from unbuckling themselves as long as we're torturing.
			target.Paralyze(1 SECONDS)
			convert_progress--
			/// We're done? Let's see if they can be Vassal.
			if(convert_progress <= 0)
				if(IS_VASSAL(target))
					var/datum/antagonist/vassal/vassaldatum = target.mind.has_antag_datum(/datum/antagonist/vassal)
					if(!vassaldatum.master.broke_masquerade)
						to_chat(user, span_boldwarning("[target] is under the spell of another Bloodsucker!"))
						return
				if(RequireDisloyalty(user, target))
					to_chat(user, span_boldwarning("[target] has external loyalties! [target.p_they(TRUE)] will require more <i>persuasion</i> to break [target.p_them()] to your will!"))
				else
					to_chat(user, span_notice("[target] looks ready for the <b>Dark Communion</b>."))
			/// Otherwise, we're not done, we need to persuade them some more.
			else
				to_chat(user, span_notice("[target] could use [convert_progress == 1 ? "a little" : "some"] more <i>persuasion</i>."))
		use_lock = FALSE
		return
	/// Check: Mindshield & Antag
	if(!disloyalty_confirm && RequireDisloyalty(user, target))
		if(!do_disloyalty(user,target))
			to_chat(user, span_danger("<i>The ritual has been interrupted!</i>"))
		else if(!disloyalty_confirm)
			to_chat(user, span_danger("[target] refuses to give into your persuasion. Perhaps a little more?"))
		else
			to_chat(user, span_notice("[target] looks ready for the <b>Dark Communion</b>."))
		use_lock = FALSE
		return
	user.visible_message(
		span_notice("[user] marks a bloody smear on [target]'s forehead and puts a wrist up to [target.p_their()] mouth!"),
		span_notice("You paint a bloody marking across [target]'s forehead, place your wrist to [target.p_their()] mouth, and subject [target.p_them()] to the Dark Communion."),
	)
	if(!do_mob(user, src, 5 SECONDS))
		to_chat(user, span_danger("<i>The ritual has been interrupted!</i>"))
		use_lock = FALSE
		return
	/// Convert to Vassal!
	bloodsuckerdatum.AddBloodVolume(-TORTURE_CONVERSION_COST)
	if(bloodsuckerdatum && bloodsuckerdatum.attempt_turn_vassal(target))
		if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
			remove_loyalties(target)
		if(bloodsuckerdatum.my_clan == CLAN_TREMERE)
			to_chat(user, span_danger("You have now gained an additional Rank to spend!"))
			bloodsuckerdatum.bloodsucker_level_unspent++
		user.playsound_local(null, 'sound/effects/explosion_distant.ogg', 40, TRUE)
		target.playsound_local(null, 'sound/effects/explosion_distant.ogg', 40, TRUE)
		target.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, TRUE)
		target.Jitter(15)
		INVOKE_ASYNC(target, /mob.proc/emote, "laugh")
		//remove_victim(target) // Remove on CLICK ONLY!
	use_lock = FALSE

/obj/structure/bloodsucker/vassalrack/proc/do_torture(mob/living/user, mob/living/carbon/target, mult = 1)
	/// Fifteen seconds if you aren't using anything. Shorter with weapons and such.
	var/torture_time = 15
	var/torture_dmg_brute = 2
	var/torture_dmg_burn = 0
	/// Get Bodypart
	var/target_string = ""
	var/obj/item/bodypart/selected_bodypart = null
	selected_bodypart = pick(target.bodyparts)
	if(selected_bodypart)
		target_string += selected_bodypart.name
	/// Get Weapon
	var/obj/item/held_item = user.get_active_held_item()
	if(!istype(held_item))
		held_item = user.get_inactive_held_item()
	/// Weapon Bonus
	if(held_item)
		torture_time -= held_item.force / 4
		torture_dmg_brute += held_item.force / 4
		//torture_dmg_burn += I.
		if(held_item.sharpness == SHARP_EDGED)
			torture_time -= 2
		else if(held_item.sharpness == SHARP_POINTY)
			torture_time -= 3
		/// This will hurt your eyes.
		else if(held_item.tool_behaviour == TOOL_WELDER)
			if(held_item.use_tool(src, user, 0, volume = 5))
				torture_time -= 6
				torture_dmg_burn += 5
		held_item.play_tool_sound(target)
	/// Minimum 5 seconds.
	torture_time = max(50, torture_time * 10)
	/// Now run process.
	if(!do_mob(user, target, torture_time * mult))
		return FALSE
	/// Success?
	if(held_item)
		playsound(loc, held_item.hitsound, 30, 1, -1)
		held_item.play_tool_sound(target)
	target.visible_message(
		span_danger("[user] performs a ritual, spilling some of [target]'s blood from their [target_string] and shaking them up!"),
		span_userdanger("[user] performs a ritual, spilling some blood from your [target_string], shaking you up!"),
	)
	INVOKE_ASYNC(target, /mob.proc/emote, "scream")
	target.Jitter(5)
	target.apply_damages(brute = torture_dmg_brute, burn = torture_dmg_burn, def_zone = (selected_bodypart ? selected_bodypart.body_zone : null)) // take_overall_damage(6,0)
	return TRUE

/// Offer them the oppertunity to join now.
/obj/structure/bloodsucker/vassalrack/proc/do_disloyalty(mob/living/user, mob/living/target)
	spawn(10)
		/// Are we still torturing? Did we cancel? Are they still here?
		if(use_lock && target && target.client)
			to_chat(user, span_notice("[target] has been given the opportunity for servitude. You await their decision..."))
			var/alert_text = "You are being tortured! Do you want to give in and pledge your undying loyalty to [user]?"
		/*	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
				alert_text += "\n\nYou will no longer be loyal to the station!" */
			alert_text += "\n\nYou will not lose your current objectives, but they come second to the will of your new master!"
			to_chat(target, span_cultlarge("THE HORRIBLE PAIN! WHEN WILL IT END?!"))
			var/list/torture_icons = list(
				"Accept" = image(icon = 'fulp_modules/features/antagonists/bloodsuckers/icons/actions_bloodsucker.dmi', icon_state = "power_recup"),
				"Refuse" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "stunbaton_active")
				)
			var/torture_response = show_radial_menu(target, src, torture_icons, radius = 36, require_near = TRUE)
			switch(torture_response)
				if("Accept")
					disloyalty_accept(target)
				else
					disloyalty_refuse(target)
	if(!do_torture(user,target, 2))
		return FALSE

	// NOTE: We only remove loyalties when we're CONVERTED!
	return TRUE

/obj/structure/bloodsucker/vassalrack/proc/RequireDisloyalty(mob/living/user, mob/living/target)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = IS_BLOODSUCKER(user)
	return bloodsuckerdatum.AmValidAntag(target) || HAS_TRAIT(target, TRAIT_MINDSHIELD)

/obj/structure/bloodsucker/vassalrack/proc/disloyalty_accept(mob/living/target)
	// FAILSAFE: Still on the rack?
	if(!(locate(target) in buckled_mobs))
		return
	// NOTE: You can say YES after torture. It'll apply to next time.
	disloyalty_confirm = TRUE
	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
		to_chat(target, span_boldnotice("You give in to the will of your torturer. If they are successful, you will no longer be loyal to the station!"))

/obj/structure/bloodsucker/vassalrack/proc/disloyalty_refuse(mob/living/target)
	// FAILSAFE: Still on the rack?
	if(!(locate(target) in buckled_mobs))
		return
	// Failsafe: You already said YES.
	if(disloyalty_confirm)
		return
	to_chat(target, span_notice("You refuse to give in! You <i>will not</i> break!"))

/obj/structure/bloodsucker/vassalrack/proc/remove_loyalties(mob/living/target)
	// Find Mind Implant & Destroy
	if(HAS_TRAIT(target, TRAIT_MINDSHIELD))
		for(var/obj/item/implant/all_implants in target.implants)
			if(all_implants.type == /obj/item/implant/mindshield)
				all_implants.removed(target, silent = TRUE)

/obj/structure/bloodsucker/vassalrack/proc/offer_favorite_vassal(mob/living/carbon/human/user, mob/living/target)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	var/datum/antagonist/vassal/vassaldatum = target.mind.has_antag_datum(/datum/antagonist/vassal)

	to_chat(user, span_notice("Would you like to turn this Vassal into your completely loyal Servant? This costs 150 Blood to do. You cannot undo this."))
	var/list/favorite_options = list(
		"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
		"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no"),
	)
	var/favorite_response = show_radial_menu(user, src, favorite_options, radius = 36, require_near = TRUE)
	switch(favorite_response)
		if("Yes")
			user.blood_volume -= 150
			bloodsuckerdatum.has_favorite_vassal = TRUE
			vassaldatum.make_favorite(user)
		else
			to_chat(user, span_danger("You decide not to turn [target] into your Favorite Vassal."))
			use_lock = FALSE


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/structure/bloodsucker/candelabrum
	name = "candelabrum"
	desc = "It burns slowly, but doesn't radiate any heat."
	icon = 'fulp_modules/features/antagonists/bloodsuckers/icons/vamp_obj.dmi'
	icon_state = "candelabrum"
	light_color = "#66FFFF"//LIGHT_COLOR_BLUEGREEN // lighting.dm
	light_power = 3
	light_range = 0 // to 2
	density = FALSE
	can_buckle = TRUE
	anchored = FALSE
	Ghost_desc = "This is a magical candle which drains at the sanity of non Bloodsuckers and Vassals.\n\
		Vassals can turn the candle on manually, while Bloodsuckers can do it from a distance."
	Vamp_desc = "This is a magical candle which drains at the sanity of mortals who are not under your command while it is active.\n\
		You can right-click on it from any range to turn it on remotely, or simply be next to it and click on it to turn it on and off normally."
	Vassal_desc = "This is a magical candle which drains at the sanity of the fools who havent yet accepted your master, as long as it is active.\n\
		You can turn it on and off by clicking on it while you are next to it.\n\
		If your Master is part of the Ventrue Clan, they utilize this to upgrade their Favorite Vassal."
	Hunter_desc = "This is a blue Candelabrum, which causes insanity to those near it while active."
	var/lit = FALSE

/obj/structure/bloodsucker/candelabrum/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/structure/bloodsucker/candelabrum/update_icon_state()
	icon_state = "candelabrum[lit ? "_lit" : ""]"
	return ..()

/obj/structure/bloodsucker/candelabrum/examine(mob/user)
	. = ..()
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	if(bloodsuckerdatum.my_clan == CLAN_VENTRUE)
		. += span_cult("As part of the Ventrue Clan, you can Rank Up your Favorite Vassal.\n\
		Drag your Vassal's sprite onto the Candelabrum to secure them in place. From there, Clicking will Rank them up, while Right-click will unbuckle, as long as you are in reach.\n\
		Ranking up a Vassal will rank up what powers you currently have, and will allow you to choose what Power your Favorite Vassal will recieve.")

/obj/structure/bloodsucker/candelabrum/bolt()
	. = ..()
	set_anchored(TRUE)
	density = TRUE

/obj/structure/bloodsucker/candelabrum/unbolt()
	. = ..()
	set_anchored(FALSE)
	density = FALSE

/obj/structure/bloodsucker/candelabrum/attack_hand_secondary(mob/user, modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	if(!has_buckled_mobs() || !isliving(user))
		return
	var/mob/living/carbon/target = pick(buckled_mobs)
	if(target)
		unbuckle_mob(target, user)

/obj/structure/bloodsucker/candelabrum/proc/toggle(mob/user)
	lit = !lit
	if(lit)
		desc = initial(desc)
		set_light(2, 3, "#66FFFF")
		START_PROCESSING(SSobj, src)
	else
		desc = "Despite not being lit, it makes your skin crawl."
		set_light(0)
		STOP_PROCESSING(SSobj, src)
	update_icon()

/obj/structure/bloodsucker/candelabrum/process()
	if(!lit)
		return
	for(var/mob/living/carbon/nearly_people in viewers(7, src))
		/// We dont want Bloodsuckers or Vassals affected by this
		if(IS_VASSAL(nearly_people) || IS_BLOODSUCKER(nearly_people))
			continue
		nearly_people.hallucination += 5
		SEND_SIGNAL(nearly_people, COMSIG_ADD_MOOD_EVENT, "vampcandle", /datum/mood_event/vampcandle)

/*
 *	# Candelabrum Ventrue Stuff
 *
 *	Ventrue Bloodsuckers can buckle Vassals onto the Candelabrum to "Upgrade" them.
 *	This is limited to a Single vassal, called 'My Favorite Vassal'.
 *
 *	Most of this is just copied over from Persuasion Rack.
 */

/obj/structure/bloodsucker/candelabrum/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!.)
		return
	if(!anchored)
		return
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	// Checks: We're Ventrue, they're Buckled & Alive.
	if(bloodsuckerdatum && bloodsuckerdatum.my_clan == CLAN_VENTRUE)
		if(!has_buckled_mobs())
			toggle()
			return
		var/mob/living/carbon/target = pick(buckled_mobs)
		if(target.stat >= DEAD)
			unbuckle_mob(target)
			return
		// Are we spending a Rank?
		if(!bloodsuckerdatum.bloodsucker_level_unspent <= 0)
			bloodsuckerdatum.SpendRank(target)
		else if(user.blood_volume >= 550)
			// We don't have any ranks to spare? Let them upgrade... with enough Blood.
			to_chat(user, span_warning("Do you wish to spend 550 Blood to Rank [target] up?"))
			var/list/rank_options = list(
				"Yes" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_yes"),
				"No" = image(icon = 'icons/hud/radial.dmi', icon_state = "radial_no"),
			)
			var/rank_response = show_radial_menu(user, src, rank_options, radius = 36, require_near = TRUE)
			switch(rank_response)
				if("Yes")
					user.blood_volume -= 550
					bloodsuckerdatum.SpendRank(target, spend_rank = FALSE)
					return
		else
			// Neither? Shame. Goodbye!
			to_chat(user, span_danger("You don't have any levels or enough Blood to Rank [target] up with."))
			return

	if(IS_BLOODSUCKER(user) || IS_VASSAL(user))
		toggle()

/// Buckling someone in
/obj/structure/bloodsucker/candelabrum/MouseDrop_T(mob/living/target, mob/user)
	if(!anchored && IS_BLOODSUCKER(user))
		to_chat(user, span_danger("Until the candelabrum is secured in place, it cannot serve its purpose."))
		return
	/// Default checks
	if(!target.Adjacent(src) || target == user || !isliving(user) || has_buckled_mobs() || user.incapacitated() || target.buckled)
		return
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = IS_BLOODSUCKER(user)
	var/datum/antagonist/vassal/vassaldatum = IS_VASSAL(target)
	/// Are you even a Bloodsucker?
	if(!bloodsuckerdatum || !vassaldatum)
		return
	/// Are you part of Ventrue? No? Then go away.
	if(!bloodsuckerdatum.my_clan == CLAN_VENTRUE)
		return
	/// Are they a Favorite Vassal?
	if(!vassaldatum.favorite_vassal)
		return
	/// They are a Favorite vassal, but are they OUR Vassal?
	if(!vassaldatum.master == bloodsuckerdatum)
		return

	/// Good to go - Buckle them!
	if(do_mob(user, target, 5 SECONDS))
		attach_mob(target, user)

/obj/structure/bloodsucker/candelabrum/proc/attach_mob(mob/living/target, mob/living/user)
	user.visible_message(
		span_notice("[user] lifts and buckles [target] onto the candelabrum."),
		span_boldnotice("You buckle [target] onto the candelabrum."),
	)

	playsound(src.loc, 'sound/effects/pop_expl.ogg', 25, 1)
	target.forceMove(get_turf(src))

	if(!buckle_mob(target))
		return
	update_icon()

/// Attempt Unbuckle
/obj/structure/bloodsucker/candelabrum/unbuckle_mob(mob/living/buckled_mob, force = FALSE, can_fall = TRUE)
	. = ..()
	src.visible_message(span_danger("[buckled_mob][buckled_mob.stat==DEAD?"'s corpse":""] slides off of the candelabrum."))
	update_icon()

/// Blood Throne - Allows Bloodsuckers to remotely speak with their Vassals. - Code (Mostly) stolen from comfy chairs (armrests) and chairs (layers)
/obj/structure/bloodsucker/bloodthrone
	name = "wicked throne"
	desc = "Twisted metal shards jut from the arm rests. Very uncomfortable looking. It would take a masochistic sort to sit on this jagged piece of furniture."
	icon = 'fulp_modules/features/antagonists/bloodsuckers/icons/vamp_obj_64.dmi'
	icon_state = "throne"
	buckle_lying = 0
	anchored = FALSE
	density = TRUE
	can_buckle = TRUE
	Ghost_desc = "This is a Bloodsucker throne, any Bloodsucker sitting on it can remotely speak to their Vassals by attempting to speak aloud."
	Vamp_desc = "This is a blood throne, sitting on it will allow you to telepathically speak to your vassals by simply speaking."
	Vassal_desc = "This is a blood throne, it allows your Master to telepathically speak to you and others like you."
	Hunter_desc = "This is a chair that hurts those that try to buckle themselves onto it, though the Undead have no problem latching on.\n\
		While buckled, Monsters can use this to telepathically communicate with eachother."
	var/mutable_appearance/armrest

// Add rotating and armrest
/obj/structure/bloodsucker/bloodthrone/Initialize()
	AddComponent(/datum/component/simple_rotation)
	armrest = GetArmrest()
	armrest.layer = ABOVE_MOB_LAYER
	return ..()

/obj/structure/bloodsucker/bloodthrone/Destroy()
	QDEL_NULL(armrest)
	return ..()

/obj/structure/bloodsucker/bloodthrone/bolt()
	. = ..()
	anchored = TRUE

/obj/structure/bloodsucker/bloodthrone/unbolt()
	. = ..()
	anchored = FALSE

// Armrests
/obj/structure/bloodsucker/bloodthrone/proc/GetArmrest()
	return mutable_appearance('fulp_modules/features/antagonists/bloodsuckers/icons/vamp_obj_64.dmi', "thronearm")

/obj/structure/bloodsucker/bloodthrone/proc/update_armrest()
	if(has_buckled_mobs())
		add_overlay(armrest)
	else
		cut_overlay(armrest)

// Rotating
/obj/structure/bloodsucker/bloodthrone/setDir(newdir)
	. = ..()
	if(has_buckled_mobs())
		for(var/m in buckled_mobs)
			var/mob/living/buckled_mob = m
			buckled_mob.setDir(newdir)

	if(has_buckled_mobs() && dir == NORTH)
		layer = ABOVE_MOB_LAYER
	else
		layer = OBJ_LAYER

// Buckling
/obj/structure/bloodsucker/bloodthrone/buckle_mob(mob/living/user, force = FALSE, check_loc = TRUE)
	if(!anchored)
		to_chat(user, span_announce("[src] is not bolted to the ground!"))
		return
	. = ..()
	user.visible_message(
		span_notice("[user] sits down on [src]."),
		span_boldnotice("You sit down onto [src]."),
	)
	if(IS_BLOODSUCKER(user))
		RegisterSignal(user, COMSIG_MOB_SAY, .proc/handle_speech)
	else
		user.Paralyze(6 SECONDS)
		to_chat(user, span_cult("The power of the blood throne overwhelms you!"))
		user.apply_damage(10, BRUTE)
		unbuckle_mob(user)

/obj/structure/bloodsucker/bloodthrone/post_buckle_mob(mob/living/target)
	. = ..()
	update_armrest()
	target.pixel_y += 2

// Unbuckling
/obj/structure/bloodsucker/bloodthrone/unbuckle_mob(mob/living/user, force = FALSE, can_fall = TRUE)
	src.visible_message(span_danger("[user] unbuckles themselves from [src]."))
	if(IS_BLOODSUCKER(user))
		UnregisterSignal(user, COMSIG_MOB_SAY)
	. = ..()

/obj/structure/bloodsucker/bloodthrone/post_unbuckle_mob(mob/living/target)
	target.pixel_y -= 2

// The speech itself
/obj/structure/bloodsucker/bloodthrone/proc/handle_speech(datum/source, mob/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	var/mob/living/carbon/human/user = source
	var/rendered = span_cultlarge("<b>[user.real_name]:</b> [message]")
	user.log_talk(message, LOG_SAY, tag=ROLE_BLOODSUCKER)
	var/datum/antagonist/bloodsucker/bloodsuckerdatum = user.mind.has_antag_datum(/datum/antagonist/bloodsucker)
	for(var/datum/antagonist/vassal/receiver as anything in bloodsuckerdatum.vassals)
		if(!receiver.owner.current)
			continue
		var/mob/receiver_mob = receiver.owner.current
		to_chat(receiver_mob, rendered)
	to_chat(user, rendered) // tell yourself, too.

	for(var/mob/dead_mob in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(dead_mob, user)
		to_chat(dead_mob, "[link] [rendered]")

	speech_args[SPEECH_MESSAGE] = ""
