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

#define PLAYER_FLAG  PLAYER_BOTTOMFRAME

class OP4Player:HLPlayer
{
	PREDICTED_FLOAT(flagmodel)
	PREDICTED_FLOAT(flagskin)
	string m_oldModel;

	virtual void OP4Player(void);

#ifdef CLIENT
	ncRenderableEntity m_eFlag;
	virtual void UpdatePlayerAttachments(bool);
	virtual void(float,float) ReceiveEntity;
	virtual void(void) PredictPreFrame;
	virtual void(void) PredictPostFrame;
	virtual void OnRemoveEntity(void);
#else
	entity hook;
	float m_flPickUpTime;
	virtual void(void) EvaluateEntity;
	virtual float(entity, float) SendEntity;
	nonvirtual void PowerupThink(void);
#endif
};

void
OP4Player::OP4Player(void)
{

}

#ifdef CLIENT
void
OP4Player::UpdatePlayerAttachments(bool visible)
{
	if (m_eFlag != world) {
		m_eFlag.SetOrigin(origin);
		m_eFlag.SetAngles([0, angles[1], 0]);
	}

	/* FIXME: this needs to be incorporated and simplified, now that we can handle it all in-class */
	if (!visible)
		return;

	/* what's the current weapon model supposed to be anyway? */
	p_model.oldmodel = 0;//Weapons_GetPlayermodel(this, activeweapon);

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
		if (autocvar(cl_himodels, 1, "Use high-quality player models over lower-definition ones"))
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

void
OP4Player::OnRemoveEntity(void)
{
	super::OnRemoveEntity();

	if (m_eFlag) {
		m_eFlag.Destroy();
	}
}
/*
=================
OP4Player::ReceiveEntity
=================
*/
void
OP4Player::ReceiveEntity(float new, float flChanged)
{
	/* the generic client attributes */
	ncPlayer::ReceiveEntity(new, flChanged);

	READENTITY_BYTE(anim_top, PLAYER_TOPFRAME)
	READENTITY_FLOAT(anim_top_time, PLAYER_TOPFRAME)
	READENTITY_FLOAT(anim_top_delay, PLAYER_TOPFRAME)
	READENTITY_BYTE(anim_bottom, PLAYER_BOTTOMFRAME)
	READENTITY_FLOAT(anim_bottom_time, PLAYER_BOTTOMFRAME)

	READENTITY_FLOAT(flagmodel, PLAYER_FLAG)
	READENTITY_BYTE(flagskin, PLAYER_FLAG)

	/* add/remove flag model */
	if (flagmodel != 0) {
		if (!m_eFlag)
			m_eFlag = spawn(ncRenderableEntity);

		m_eFlag.SetModelindex(flagmodel);
		m_eFlag.SetSkin(flagskin);
		m_eFlag.SetFrame(2);
	} else if (m_eFlag) {
		m_eFlag.Destroy();
		remove(m_eFlag);
		m_eFlag = 0;
	}
}

/*
=================
OP4Player::PredictPostFrame

Save the last valid server values away in the _net variants of each field
so we can roll them back later.
=================
*/
void
OP4Player::PredictPreFrame(void)
{
	super::PredictPreFrame();
	SAVE_STATE(flagmodel)
	SAVE_STATE(flagskin)
}

/*
=================
OP4Player::PredictPostFrame

Where we roll back our values to the ones last sent/verified by the server.
=================
*/
void
OP4Player::PredictPostFrame(void)
{
	super::PredictPostFrame();

	ROLL_BACK(flagmodel)
	ROLL_BACK(flagskin)
}

#else

void
OP4Player::EvaluateEntity(void)
{
	/* the generic client attributes */
	super::EvaluateEntity();

	PowerupThink();

	EVALUATE_FIELD(flagmodel, PLAYER_FLAG)
	EVALUATE_FIELD(flagskin, PLAYER_FLAG)
}

/*
=================
OP4Player::SendEntity
=================
*/
float
OP4Player::SendEntity(entity ePEnt, float flChanged)
{
	/* don't broadcast invisible players */
	if (IsFakeSpectator() && ePEnt != this)
		return (0);
	if (!GetModelindex() && ePEnt != this)
		return (0);

	flChanged = OptimiseChangedFlags(ePEnt, flChanged);

	/* the generic client attributes */
	ncPlayer::SendEntity(ePEnt, flChanged);

	SENDENTITY_BYTE(anim_top, PLAYER_TOPFRAME)
	SENDENTITY_FLOAT(anim_top_time, PLAYER_TOPFRAME)
	SENDENTITY_FLOAT(anim_top_delay, PLAYER_TOPFRAME)
	SENDENTITY_BYTE(anim_bottom, PLAYER_BOTTOMFRAME)
	SENDENTITY_FLOAT(anim_bottom_time, PLAYER_BOTTOMFRAME)

	SENDENTITY_FLOAT(flagmodel, PLAYER_FLAG)
	SENDENTITY_BYTE(flagskin, PLAYER_FLAG)
	return (1);
}
#endif
