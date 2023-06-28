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
	PLAYER_FLAG,
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

	PREDICTED_FLOAT(flagmodel)
	PREDICTED_FLOAT(flagskin)

	virtual void(void) Physics_Jump;
	virtual void UpdatePlayerAnimation(float);

#ifdef CLIENT
	NSRenderableEntity m_eFlag;
	virtual void UpdatePlayerAttachments(bool);
	virtual void(float,float) ReceiveEntity;
	virtual void(void) PredictPreFrame;
	virtual void(void) PredictPostFrame;
	virtual void UpdateAliveCam(void);
	virtual void OnRemoveEntity(void);
#else
	float m_flPickUpTime;
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
	nonvirtual void PowerupThink(void);
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
void Camera_RunPosBob(vector angles, __inout vector camera_pos);
void Camera_StrafeRoll(__inout vector camera_angle);
void Shake_Update(NSClientPlayer);

void
player::UpdateAliveCam(void)
{
	vector cam_pos = GetEyePos();
	Camera_RunPosBob(view_angles, cam_pos);

	g_view.SetCameraOrigin(cam_pos);
	Camera_StrafeRoll(view_angles);
	g_view.SetCameraAngle(view_angles);

	if (vehicle) {
		NSVehicle veh = (NSVehicle)vehicle;

		if (veh.UpdateView)
			veh.UpdateView();
	} else if (health) {
		if (autocvar_pm_thirdPerson == TRUE) {
			makevectors(view_angles);
			vector vStart = [pSeat->m_vecPredictedOrigin[0], pSeat->m_vecPredictedOrigin[1], pSeat->m_vecPredictedOrigin[2] + 16] + (v_right * 4);
			vector vEnd = vStart + (v_forward * -48) + [0,0,16] + (v_right * 4);
			traceline(vStart, vEnd, FALSE, this);
			g_view.SetCameraOrigin(trace_endpos + (v_forward * 5));
		}
	}

	Shake_Update(this);
	g_view.AddPunchAngle(punchangle);
}

.string oldmodel;
string Weapons_GetPlayermodel(player, int);

void
player::UpdatePlayerAttachments(bool visible)
{
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

	if (m_eFlag != world) {
		m_eFlag.SetOrigin(origin);
		m_eFlag.SetAngles([0, angles[1], 0]);
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

void
player::OnRemoveEntity(void)
{
	super::OnRemoveEntity();

	if (m_eFlag) {
		m_eFlag.Destroy();
	}
}
/*
=================
player::ReceiveEntity
=================
*/
void
player::ReceiveEntity(float new, float flChanged)
{
	/* the generic client attributes */
	NSClientPlayer::ReceiveEntity(new, flChanged);

	/* animation */
	READENTITY_BYTE(anim_top, PLAYER_TOPFRAME)
	READENTITY_FLOAT(anim_top_time, PLAYER_TOPFRAME)
	READENTITY_FLOAT(anim_top_delay, PLAYER_TOPFRAME)
	READENTITY_BYTE(anim_bottom, PLAYER_BOTTOMFRAME)
	READENTITY_FLOAT(anim_bottom_time, PLAYER_BOTTOMFRAME)

	READENTITY_BYTE(glock_mag, PLAYER_AMMO1)
	READENTITY_BYTE(mp5_mag, PLAYER_AMMO1)
	READENTITY_BYTE(python_mag, PLAYER_AMMO1)
	READENTITY_BYTE(shotgun_mag, PLAYER_AMMO1)
	READENTITY_BYTE(crossbow_mag, PLAYER_AMMO1)
	READENTITY_BYTE(rpg_mag, PLAYER_AMMO1)
	READENTITY_BYTE(satchel_chg, PLAYER_AMMO1)

	READENTITY_BYTE(ammo_9mm, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_357, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_buckshot, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_bolt, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_rocket, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_uranium, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_handgrenade, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_satchel, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_tripmine, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_snark, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_hornet, PLAYER_AMMO2)

	READENTITY_BYTE(ammo_m203_grenade, PLAYER_AMMO3)
	READENTITY_BYTE(ammo_gauss_volume, PLAYER_AMMO3)
	READENTITY_BYTE(ammo_rpg_state, PLAYER_AMMO3)
	READENTITY_BYTE(mode_tempstate, PLAYER_AMMO3)

	/* gearbox */
	READENTITY_BYTE(eagle_mag, PLAYER_AMMO1)
	READENTITY_BYTE(sniper_mag, PLAYER_AMMO1)
	READENTITY_BYTE(m249_mag, PLAYER_AMMO1)
	READENTITY_BYTE(sporelauncher_mag, PLAYER_AMMO1)

	READENTITY_BYTE(ammo_556, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_762, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_spore, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_shock, PLAYER_AMMO2)
	READENTITY_BYTE(ammo_penguin, PLAYER_AMMO2)

	READENTITY_BYTE(mode_displacer, PLAYER_AMMO3)
	READENTITY_BYTE(mode_eagle, PLAYER_AMMO3)
	READENTITY_BYTE(mode_wrench, PLAYER_AMMO3)
	READENTITY_BYTE(mode_sporelauncher, PLAYER_AMMO3)
	READENTITY_BYTE(mode_m249, PLAYER_AMMO3)

	READENTITY_FLOAT(flagmodel, PLAYER_FLAG)
	READENTITY_BYTE(flagskin, PLAYER_FLAG)

	setorigin(this, origin);

	/* add/remove flag model */
	if (flagmodel != 0) {
		if (!m_eFlag)
			m_eFlag = spawn(NSRenderableEntity);

		m_eFlag.SetModelindex(flagmodel);
		m_eFlag.SetSkin(flagskin);
		m_eFlag.SetFrame(2);
	} else if (m_eFlag) {
		m_eFlag.Destroy();
		remove(m_eFlag);
		m_eFlag = world;
	}

	/* these only concern the current player */
	CSQC_UpdateSeat();
	if (this != pSeat->m_ePlayer)
		return;

	/* do not notify us of updates when spawning initially */
	if (flChanged == UPDATE_ALL)
		PredictPreFrame();

	if (flChanged & PLAYER_AMMO1 || flChanged & PLAYER_AMMO2 || flChanged & PLAYER_AMMO3) {
		Weapons_AmmoUpdate(this);
		HUD_AmmoNotify_Check(this);
	}

	if (flChanged & PLAYER_ITEMS || flChanged & PLAYER_HEALTH)
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

	SAVE_STATE(anim_top)
	SAVE_STATE(anim_top_delay)
	SAVE_STATE(anim_top_time)
	SAVE_STATE(anim_bottom)
	SAVE_STATE(anim_bottom_time)

	SAVE_STATE(glock_mag)
	SAVE_STATE(mp5_mag)
	SAVE_STATE(python_mag)
	SAVE_STATE(shotgun_mag)
	SAVE_STATE(crossbow_mag)
	SAVE_STATE(rpg_mag)
	SAVE_STATE(satchel_chg)

	SAVE_STATE(ammo_9mm)
	SAVE_STATE(ammo_357)
	SAVE_STATE(ammo_buckshot)
	SAVE_STATE(ammo_bolt)
	SAVE_STATE(ammo_rocket)
	SAVE_STATE(ammo_uranium)
	SAVE_STATE(ammo_handgrenade)
	SAVE_STATE(ammo_satchel)
	SAVE_STATE(ammo_tripmine)
	SAVE_STATE(ammo_snark)
	SAVE_STATE(ammo_hornet)

	SAVE_STATE(ammo_m203_grenade)
	SAVE_STATE(ammo_gauss_volume)
	SAVE_STATE(ammo_rpg_state)
	SAVE_STATE(mode_tempstate)

	/* gearbox */
	SAVE_STATE(eagle_mag)
	SAVE_STATE(sniper_mag)
	SAVE_STATE(m249_mag)
	SAVE_STATE(sporelauncher_mag)
	SAVE_STATE(ammo_556)
	SAVE_STATE(ammo_762)
	SAVE_STATE(ammo_spore)
	SAVE_STATE(ammo_shock)
	SAVE_STATE(ammo_penguin)
	SAVE_STATE(mode_displacer)
	SAVE_STATE(mode_eagle)
	SAVE_STATE(mode_wrench)
	SAVE_STATE(mode_sporelauncher)
	SAVE_STATE(mode_m249)
	SAVE_STATE(flagmodel)
	SAVE_STATE(flagskin)
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

	ROLL_BACK(anim_top)
	ROLL_BACK(anim_top_delay)
	ROLL_BACK(anim_top_time)
	ROLL_BACK(anim_bottom)
	ROLL_BACK(anim_bottom_time)

	ROLL_BACK(glock_mag)
	ROLL_BACK(mp5_mag)
	ROLL_BACK(python_mag)
	ROLL_BACK(shotgun_mag)
	ROLL_BACK(crossbow_mag)
	ROLL_BACK(rpg_mag)
	ROLL_BACK(satchel_chg)

	ROLL_BACK(ammo_9mm)
	ROLL_BACK(ammo_357)
	ROLL_BACK(ammo_buckshot)
	ROLL_BACK(ammo_bolt)
	ROLL_BACK(ammo_rocket)
	ROLL_BACK(ammo_uranium)
	ROLL_BACK(ammo_handgrenade)
	ROLL_BACK(ammo_satchel)
	ROLL_BACK(ammo_tripmine)
	ROLL_BACK(ammo_snark)
	ROLL_BACK(ammo_hornet)

	ROLL_BACK(ammo_m203_grenade)
	ROLL_BACK(ammo_gauss_volume)
	ROLL_BACK(ammo_rpg_state)
	ROLL_BACK(mode_tempstate)

	/* gearbox */
	ROLL_BACK(eagle_mag)
	ROLL_BACK(sniper_mag)
	ROLL_BACK(m249_mag)
	ROLL_BACK(sporelauncher_mag)
	ROLL_BACK(ammo_556)
	ROLL_BACK(ammo_762)
	ROLL_BACK(ammo_spore)
	ROLL_BACK(ammo_shock)
	ROLL_BACK(ammo_penguin)
	ROLL_BACK(mode_displacer)
	ROLL_BACK(mode_eagle)
	ROLL_BACK(mode_wrench)
	ROLL_BACK(mode_sporelauncher)
	ROLL_BACK(mode_m249)
	ROLL_BACK(flagmodel)
	ROLL_BACK(flagskin)
}

#else

void
player::EvaluateEntity(void)
{
	/* the generic client attributes */
	NSClientPlayer::EvaluateEntity();

	PowerupThink();

	EVALUATE_FIELD(anim_top, PLAYER_TOPFRAME)
	EVALUATE_FIELD(anim_top_time, PLAYER_TOPFRAME)
	EVALUATE_FIELD(anim_top_delay, PLAYER_TOPFRAME)
	EVALUATE_FIELD(anim_bottom, PLAYER_BOTTOMFRAME)
	EVALUATE_FIELD(anim_bottom_time, PLAYER_BOTTOMFRAME)

	EVALUATE_FIELD(glock_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(mp5_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(python_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(shotgun_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(crossbow_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(rpg_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(satchel_chg, PLAYER_AMMO1)

	EVALUATE_FIELD(ammo_9mm, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_357, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_buckshot, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_bolt, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_rocket, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_uranium, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_handgrenade, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_satchel, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_tripmine, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_snark, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_hornet, PLAYER_AMMO2)

	EVALUATE_FIELD(ammo_m203_grenade, PLAYER_AMMO3)
	EVALUATE_FIELD(ammo_gauss_volume, PLAYER_AMMO3)
	EVALUATE_FIELD(ammo_rpg_state, PLAYER_AMMO3)
	EVALUATE_FIELD(mode_tempstate, PLAYER_AMMO3)

	/* gearbox */
	EVALUATE_FIELD(eagle_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(sniper_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(m249_mag, PLAYER_AMMO1)
	EVALUATE_FIELD(sporelauncher_mag, PLAYER_AMMO1)

	EVALUATE_FIELD(ammo_556, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_762, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_spore, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_shock, PLAYER_AMMO2)
	EVALUATE_FIELD(ammo_penguin, PLAYER_AMMO2)

	EVALUATE_FIELD(mode_displacer, PLAYER_AMMO3)
	EVALUATE_FIELD(mode_eagle, PLAYER_AMMO3)
	EVALUATE_FIELD(mode_wrench, PLAYER_AMMO3)
	EVALUATE_FIELD(mode_sporelauncher, PLAYER_AMMO3)
	EVALUATE_FIELD(mode_m249, PLAYER_AMMO3)
	EVALUATE_FIELD(flagmodel, PLAYER_FLAG)
	EVALUATE_FIELD(flagskin, PLAYER_FLAG)
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

	/* the generic client attributes */
	NSClientPlayer::SendEntity(ePEnt, flChanged);

	SENDENTITY_BYTE(anim_top, PLAYER_TOPFRAME)
	SENDENTITY_FLOAT(anim_top_time, PLAYER_TOPFRAME)
	SENDENTITY_FLOAT(anim_top_delay, PLAYER_TOPFRAME)
	SENDENTITY_BYTE(anim_bottom, PLAYER_BOTTOMFRAME)
	SENDENTITY_FLOAT(anim_bottom_time, PLAYER_BOTTOMFRAME)

	SENDENTITY_BYTE(glock_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(mp5_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(python_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(shotgun_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(crossbow_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(rpg_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(satchel_chg, PLAYER_AMMO1)

	SENDENTITY_BYTE(ammo_9mm, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_357, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_buckshot, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_bolt, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_rocket, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_uranium, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_handgrenade, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_satchel, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_tripmine, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_snark, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_hornet, PLAYER_AMMO2)

	SENDENTITY_BYTE(ammo_m203_grenade, PLAYER_AMMO3)
	SENDENTITY_BYTE(ammo_gauss_volume, PLAYER_AMMO3)
	SENDENTITY_BYTE(ammo_rpg_state, PLAYER_AMMO3)
	SENDENTITY_BYTE(mode_tempstate, PLAYER_AMMO3)

	/* gearbox */
	SENDENTITY_BYTE(eagle_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(sniper_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(m249_mag, PLAYER_AMMO1)
	SENDENTITY_BYTE(sporelauncher_mag, PLAYER_AMMO1)

	SENDENTITY_BYTE(ammo_556, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_762, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_spore, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_shock, PLAYER_AMMO2)
	SENDENTITY_BYTE(ammo_penguin, PLAYER_AMMO2)

	SENDENTITY_BYTE(mode_displacer, PLAYER_AMMO3)
	SENDENTITY_BYTE(mode_eagle, PLAYER_AMMO3)
	SENDENTITY_BYTE(mode_wrench, PLAYER_AMMO3)
	SENDENTITY_BYTE(mode_sporelauncher, PLAYER_AMMO3)
	SENDENTITY_BYTE(mode_m249, PLAYER_AMMO3)
	SENDENTITY_FLOAT(flagmodel, PLAYER_FLAG)
	SENDENTITY_BYTE(flagskin, PLAYER_FLAG)
	return (1);
}
#endif

