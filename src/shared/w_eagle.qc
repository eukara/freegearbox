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

/*QUAKED weapon_eagle (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_desert_eagle.mdl"

HALF-LIFE: OPPOSING FORCE (1999) ENTITY

Desert Eagle Weapon

*/

enum
{
	EAGLE_IDLE1,
	EAGLE_IDLE2,
	EAGLE_IDLE3,
	EAGLE_IDLE4,
	EAGLE_IDLE5,
	EAGLE_SHOOT,
	EAGLE_SHOOT_EMPTY,
	EAGLE_RELOAD,
	EAGLE_RELOAD_NOSHOT,
	EAGLE_DRAW,
	EAGLE_HOLSTER
};

void
w_eagle_precache(void)
{
#ifdef SERVER
	precache_model("models/w_desert_eagle.mdl");
	precache_sound("weapons/desert_eagle_fire.wav");
	precache_sound("weapons/desert_eagle_sight.wav");
	precache_sound("weapons/desert_eagle_sight2.wav");
#else
	precache_model("models/v_desert_eagle.mdl");
	precache_model("models/p_desert_eagle.mdl");
#endif
}

int
w_eagle_pickup(player pl, int new, int startammo)
{
#ifdef SERVER

	if (new) {
		pl.eagle_mag = 7;
	} else {
		if (pl.ammo_357 < MAX_A_357) {
			pl.ammo_357 = bound(0, pl.ammo_357 + 7, MAX_A_357);
		} else {
			return (0);
		}
	}
#endif
	return (1);
}

void
w_eagle_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.eagle_mag, pl.ammo_357, -1);
}

string
w_eagle_wmodel(void)
{
	return "models/w_desert_eagle.mdl";
}
string
w_eagle_pmodel(player pl)
{
	return "models/p_desert_eagle.mdl";
}
string
w_eagle_deathmsg(void)
{
	return "";
}

void
w_eagle_draw(player pl)
{
	Weapons_SetModel("models/v_desert_eagle.mdl");
	Weapons_ViewAnimation(pl, EAGLE_DRAW);
}

void
w_eagle_holster(player pl)
{
	Weapons_ViewAnimation(pl, EAGLE_HOLSTER);
}

void
w_eagle_release(player pl)
{

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.eagle_mag == 0 && pl.ammo_357 > 0) {
		Weapons_Reload(pl);
		return;
	}

	if (pl.w_idle_next) {
		return;
	}

	if (pl.eagle_mag <= 0) {
		return;
	}

	int r = (float)input_sequence % 4;
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, EAGLE_IDLE1);
		pl.w_idle_next = 2.5f;
		break;
	case 1:
		Weapons_ViewAnimation(pl, EAGLE_IDLE2);
		pl.w_idle_next = 2.5f;
		break;
	case 2:
		Weapons_ViewAnimation(pl, EAGLE_IDLE3);
		pl.w_idle_next = 1.633333f;
		break;
	default:
		Weapons_ViewAnimation(pl, EAGLE_IDLE4);
		pl.w_idle_next = 2.5f;
	}
}

void
w_eagle_primary(player pl)
{
	if (pl.w_attack_next > 0.0) {
		return;
	}

	if (pl.eagle_mag <= 0) {
		return;
	}

	/* Actual firing */
	if (pl.mode_eagle == 1) {
#ifdef SERVER
		TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 34, [0, 0], WEAPON_EAGLE);
#endif
		pl.w_attack_next = 0.5f;
	} else {
#ifdef SERVER
		TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 34,  [0.1,0.1], WEAPON_EAGLE);
#endif
		pl.w_attack_next = 0.2f;
	}

	pl.eagle_mag--;
	Weapons_ViewPunchAngle(pl, [-10,0,0]);

	if (pl.eagle_mag <= 0) {
		Weapons_ViewAnimation(pl, EAGLE_SHOOT_EMPTY);
	} else {
		Weapons_ViewAnimation(pl, EAGLE_SHOOT);
	}

#ifdef SERVER
	sound(pl, CHAN_WEAPON, "weapons/desert_eagle_fire.wav", 1, ATTN_NORM);
#else
	View_SetMuzzleflash(MUZZLE_SMALL);
#endif
	pl.w_idle_next = 10.0f;
}

void
w_eagle_secondary(player pl)
{

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* toggle laser */
	pl.mode_eagle = 1 - pl.mode_eagle;

#ifdef SERVER
	if (pl.mode_eagle) {
		sound(pl, 8, "weapons/desert_eagle_sight.wav", 1, ATTN_NORM);
	} else {
		sound(pl, 8, "weapons/desert_eagle_sight2.wav", 1, ATTN_NORM);
	}
#endif

	pl.w_attack_next = 1.0f;
	w_eagle_release(pl);
}

void
w_eagle_reload(player pl)
{

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* Ammo check */
	if (pl.eagle_mag >= 7) {
		return;
	}
	if (pl.ammo_357 <= 0) {
		return;
	}

	if (pl.eagle_mag <= 0) {
		Weapons_ViewAnimation(pl, EAGLE_RELOAD);
	} else {
		Weapons_ViewAnimation(pl, EAGLE_RELOAD_NOSHOT);
	}

	/* Audio-Visual bit */
#ifdef SERVER
	static void w_eagle_reload_done(void) {
		player pl = (player)self;
		Weapons_ReloadWeapon(pl, player::eagle_mag, player::ammo_357, 7);
	}

	pl.think = w_eagle_reload_done;
	pl.nextthink = time + 1.64f;
#endif

	pl.w_attack_next = 1.64f;
	pl.w_idle_next = 10.0f;
}

void
w_eagle_crosshair(player pl)
{
#ifdef CLIENT
	vector aicon_pos;

	/* crosshair/laser */
	if (pl.mode_eagle == 1) {
		float lerp;
		vector jitter = g_vec_null;
		Weapons_MakeVectors(pl);
		vector src = pl.origin + pl.view_ofs;
		vector cross_pos;
		traceline(src, src + (v_forward * 256), FALSE, pl);
		lerp = Math_Lerp(18,6, trace_fraction);
		jitter[0] = (random(0,2) - 2) * (1 - trace_fraction);
		jitter[1] = (random(0,2) - 2) * (1 - trace_fraction);
		cross_pos = g_hudmins + (g_hudres / 2) + ([-lerp,-lerp] / 2);
		drawsubpic(
			cross_pos + jitter,
			[lerp,lerp],
			"sprites/laserdot.spr_0.tga",
			[0,0],
			[1.0, 1.0],
			[1,1,1],
			1.0f,
			DRAWFLAG_ADDITIVE
		);
	} else {
		Cross_DrawSub(
			"sprites/ofch1.spr_0.tga",
			[24,24],
			[0,0],
			[24/72, 24/72]
		);
	}

	/* ammo counters */
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();

	/* ammo icon */
	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(
		aicon_pos,
		[24,24],
		"sprites/640hud7.spr_0.tga",
		[24/256,72/128],
		[24/256, 24/128],
		g_hud_color,
		pSeatLocal->m_flAmmo2Alpha,
		DRAWFLAG_ADDITIVE
	);
#endif
}

float
w_eagle_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMPYTHON : ANIM_AIMPYTHON;
}

int
w_eagle_isempty(player pl)
{

	if (pl.eagle_mag <= 0 && pl.ammo_357 <= 0)
		return 1;

	return 0;
}

void
w_eagle_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (w_eagle_isempty(pl))
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hudof02.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hudof01.spr_0.tga",
			[0,90/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}

	HUD_DrawAmmoBar(pos, pl.ammo_357, MAX_A_357, a);
#endif
}

weapon_t w_eagle =
{
	.name		= "eagle",
	.id		= ITEM_EAGLE,
	.slot		= 1,
	.slot_pos	= 2,
	.draw		= w_eagle_draw,
	.holster	= w_eagle_holster,
	.primary	= w_eagle_primary,
	.secondary	= w_eagle_secondary,
	.reload		= w_eagle_reload,
	.release	= w_eagle_release,
	.postdraw	= w_eagle_crosshair,
	.precache	= w_eagle_precache,
	.pickup		= w_eagle_pickup,
	.updateammo	= w_eagle_updateammo,
	.wmodel		= w_eagle_wmodel,
	.pmodel		= w_eagle_pmodel,
	.deathmsg	= w_eagle_deathmsg,
	.aimanim	= w_eagle_aimanim,
	.hudpic		= w_eagle_hudpic,
	.isempty	= w_eagle_isempty
};