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

enum
{
	DISP_IDLE1,
	DISP_IDLE2,
	DISP_SPINUP,
	DISP_SPIN,
	DISP_FIRE,
	DISP_DRAW,
	DISP_HOLSTER
};

#ifdef SERVER
entity Spawn_SelectRandom(string);
#endif

void
w_displacer_precache(void)
{
#ifdef SERVER
	precache_sound("weapons/displacer_impact.wav");
	precache_sound("weapons/displacer_fire.wav");
	precache_sound("weapons/displacer_self.wav");
	precache_sound("weapons/displacer_spin.wav");
	precache_sound("weapons/displacer_spin2.wav");
	precache_sound("weapons/displacer_start.wav");
	precache_sound("weapons/displacer_teleport.wav");
	precache_sound("weapons/displacer_teleport_player.wav");
	precache_model("models/w_displacer.mdl");
	precache_model("sprites/exit1.spr");
#else
	precache_model("models/v_displacer.mdl");
	precache_model("models/p_displacer.mdl");
#endif
}

void
w_displacer_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, pl.ammo_uranium, -1);
}

string
w_displacer_wmodel(void)
{
	return "models/w_displacer.mdl";
}

string
w_displacer_pmodel(player pl)
{
	return "models/p_displacer.mdl";
}

string
w_displacer_deathmsg(void)
{
	return "%s was assaulted by %s's Displacer.";
}

int
w_displacer_pickup(player pl, int new, int startammo)
{
#ifdef SERVER
	int addAmmo = (startammo == -1) ? 40 : startammo;

	if (pl.ammo_uranium < MAX_A_URANIUM) {
		pl.ammo_uranium = bound(0, pl.ammo_uranium + addAmmo, MAX_A_URANIUM);
	} else {
		return (0);
	}
#endif
	return (1);
}

void
w_displacer_draw(player pl)
{
	Weapons_SetModel("models/v_displacer.mdl");
	Weapons_ViewAnimation(pl, DISP_DRAW);
}

void
w_displacer_holster(player pl)
{
	Weapons_ViewAnimation(pl, DISP_HOLSTER);
}

void
w_displacer_teleport(entity target)
{
#ifdef SERVER
	player pl = (player)target;
	/* TODO, 250 damage */
	sound(pl, CHAN_WEAPON, "weapons/displacer_teleport.wav", 1, ATTN_NORM);
	
	/* FIXME: This will teleport upon your standard spawn positions
	 * in other game modes, such as CTF (your team spawns), no clue
	 * about singleplayer */
	entity spot = Spawn_SelectRandom("info_player_deathmatch");
	setorigin(pl, spot.origin);
#endif
}

void
w_displacer_fireball(player pl)
{
#ifdef SERVER

	static void displacerball_touch(void)
	{
		if (other.flags & FL_CLIENT) {
			w_displacer_teleport(other);
		}
		Damage_Radius(self.origin, self.owner, 250, 250 * 2.5f, TRUE, WEAPON_DISPLACER);
		sound(self, 1, "weapons/displacer_impact.wav", 1, ATTN_NORM);
		remove(self);
	}

	static void displacerball_animate(void)
	{
		self.frame++;
		
		if (self.frame > 25)
			self.frame = 0;
		
		self.nextthink = time + 0.1f;
	}

	Weapons_MakeVectors(pl);
	entity ball = spawn();

	setmodel(ball, "sprites/exit1.spr");
	setorigin(ball, Weapons_GetCameraPos(pl) + (v_forward * 16));
	ball.owner = self;
	ball.velocity = v_forward * 500;
	ball.movetype = MOVETYPE_FLYMISSILE;
	ball.solid = SOLID_BBOX;
	ball.angles = vectoangles(ball.velocity);
	ball.touch = displacerball_touch;
	ball.effects = EF_ADDITIVE;
	ball.think = displacerball_animate;
	ball.nextthink = time + 0.1f;
	setsize(ball, [0,0,0], [0,0,0]);
	sound(pl, CHAN_WEAPON, "weapons/displacer_fire.wav", 1, ATTN_NORM);
#endif
}

void
w_displacer_release(player pl)
{

	if (pl.w_idle_next > 0.0) {
		return;
	}

	if (pl.mode_displacer == 1) {
		Weapons_ViewAnimation(pl, DISP_FIRE);
		w_displacer_fireball(pl);
		pl.mode_displacer = 0;
		pl.w_idle_next = pl.w_attack_next = 1.0f;
		pl.ammo_uranium -= 20;
		return;
	} else if (pl.mode_displacer == 2) {
		Weapons_ViewAnimation(pl, DISP_FIRE);
		w_displacer_teleport(pl);
		pl.mode_displacer = 0;
		pl.w_idle_next = pl.w_attack_next = 1.0f;
		pl.ammo_uranium -= 60;
		return;
	}

	int r = (float)input_sequence % 3;
	if (r == 1) {
		Weapons_ViewAnimation(pl, DISP_IDLE1);
	} else {
		Weapons_ViewAnimation(pl, DISP_IDLE2);
	}

	pl.w_idle_next = 3.0f;
}

void
w_displacer_primary(player pl)
{
	if (pl.w_attack_next > 0.0) {
		return;
	}

	/* ammo check */
	if (pl.ammo_uranium < 20) {
		return;
	}

	/* we're already in spinning mode */
	if (pl.mode_displacer > 0) {
		w_displacer_release(pl);
		return;
	}

	pl.mode_displacer = 1;

	Weapons_ViewAnimation(pl, DISP_SPINUP);

#ifdef SERVER
	sound(pl, CHAN_WEAPON, "weapons/displacer_spin.wav", 1, ATTN_NORM);
#endif
	pl.w_idle_next = pl.w_attack_next = 1.0f;
}

void
w_displacer_secondary(player pl)
{

	if (pl.w_attack_next > 0.0) {
		return;
	}

	if (pl.ammo_uranium < 60) {
		return;
	}

	/* we're already in spinning mode */
	if (pl.mode_displacer > 0) {
		w_displacer_release(pl);
		return;
	}

	pl.mode_displacer = 2;
	Weapons_ViewAnimation(pl, DISP_SPINUP);

#ifdef SERVER
	sound(pl, CHAN_WEAPON, "weapons/displacer_spin2.wav", 1, ATTN_NORM);
#endif
	pl.w_idle_next = pl.w_attack_next = 1.0f;
}

float
w_displacer_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMSQUEAK : ANIM_AIMSQUEAK;
}

void
w_displacer_hud(player pl)
{
#ifdef CLIENT
	vector aicon_pos;

	aicon_pos = g_hudmins + [g_hudres[0] - 48, g_hudres[1] - 42];

	Cross_DrawSub(
		g_ofch1_spr,
		[24,24],
		[48/72,0],
		[24/72,24/72]
	);

	drawsubpic(
		aicon_pos,
		[24,24],
		"sprites/640hud7.spr_0.tga",
		[0,96/128], // was [24/256,72/128]... which makes 0 sense
		[24/256, 24/128],
		g_hud_color,
		pSeatLocal->m_flAmmo2Alpha,
		DRAWFLAG_ADDITIVE
	);

	HUD_DrawAmmo2();
#endif
}

int
w_displacer_isempty(player pl)
{

	if (pl.ammo_uranium <= 0)
		return 1;

	return 0;
}

void
w_displacer_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	vector hud_col;

	if (w_displacer_isempty(pl))
		hud_col = [1,0,0];
	else
		hud_col = g_hud_color;

	HUD_DrawAmmoBar(pos, pl.ammo_uranium, MAX_A_URANIUM, a);

	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_ofhud2_spr,
			[0,180/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			g_ofhud1_spr,
			[0,180/256],
			[170/256,45/256],
			hud_col,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_displacer =
{
	.name		= "displacer",
	.id		= ITEM_DISPLACER,
	.slot		= 5,
	.slot_pos	= 1,
	.draw		= w_displacer_draw,
	.holster	= w_displacer_holster,
	.primary	= w_displacer_primary,
	.secondary	= w_displacer_secondary,
	.reload		= __NULL__,
	.release	= w_displacer_release,
	.postdraw	= w_displacer_hud,
	.precache	= w_displacer_precache,
	.pickup		= w_displacer_pickup,
	.updateammo	= w_displacer_updateammo,
	.wmodel		= w_displacer_wmodel,
	.pmodel		= w_displacer_pmodel,
	.deathmsg	= w_displacer_deathmsg,
	.aimanim	= w_displacer_aimanim,
	.hudpic		= w_displacer_hudpic,
	.isempty	= w_displacer_isempty
};
