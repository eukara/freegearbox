/*
 * Copyright (c) 2016-2021 Marco Cawthorne <marco@icculus.org>
 *
 * Permission to use, copy, modify, and distribute this software for any
 * purpose with or without fee is hereby granted, provided that the above
 * copyright notice and this permission notice appear in all copies.
 *
 * THE SOFTWARE IS PROVIDED "AS IS" AND THE AUTHOR DISCLAIMS ALL WARRANTIES
 * WITH REGARD TO THIS SOFTWARE INCLUDING ALL IMPLIED WARRANTIES OF
 * MERCHANTABILITY AND FITNESS. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR
 * ANY SPECIAL, DIRECT, INDIRECT, OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES
 * WHATSOEVER RESULTING FROM LOSS OF MIND, USE, DATA OR PROFITS, WHETHER
 * IN AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION, ARISING
 * OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF THIS SOFTWARE.
 */

#ifdef CLIENT
/* Here's a list of bone names that we are aware of on HL player models.
   Usually we'd use skeletalobjects to share the same skeleton/anim with
   another model - but because FTEQW does not support that for HLMDL we
   are forced to manually position the bones of our attachnment
   by iterating over them and manually setting their position in 3D-space.
*/
string g_pbones[] =
{
 "Bip01",
 "Bip01 Footsteps",
 "Bip01 Pelvis",
 "Bip01 L Leg",
 "Bip01 L Leg1",
 "Bip01 L Foot",
 "Bip01 L Toe0",
 "Bip01 L Toe01",
 "Bip01 L Toe02",
 "Dummy16",
 "Bip01 R Leg",
 "Bip01 R Leg1",
 "Bip01 R Foot",
 "Bip01 R Toe0",
 "Bip01 R Toe01",
 "Bip01 R Toe02",
 "Dummy11",
 "Bip01 Spine",
 "Bip01 Spine1",
 "Bip01 Spine2",
 "Bip01 Spine3",
 "Bip01 Neck",
 "Bip01 Head",
 "Dummy21",
 "Dummy08",
 "Bone02",
 "Bone03",
 "Bone04",
 "Dummy05",
 "Bone09",
 "Bone10",
 "Dummy04",
 "Bone05",
 "Bone06",
 "Dummy03",
 "Bone07",
 "Bone08",
 "Dummy09",
 "Bone11",
 "Bone12",
"Dummy10",
 "Bone13",
 "Bone14",
 "Bone15",
 "Bip01 L Arm",
 "Bip01 L Arm1",
 "Bip01 L Arm2",
 "Bip01 L Hand",
 "Bip01 L Finger0",
 "Bip01 L Finger01",
 "Bip01 L Finger02",
 "Dummy06",
 "Bip01 L Finger1",
 "Bip01 L Finger11",
 "Bip01 L Finger12",
 "Dummy07",
 "Bip01 R Arm",
 "Bip01 R Arm1",
 "Bip01 R Arm2",
 "Bip01 R Hand",
 "Bip01 R Finger0",
 "Bip01 R Finger01",
 "Bip01 R Finger02",
 "Dummy01",
 "Bip01 R Finger1",
 "Bip01 R Finger11",
 "Bip01 R Finger12",
 "Dummy02",
 "Box02",
 "Bone08",
 "Bone15"
};
#endif

/* all potential SendFlags bits we can possibly send */
enumflags
{
	PLAYER_TOPFRAME = PLAYER_CUSTOMFIELDSTART,
	PLAYER_BOTTOMFRAME,
	PLAYER_AMMO1,
	PLAYER_AMMO2,
	PLAYER_AMMO3,
	PLAYER_UNUSED5,
	PLAYER_UNUSED6,
	PLAYER_UNUSED7
};

class player:NSClientPlayer
{
	/* animation */
	PREDICTED_INT(anim_top)
	PREDICTED_FLOAT(anim_top_time)
	PREDICTED_FLOAT(anim_top_delay)
	PREDICTED_INT(anim_bottom)
	PREDICTED_FLOAT(anim_bottom_time)

	/* ammo 1 */
	PREDICTED_INT(glock_mag)
	PREDICTED_INT(mp5_mag)
	PREDICTED_INT(python_mag)
	PREDICTED_INT(shotgun_mag)
	PREDICTED_INT(crossbow_mag)
	PREDICTED_INT(rpg_mag)
	PREDICTED_INT(satchel_chg)

	/* ammo 2 */
	PREDICTED_INT(ammo_9mm)
	PREDICTED_INT(ammo_357)
	PREDICTED_INT(ammo_buckshot)
	PREDICTED_INT(ammo_bolt)
	PREDICTED_INT(ammo_rocket)
	PREDICTED_INT(ammo_uranium)
	PREDICTED_INT(ammo_handgrenade)
	PREDICTED_INT(ammo_satchel)
	PREDICTED_INT(ammo_tripmine)
	PREDICTED_INT(ammo_snark)
	PREDICTED_INT(ammo_hornet)

	/* ammo 3 */
	PREDICTED_INT(ammo_m203_grenade)
	PREDICTED_INT(ammo_gauss_volume)
	PREDICTED_INT(ammo_rpg_state)
	PREDICTED_INT(mode_tempstate)

	/* gearbox */
	PREDICTED_INT(eagle_mag)
	PREDICTED_INT(sniper_mag)
	PREDICTED_INT(m249_mag)
	PREDICTED_INT(sporelauncher_mag)
	PREDICTED_INT(ammo_556)
	PREDICTED_INT(ammo_762)
	PREDICTED_INT(ammo_spore)
	PREDICTED_INT(ammo_shock)
	PREDICTED_INT(ammo_penguin)
	PREDICTED_INT(mode_displacer)
	PREDICTED_INT(mode_eagle)
	PREDICTED_INT(mode_wrench)
	PREDICTED_INT(mode_sporelauncher)
	PREDICTED_INT(mode_m249)

	virtual void(void) Physics_Jump;
	virtual void UpdatePlayerAnimation(float);

#ifdef CLIENT
	virtual void UpdatePlayerAttachments(bool);
	virtual void(float,float) ReceiveEntity;
	virtual void(void) PredictPreFrame;
	virtual void(void) PredictPostFrame;
#else
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
#endif
};



void Animation_PlayerUpdate(player); 
void Animation_TimerUpdate(player, float); 

void
player::UpdatePlayerAnimation(float timelength)
{
	/* calculate our skeletal progression */
	Animation_PlayerUpdate(this);
	/* advance animation timers */
	Animation_TimerUpdate(this, timelength);
}

#ifdef CLIENT
.string oldmodel;
string Weapons_GetPlayermodel(player, int);

void
player::UpdatePlayerAttachments(bool visible)
{
	/* draw the flashlight */
	if (gflags & GF_FLASHLIGHT) {
		vector src;
		vector ang;
		
		if (entnum != player_localentnum) {
			src = origin + view_ofs;
			ang = v_angle;
		} else {
			src = pSeat->m_vecPredictedOrigin + [0,0,-8];
			ang = view_angles;
		}

		makevectors(ang);
		traceline(src, src + (v_forward * 8096), MOVE_NORMAL, this);

		if (serverkeyfloat("*bspversion") == BSPVER_HL) {
			dynamiclight_add(trace_endpos + (v_forward * -2), 128, [1,1,1]);
		} else {
			float p = dynamiclight_add(src, 512, [1,1,1], 0, "textures/flashlight");
			dynamiclight_set(p, LFIELD_ANGLES, ang);
			dynamiclight_set(p, LFIELD_FLAGS, 3);
		}
	}

	/* FIXME: this needs to be incorporated and simplified, now that we can handle it all in-class */
	if (!visible)
		return;

	/* what's the current weapon model supposed to be anyway? */
	p_model.oldmodel = Weapons_GetPlayermodel(this, activeweapon);

	/* we changed weapons, update skeletonindex */
	if (p_model.model != p_model.oldmodel) {
		/* free memory */
		if (p_model.skeletonindex)
			skel_delete(p_model.skeletonindex);

		/* set the new model and mark us updated */
		setmodel(p_model, p_model.oldmodel);
		p_model.model = p_model.oldmodel;
		
		/* set the new skeletonindex */
		p_model.skeletonindex = skel_create(p_model.modelindex);

		/* hack this thing in here FIXME: this should be done when popping in/out of a pvs */
		if (autocvar(cl_himodels, 1, "Use high-quality thisayer models over lower-definition ones"))
			setcustomskin(this, "", "geomset 0 2\n");
		else
			setcustomskin(this, "", "geomset 0 1\n");
	}

	/* follow thisayer at all times */
	setorigin(p_model, origin);
	p_model.angles = angles;
	skel_build(p_model.skeletonindex, p_model, p_model.modelindex,0, 0, -1);

	/* we have to loop through all valid bones of the weapon model and match them
	 * to the thisayer one */
	for (float i = 0; i < g_pbones.length; i++) {
		vector bpos;
		float pbone = gettagindex(this, g_pbones[i]);
		float wbone = gettagindex(p_model, g_pbones[i]);

		/* if the bone doesn't ignore in either skeletal mesh, ignore */
		if (wbone <= 0 || pbone <= 0)
			continue;

		bpos = gettaginfo(this, pbone);
		
		/* the most expensive bit */
		skel_set_bone_world(p_model, wbone, bpos, v_forward, v_right, v_up);
	}
}

void Weapons_AmmoUpdate(entity);
void HUD_AmmoNotify_Check(player pl);
void HUD_ItemNotify_Check(player pl);
/*
=================
player::ReceiveEntity
=================
*/
void
player::ReceiveEntity(float new, float fl)
{

	NSClientPlayer::ReceiveEntity(new, fl);

	/* animation */
	if (fl & PLAYER_TOPFRAME) {
		anim_top = readbyte();
		anim_top_time = readfloat();
		anim_top_delay = readfloat();
	}
	if (fl & PLAYER_BOTTOMFRAME) {
		anim_bottom = readbyte();
		anim_bottom_time = readfloat();
	}

	if (fl & PLAYER_AMMO1) {
		glock_mag = readbyte();
		mp5_mag = readbyte();
		python_mag = readbyte();
		shotgun_mag = readbyte();
		crossbow_mag = readbyte();
		rpg_mag = readbyte();
		satchel_chg = readbyte();

		/* gearbox */
		eagle_mag = readbyte();
		sniper_mag = readbyte();
		m249_mag = readbyte();
		sporelauncher_mag = readbyte();
	}
	
	if (fl & PLAYER_AMMO2) {
		ammo_9mm = readbyte();
		ammo_357 = readbyte();
		ammo_buckshot = readbyte();
		ammo_bolt = readbyte();
		ammo_rocket = readbyte();
		ammo_uranium = readbyte();
		ammo_handgrenade = readbyte();
		ammo_satchel = readbyte();
		ammo_tripmine = readbyte();
		ammo_snark = readbyte();
		ammo_hornet = readbyte();

		/* gearbox */
		ammo_556 = readbyte();
		ammo_762 = readbyte();
		ammo_spore = readbyte();
		ammo_shock = readbyte();
		ammo_penguin = readbyte();
	}

	if (fl & PLAYER_AMMO3) {
		ammo_m203_grenade = readbyte();
		ammo_gauss_volume = readbyte();
		ammo_rpg_state = readbyte();
		mode_tempstate = readbyte();

		/* gearbox */
		mode_displacer = readbyte();
		mode_eagle = readbyte();
		mode_wrench = readbyte();
		mode_sporelauncher = readbyte();
		mode_m249 = readbyte();
	}

	setorigin(this, origin);

	/* these only concern the current player */
	CSQC_UpdateSeat();
	if (this != pSeat->m_ePlayer)
		return;

	/* do not notify us of updates when spawning initially */
	if (fl == UPDATE_ALL)
		PredictPreFrame();

	if (fl & PLAYER_AMMO1 || fl & PLAYER_AMMO2 || fl & PLAYER_AMMO3) {
		Weapons_AmmoUpdate(this);
		HUD_AmmoNotify_Check(this);
	}

	if (fl & PLAYER_ITEMS || fl & PLAYER_HEALTH)
		HUD_ItemNotify_Check(this);
}

/*
=================
player::PredictPostFrame

Save the last valid server values away in the _net variants of each field
so we can roll them back later.
=================
*/
void
player::PredictPreFrame(void)
{
	NSClientPlayer::PredictPreFrame();

	SAVE_STATE(anim_top);
	SAVE_STATE(anim_top_delay);
	SAVE_STATE(anim_top_time);
	SAVE_STATE(anim_bottom);
	SAVE_STATE(anim_bottom_time);

	SAVE_STATE(glock_mag);
	SAVE_STATE(mp5_mag);
	SAVE_STATE(python_mag);
	SAVE_STATE(shotgun_mag);
	SAVE_STATE(crossbow_mag);
	SAVE_STATE(rpg_mag);
	SAVE_STATE(satchel_chg);

	SAVE_STATE(ammo_9mm);
	SAVE_STATE(ammo_357);
	SAVE_STATE(ammo_buckshot);
	SAVE_STATE(ammo_bolt);
	SAVE_STATE(ammo_rocket);
	SAVE_STATE(ammo_uranium);
	SAVE_STATE(ammo_handgrenade);
	SAVE_STATE(ammo_satchel);
	SAVE_STATE(ammo_tripmine);
	SAVE_STATE(ammo_snark);
	SAVE_STATE(ammo_hornet);

	SAVE_STATE(ammo_m203_grenade);
	SAVE_STATE(ammo_gauss_volume);
	SAVE_STATE(ammo_rpg_state);
	SAVE_STATE(mode_tempstate);

	/* gearbox */
	SAVE_STATE(eagle_mag);
	SAVE_STATE(sniper_mag);
	SAVE_STATE(m249_mag);
	SAVE_STATE(sporelauncher_mag);
	SAVE_STATE(ammo_556);
	SAVE_STATE(ammo_762);
	SAVE_STATE(ammo_spore);
	SAVE_STATE(ammo_shock);
	SAVE_STATE(ammo_penguin);
	SAVE_STATE(mode_displacer);
	SAVE_STATE(mode_eagle);
	SAVE_STATE(mode_wrench);
	SAVE_STATE(mode_sporelauncher);
	SAVE_STATE(mode_m249);
}

/*
=================
player::PredictPostFrame

Where we roll back our values to the ones last sent/verified by the server.
=================
*/
void
player::PredictPostFrame(void)
{
	NSClientPlayer::PredictPostFrame();

	ROLL_BACK(anim_top);
	ROLL_BACK(anim_top_delay);
	ROLL_BACK(anim_top_time);
	ROLL_BACK(anim_bottom);
	ROLL_BACK(anim_bottom_time);

	ROLL_BACK(glock_mag);
	ROLL_BACK(mp5_mag);
	ROLL_BACK(python_mag);
	ROLL_BACK(shotgun_mag);
	ROLL_BACK(crossbow_mag);
	ROLL_BACK(rpg_mag);
	ROLL_BACK(satchel_chg);

	ROLL_BACK(ammo_9mm);
	ROLL_BACK(ammo_357);
	ROLL_BACK(ammo_buckshot);
	ROLL_BACK(ammo_bolt);
	ROLL_BACK(ammo_rocket);
	ROLL_BACK(ammo_uranium);
	ROLL_BACK(ammo_handgrenade);
	ROLL_BACK(ammo_satchel);
	ROLL_BACK(ammo_tripmine);
	ROLL_BACK(ammo_snark);
	ROLL_BACK(ammo_hornet);

	ROLL_BACK(ammo_m203_grenade);
	ROLL_BACK(ammo_gauss_volume);
	ROLL_BACK(ammo_rpg_state);
	ROLL_BACK(mode_tempstate);

	/* gearbox */
	ROLL_BACK(eagle_mag);
	ROLL_BACK(sniper_mag);
	ROLL_BACK(m249_mag);
	ROLL_BACK(sporelauncher_mag);
	ROLL_BACK(ammo_556);
	ROLL_BACK(ammo_762);
	ROLL_BACK(ammo_spore);
	ROLL_BACK(ammo_shock);
	ROLL_BACK(ammo_penguin);
	ROLL_BACK(mode_displacer);
	ROLL_BACK(mode_eagle);
	ROLL_BACK(mode_wrench);
	ROLL_BACK(mode_sporelauncher);
	ROLL_BACK(mode_m249);
}

#else
void
player::EvaluateEntity(void)
{
	NSClientPlayer::EvaluateEntity();

	/* animation */
	if (ATTR_CHANGED(anim_bottom) || ATTR_CHANGED(anim_bottom_time))
		SendFlags |= PLAYER_BOTTOMFRAME;
	if (ATTR_CHANGED(anim_top) || ATTR_CHANGED(anim_top_time) || ATTR_CHANGED(anim_top_delay))
		SendFlags |= PLAYER_TOPFRAME;

	/* ammo 1 type updates */
	if (ATTR_CHANGED(glock_mag))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(mp5_mag))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(python_mag))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(shotgun_mag))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(crossbow_mag))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(rpg_mag))
		SendFlags |= PLAYER_AMMO1;
	if (ATTR_CHANGED(satchel_chg))
		SendFlags |= PLAYER_AMMO1;

	/* ammo 2 type updates */
	if (ATTR_CHANGED(ammo_9mm))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_357))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_buckshot))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_bolt))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_rocket))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_uranium))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_handgrenade))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_satchel))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_tripmine))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_snark))
		SendFlags |= PLAYER_AMMO2;
	if (ATTR_CHANGED(ammo_hornet))
		SendFlags |= PLAYER_AMMO2;

	if (ATTR_CHANGED(ammo_m203_grenade))
		SendFlags |= PLAYER_AMMO3;
	if (ATTR_CHANGED(ammo_gauss_volume))
		SendFlags |= PLAYER_AMMO3;
	if (ATTR_CHANGED(ammo_rpg_state))
		SendFlags |= PLAYER_AMMO3;
	if (ATTR_CHANGED(mode_tempstate))
		SendFlags |= PLAYER_AMMO3;

	SAVE_STATE(glock_mag);
	SAVE_STATE(mp5_mag);
	SAVE_STATE(python_mag);
	SAVE_STATE(shotgun_mag);
	SAVE_STATE(crossbow_mag);
	SAVE_STATE(rpg_mag);
	SAVE_STATE(satchel_chg);
	SAVE_STATE(ammo_9mm);
	SAVE_STATE(ammo_357);
	SAVE_STATE(ammo_buckshot);
	SAVE_STATE(ammo_bolt);
	SAVE_STATE(ammo_rocket);
	SAVE_STATE(ammo_uranium);
	SAVE_STATE(ammo_handgrenade);
	SAVE_STATE(ammo_satchel);
	SAVE_STATE(ammo_tripmine);
	SAVE_STATE(ammo_snark);
	SAVE_STATE(ammo_hornet);

	SAVE_STATE(ammo_m203_grenade);
	SAVE_STATE(ammo_gauss_volume);
	SAVE_STATE(ammo_rpg_state);
	SAVE_STATE(mode_tempstate);

	SAVE_STATE(anim_top);
	SAVE_STATE(anim_top_delay);
	SAVE_STATE(anim_top_time);
	SAVE_STATE(anim_bottom);
	SAVE_STATE(anim_bottom_time);

	/* gearbox */
	if (eagle_mag_net != eagle_mag)
		SendFlags |= PLAYER_AMMO1;
	if (sniper_mag_net != sniper_mag)
		SendFlags |= PLAYER_AMMO1;
	if (m249_mag_net != m249_mag)
		SendFlags |= PLAYER_AMMO1;
	if (sporelauncher_mag_net != sporelauncher_mag)
		SendFlags |= PLAYER_AMMO1;

	if (ammo_556_net != ammo_556)
		SendFlags |= PLAYER_AMMO2;
	if (ammo_762_net != ammo_762)
		SendFlags |= PLAYER_AMMO2;
	if (ammo_spore_net != ammo_spore)
		SendFlags |= PLAYER_AMMO2;
	if (ammo_shock_net != ammo_shock)
		SendFlags |= PLAYER_AMMO2;
	if (ammo_penguin_net != ammo_penguin)
		SendFlags |= PLAYER_AMMO2;

	if (mode_displacer_net != mode_displacer)
		SendFlags |= PLAYER_AMMO3;
	if (mode_eagle_net != mode_eagle)
		SendFlags |= PLAYER_AMMO3;
	if (mode_wrench_net != mode_wrench)
		SendFlags |= PLAYER_AMMO3;
	if (mode_sporelauncher_net != mode_sporelauncher)
		SendFlags |= PLAYER_AMMO3;

	/* gearbox */
	SAVE_STATE(eagle_mag);
	SAVE_STATE(sniper_mag);
	SAVE_STATE(m249_mag);
	SAVE_STATE(sporelauncher_mag);
	SAVE_STATE(ammo_556);
	SAVE_STATE(ammo_762);
	SAVE_STATE(ammo_spore);
	SAVE_STATE(ammo_shock);
	SAVE_STATE(ammo_penguin);
	SAVE_STATE(mode_displacer);
	SAVE_STATE(mode_eagle);
	SAVE_STATE(mode_wrench);
	SAVE_STATE(mode_sporelauncher);
	SAVE_STATE(mode_m249);
}

/*
=================
player::SendEntity
=================
*/
float
player::SendEntity(entity ePEnt, float flChanged)
{
	/* don't broadcast invisible players */
	if (IsFakeSpectator() && ePEnt != this)
		return (0);
	if (!GetModelindex() && ePEnt != this)
		return (0);

	flChanged = OptimiseChangedFlags(ePEnt, flChanged);

	WriteByte(MSG_ENTITY, ENT_PLAYER);
	WriteFloat(MSG_ENTITY, flChanged);

	NSClientPlayer::SendEntity(ePEnt, flChanged);

	if (flChanged & PLAYER_TOPFRAME) {
		WriteByte(MSG_ENTITY, anim_top);
		WriteFloat(MSG_ENTITY, anim_top_time);
		WriteFloat(MSG_ENTITY, anim_top_delay);
	}
	if (flChanged & PLAYER_BOTTOMFRAME) {
		WriteByte(MSG_ENTITY, anim_bottom);
		WriteFloat(MSG_ENTITY, anim_bottom_time);
	}

	if (flChanged & PLAYER_AMMO1) {
		WriteByte(MSG_ENTITY, glock_mag);
		WriteByte(MSG_ENTITY, mp5_mag);
		WriteByte(MSG_ENTITY, python_mag);
		WriteByte(MSG_ENTITY, shotgun_mag);
		WriteByte(MSG_ENTITY, crossbow_mag);
		WriteByte(MSG_ENTITY, rpg_mag);
		WriteByte(MSG_ENTITY, satchel_chg);

		/* gearbox */
		WriteByte(MSG_ENTITY, eagle_mag);
		WriteByte(MSG_ENTITY, sniper_mag);
		WriteByte(MSG_ENTITY, m249_mag);
		WriteByte(MSG_ENTITY, sporelauncher_mag);
	}

	if (flChanged & PLAYER_AMMO2) {
		WriteByte(MSG_ENTITY, ammo_9mm);
		WriteByte(MSG_ENTITY, ammo_357);
		WriteByte(MSG_ENTITY, ammo_buckshot);
		WriteByte(MSG_ENTITY, ammo_bolt);
		WriteByte(MSG_ENTITY, ammo_rocket);
		WriteByte(MSG_ENTITY, ammo_uranium);
		WriteByte(MSG_ENTITY, ammo_handgrenade);
		WriteByte(MSG_ENTITY, ammo_satchel);
		WriteByte(MSG_ENTITY, ammo_tripmine);
		WriteByte(MSG_ENTITY, ammo_snark);
		WriteByte(MSG_ENTITY, ammo_hornet);

		/* gearbox */
		WriteByte(MSG_ENTITY, ammo_556);
		WriteByte(MSG_ENTITY, ammo_762);
		WriteByte(MSG_ENTITY, ammo_spore);
		WriteByte(MSG_ENTITY, ammo_shock);
		WriteByte(MSG_ENTITY, ammo_penguin);
	}

	if (flChanged & PLAYER_AMMO3) {
		WriteByte(MSG_ENTITY, ammo_m203_grenade);
		WriteByte(MSG_ENTITY, ammo_gauss_volume);
		WriteByte(MSG_ENTITY, ammo_rpg_state);
		WriteByte(MSG_ENTITY, mode_tempstate);

		/* gearbox */
		WriteByte(MSG_ENTITY, mode_displacer);
		WriteByte(MSG_ENTITY, mode_eagle);
		WriteByte(MSG_ENTITY, mode_wrench);
		WriteByte(MSG_ENTITY, mode_sporelauncher);
		WriteByte(MSG_ENTITY, mode_m249);
	}

	return (1);
}
#endif

