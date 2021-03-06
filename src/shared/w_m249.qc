/*
 * Copyright (c) 2016-2021 Marco Hladik <marco@icculus.org>
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

/*QUAKED weapon_m249 (0 0 1) (-16 -16 0) (16 16 32)
"model" "models/w_saw.mdl"

HALF-LIFE: OPPOSING FORCE (1999) ENTITY

M249 Weapon

*/

/* Animations */
enum
{
	M249_IDLE1,
	M249_IDLE2,
	M249_RELOAD1,
	M249_RELOAD2,
	M249_HOLSTER,
	M249_DRAW,
	M249_FIRE
};

void
w_m249_precache(void)
{
#ifdef SERVER
	precache_model("models/w_saw.mdl");
	precache_sound("weapons/saw_fire1.wav");
	precache_sound("weapons/saw_fire2.wav");
	precache_sound("weapons/saw_fire3.wav");
	precache_sound("weapons/saw_reload.wav");
	precache_sound("weapons/saw_reload2.wav");
#else
	precache_model("models/v_saw.mdl");
	precache_model("models/p_saw.mdl");
#endif
}

int 
w_m249_pickup(int new, int startammo)
{
#ifdef SERVER
	player pl = (player)self;

	if (new) {
		pl.m249_mag = 50;
	} else {
		if (pl.ammo_556 < MAX_A_556) {
			pl.ammo_556 = bound(0, pl.ammo_556 + 50, MAX_A_556);
		} else {
			return (0);
		}
	}
#endif
	return (1);
}

void
w_m249_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, pl.m249_mag, pl.ammo_556, -1);
}

string
w_m249_wmodel(void)
{
	return "models/w_saw.mdl";
}

string
w_m249_pmodel(void)
{
	return "models/p_saw.mdl";
}

string
w_m249_deathmsg(void)
{
	return "";
}

void
w_m249_draw(void)
{
	Weapons_SetModel("models/v_saw.mdl");
	Weapons_ViewAnimation(M249_DRAW);
}

void
w_m249_holster(void)
{
	Weapons_ViewAnimation(M249_DRAW);
}

void
w_m249_release(void)
{
	player pl = (player)self;

	/* auto-reload if need be */
	if (pl.w_attack_next <= 0.0)
	if (pl.mode_m249 == 0 && pl.m249_mag == 0 && pl.ammo_556 > 0) {
		Weapons_Reload();
		return;
	}

	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.mode_m249 == 1) {
		Weapons_ViewAnimation(M249_RELOAD2);
		pl.mode_m249 = 0;
		pl.w_attack_next = 2.45f;
		pl.w_idle_next = 15.0f;
		return;
	}

	int r = (float)input_sequence % 2;
	if (r < 1) {
		Weapons_ViewAnimation(M249_IDLE1);
	} else {
		Weapons_ViewAnimation(M249_IDLE2);
	}

	pl.w_idle_next = 15.0f;
}

void
w_m249_primary(void)
{
	player pl = (player)self;
	vector push;

	if (pl.mode_m249 == 1) {
		w_m249_release();
		return;
	}

	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* ammo check */
	if (pl.m249_mag <= 0) {
		return;
	}

	Weapons_ViewPunchAngle([-5,0,0]);
	Weapons_ViewAnimation(M249_FIRE);

	push = v_forward * -64;
	push[2] *= 0.25f; /* gravity duh */
	pl.velocity += push;
	pl.m249_mag--;

	/* actual firing */
#ifdef CLIENT
	View_SetMuzzleflash(MUZZLE_RIFLE);
#else
	TraceAttack_FireBullets(1, pl.origin + pl.view_ofs, 8, [0.052,0.052], WEAPON_M249);

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		sound(pl, CHAN_WEAPON, "weapons/saw_fire1.wav", 1, ATTN_NORM);
		break;
	case 1:
		sound(pl, CHAN_WEAPON, "weapons/saw_fire2.wav", 1, ATTN_NORM);
		break;
	default:
		sound(pl, CHAN_WEAPON, "weapons/saw_fire3.wav", 1, ATTN_NORM);
	}
#endif

	pl.w_attack_next = 0.075f;
	pl.w_idle_next = 10.0f;
}

void
w_m249_reload(void)
{
	player pl = (player)self;

	if (pl.w_attack_next > 0.0) {
		w_m249_release();
		return;
	}

	if (pl.m249_mag >= 50)
		return;
	if (pl.ammo_556 <= 0)
		return;

	Weapons_ViewAnimation(M249_RELOAD1);

#ifdef SERVER
	static void w_m249_reload_done(void) {
		player pl = (player)self;
		Weapons_ReloadWeapon(pl, player::m249_mag, player::ammo_556, 50);
	}

	pl.think = w_m249_reload_done;
	pl.nextthink = time +  3.95f;
#endif

	pl.mode_m249 = 1;
	pl.w_attack_next = pl.w_idle_next = 1.5f;
}

void
w_m249_crosshair(void)
{
#ifdef CLIENT
	vector cross_pos;
	vector aicon_pos;

	/* crosshair */
	cross_pos = g_hudmins + (g_hudres / 2) + [-12,-12];
	drawsubpic(
		cross_pos,
		[24,24],
		"sprites/ofch1.spr_0.tga",
		[24/72,0],
		[24/72, 24/72],
		[1,1,1],
		1.0,
		DRAWFLAG_NORMAL
	);

	/* ammo counters */
	HUD_DrawAmmo1();
	HUD_DrawAmmo2();

	/* ammo icon */
	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];
	drawsubpic(
		aicon_pos,
		[24,24],
		"sprites/640hud7.spr_0.tga",
		[24/128,72/128],
		[24/256, 24/128],
		g_hud_color,
		pSeatLocal->m_flAmmo2Alpha,
		DRAWFLAG_ADDITIVE
	);
#endif
}

float
w_m249_aimanim(void)
{
	return self.flags & ANIM_CR_AIMMP5 ? ANIM_CR_AIMCROWBAR : ANIM_AIMMP5;
}

int
w_m249_isempty(void)
{
	player pl = (player)self;

	if (pl.m249_mag <= 0 && pl.ammo_556 <= 0)
		return 1;

	return 0;
}

void
w_m249_hudpic(int selected, vector pos, float a)
{
#ifdef CLIENT
	player pl = (player)self;
	vector hud_col;

	if (w_m249_isempty())
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_556, MAX_A_556, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			"sprites/640hudof02.spr_0.tga",
			[0,135/256],
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
			[0,135/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_m249 =
{
	.name		= "m249",
	.id		= ITEM_M249,
	.slot		= 5,
	.slot_pos	= 0,
	.draw		= w_m249_draw,
	.holster	= w_m249_holster,
	.primary	= w_m249_primary,
	.secondary	= __NULL__,
	.reload		= w_m249_reload,
	.release	= w_m249_release,
	.crosshair	= w_m249_crosshair,
	.precache	= w_m249_precache,
	.pickup		= w_m249_pickup,
	.updateammo	= w_m249_updateammo,
	.wmodel		= w_m249_wmodel,
	.pmodel		= w_m249_pmodel,
	.deathmsg	= w_m249_deathmsg,
	.aimanim	= w_m249_aimanim,
	.hudpic		= w_m249_hudpic,
	.isempty	= w_m249_isempty
};

#ifdef SERVER
void
weapon_m249(void)
{
	Weapons_InitItem(WEAPON_M249);
}
#endif
