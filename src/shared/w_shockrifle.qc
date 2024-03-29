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
var int PART_SHOCKPIECE;
#endif

enum
{
	SHOCKRIFLE_IDLE1,
	SHOCKRIFLE_SHOOT,
	SHOCKRIFLE_DRAW,
	SHOCKRIFLE_HOLSTER,
	SHOCKRIFLE_IDLE2
};

void
w_shockrifle_precache(void)
{
#ifdef SERVER
	precache_model("models/w_shock.mdl");
	precache_sound("weapons/shock_discharge.wav");
	precache_sound("weapons/shock_draw.wav");
	precache_sound("weapons/shock_fire.wav");
	precache_sound("weapons/shock_impact.wav");
	precache_sound("weapons/shock_recharge.wav");
#else
	PART_SHOCKPIECE = particleeffectnum("shockrifle.shockrifle_piece");
	precache_model("models/v_shock.mdl");
	precache_model("models/p_shock.mdl");
#endif
}

int
w_shockrifle_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	/* only pick it up once */
	if (new) {
		pl.ammo_shock = MAX_A_SHOCK;
		return (1);
	}
#endif
	return (0);
}

void
w_shockrifle_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.ammo_shock, -1);
}

string
w_shockrifle_wmodel(void)
{
	return "models/w_shock.mdl";
}

string
w_shockrifle_pmodel(player pl)
{
	return "models/p_shock.mdl";
}

string
w_shockrifle_deathmsg(void)
{
	return "";
}

void
w_shockrifle_draw(player pl)
{
	Weapons_SetModel("models/v_shock.mdl");
	Weapons_ViewAnimation(pl, SHOCKRIFLE_DRAW);
}

void
w_shockrifle_holster(player pl)
{
	
}

#ifdef SERVER
void
w_shockrifle_shoothornet(player pl)
{
	static void Hornet_Touch(void) {
		if (other.takedamage == DAMAGE_YES) {
			Damage_Apply(other, self.owner, 10, WEAPON_SHOCKRIFLE, DMG_ELECTRO);
		}
		
		if (other.iBleeds) {
			FX_Blood(trace_endpos, [1,0,0]);
		} else {
			pointparticles(particleeffectnum("fx_spark.main"), trace_endpos, trace_plane_normal, 1);
		}
		remove(self);
	}
	Weapons_MakeVectors(pl);
	entity bolt = spawn();
	//setmodel(bolt, "models/hornet.mdl");
	setorigin(bolt, Weapons_GetCameraPos(pl) + (v_forward * 16) + (v_up * -8));
	bolt.owner = self;
	bolt.velocity = v_forward * 1000;
	bolt.movetype = MOVETYPE_FLY;
	bolt.solid = SOLID_BBOX;
	//bolt.flags |= FL_LAGGEDMOVE;
	bolt.gravity = 0.5f;
	bolt.angles = vectoangles(bolt.velocity);
	bolt.touch = Hornet_Touch;
	setsize(bolt, [0,0,0], [0,0,0]);
}
#endif

void
w_shockrifle_release(player pl)
{

	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.ammo_shock < MAX_A_SHOCK) {
		pl.ammo_shock = bound(0, pl.ammo_shock + 1, MAX_A_SHOCK);
		pl.w_idle_next = 0.35f;
	}

	if (pl.w_idle_next > 0.0) {
		return;
	}

	int r = (float)input_sequence % 2;
	if (r < 1) {
		Weapons_ViewAnimation(pl, SHOCKRIFLE_IDLE1);
	} else {
		Weapons_ViewAnimation(pl, SHOCKRIFLE_IDLE2);
	}

	pl.w_idle_next = 3.333333f;
}

void
w_shockrifle_primary(player pl)
{
	if (pl.w_attack_next > 0.0) {
		return;
	}

	if (pl.ammo_shock <= 0) {
		w_shockrifle_release(pl);
		return;
	}

	pl.ammo_shock--;
	Weapons_ViewAnimation(pl, SHOCKRIFLE_SHOOT);
	
#ifdef SERVER
	w_shockrifle_shoothornet(pl);
	sound(pl, CHAN_WEAPON, "weapons/shock_fire.wav", 1, ATTN_NORM);
#else
	Weapons_MakeVectors(pl);
	vector src = Weapons_GetCameraPos(pl) + (v_forward * 16) + (v_up * -8);
	pointparticles(PART_SHOCKPIECE, src, v_forward * 1000, 1);
#endif

	pl.w_attack_next = 0.1f;
	pl.w_idle_next = 0.5f;
}

void
w_shockrifle_crosshair(player pl)
{
#ifdef CLIENT
	vector aicon_pos;

	Cross_DrawSub(
		g_ofch1_spr,
		[24,24],
		[0,24/72],
		[24/72, 24/72]
	);

	/* ammo counter */
	HUD_DrawAmmo2();

	/* ammo icon */
	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(
		aicon_pos,
		[24,24],
		"sprites/640hud7.spr_0.tga",
		[224/256,48/128],
		[24/256, 24/128],
		g_hud_color,
		pSeatLocal->m_flAmmo2Alpha,
		DRAWFLAG_ADDITIVE
	);
#endif
}

float
w_shockrifle_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMHIVE : ANIM_AIMHIVE;
}

int
w_shockrifle_isempty(player pl)
{

	if (pl.ammo_shock <= 0)
		return 1;

	return 0;
}

void
w_shockrifle_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (w_shockrifle_isempty(pl))
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_shock, MAX_A_SHOCK, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_ofhud4_spr,
			[0,45/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			g_ofhud3_spr,
			[0,45/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_shockrifle =
{
	.name		= "shockrifle",
	.id		= ITEM_SHOCKRIFLE,
	.slot		= 6,
	.slot_pos	= 1,
	.draw		= w_shockrifle_draw,
	.holster	= w_shockrifle_holster,
	.primary	= w_shockrifle_primary,
	.secondary	= w_shockrifle_release,
	.reload		= w_shockrifle_release,
	.release	= w_shockrifle_release,
	.postdraw	= w_shockrifle_crosshair,
	.precache	= w_shockrifle_precache,
	.pickup		= w_shockrifle_pickup,
	.updateammo	= w_shockrifle_updateammo,
	.wmodel		= w_shockrifle_wmodel,
	.pmodel		= w_shockrifle_pmodel,
	.deathmsg	= w_shockrifle_deathmsg,
	.aimanim	= w_shockrifle_aimanim,
	.hudpic		= w_shockrifle_hudpic,
	.isempty	= w_shockrifle_isempty
};