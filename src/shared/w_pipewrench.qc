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
	PIPE_IDLE1,
	PIPE_IDLE2,
	PIPE_IDLE3,
	PIPE_DRAW,
	PIPE_HOLSTER,
	PIPE_ATTACK1HIT,
	PIPE_ATTACK1MISS,
	PIPE_ATTACK2HIT,
	PIPE_ATTACK2MISS,
	PIPE_ATTACK3HIT,
	PIPE_ATTACK3MISS,
	PIPE_ATTACKBIGWIND,
	PIPE_ATTACKBIGHIT,
	PIPE_ATTACKBIGMISS,
	PIPE_ATTACKBIGLOOP
};

void
w_pipewrench_precache(void)
{
#ifdef SERVER
	precache_sound("weapons/pwrench_big_miss.wav");
	precache_sound("weapons/pwrench_big_hit1.wav");
	precache_sound("weapons/pwrench_big_hit2.wav");
	precache_sound("weapons/pwrench_big_hitbod1.wav");
	precache_sound("weapons/pwrench_big_hitbod2.wav");
	precache_sound("weapons/pwrench_miss1.wav");
	precache_sound("weapons/pwrench_miss2.wav");
	precache_sound("weapons/pwrench_hit1.wav");
	precache_sound("weapons/pwrench_hit2.wav");
	precache_sound("weapons/pwrench_hitbod1.wav");
	precache_sound("weapons/pwrench_hitbod2.wav");
	precache_sound("weapons/pwrench_hitbod3.wav");
	precache_model("models/w_pipe_wrench.mdl");
#else
	precache_model("models/p_pipe_wrench.mdl");
	precache_model("models/v_pipe_wrench.mdl");
#endif
}

void
w_pipewrench_updateammo(player pl)
{
	Weapons_UpdateAmmo(pl, -1, -1, -1);
}

string
w_pipewrench_wmodel(void)
{
	return "models/w_pipe_wrench.mdl";
}

string
w_pipewrench_pmodel(player pl)
{
	return "models/p_pipe_wrench.mdl";
}

string
w_pipewrench_deathmsg(void)
{
	return "%s was assaulted by %s's Pipewrench.";
}

void
w_pipewrench_draw(player pl)
{
	Weapons_SetModel("models/v_pipe_wrench.mdl");
	Weapons_ViewAnimation(pl, PIPE_DRAW);
}

void
w_pipewrench_holster(player pl)
{
	Weapons_ViewAnimation(pl, PIPE_HOLSTER);
}

void
w_pipewrench_primary(player pl)
{
	int anim = 0;
	vector src;

	if (pl.w_attack_next) {
		return;
	}

	Weapons_MakeVectors(pl);
	src = Weapons_GetCameraPos(pl);
	traceline(src, src + (v_forward * 32), FALSE, pl);

	if (trace_fraction >= 1.0) {
		pl.w_attack_next = 0.7f;
	} else {
		pl.w_attack_next = 0.53f;
	}
	pl.w_idle_next = 2.5f;

	int r = (float)input_sequence % 3;
	switch (r) {
	case 0:
		anim = trace_fraction >= 1 ? PIPE_ATTACK1MISS:PIPE_ATTACK1HIT;
		break;
	case 1:
		anim = trace_fraction >= 1 ? PIPE_ATTACK2MISS:PIPE_ATTACK2HIT;
		break;
	default:
		anim = trace_fraction >= 1 ? PIPE_ATTACK3MISS:PIPE_ATTACK3HIT;
	}
	Weapons_ViewAnimation(pl, anim);

	if (pl.flags & FL_CROUCHING) {
		Animation_PlayerTop(pl, ANIM_SHOOTCROWBAR, 0.5f);
	} else {
		Animation_PlayerTop(pl, ANIM_CR_SHOOTCROWBAR, 0.42f);
	}

#ifdef SERVER
	sound(pl, CHAN_WEAPON, "weapons/pwrench_miss1.wav", 1, ATTN_NORM);

	if (trace_fraction >= 1.0) {
		return;
	}

	/* don't bother with decals, we got squibs */
	if (trace_ent.iBleeds) {
		FX_Blood(trace_endpos, [1,0,0]);
	} else {
		SurfData_Impact(trace_ent, trace_endpos, trace_plane_normal);
	}

	if (trace_ent.takedamage) {
		Damage_Apply(trace_ent, self, 10, WEAPON_PIPEWRENCH, DMG_BLUNT);

		if (!trace_ent.iBleeds) {
			return;
		}

		if (random() < 0.33) {
			sound(pl, 8, "weapons/pwrench_hitbod1.wav", 1, ATTN_NORM);
		} else if (random() < 0.66) {
			sound(pl, 8, "weapons/pwrench_hitbod2.wav", 1, ATTN_NORM);
		} else {
			sound(pl, 8, "weapons/pwrench_hitbod3.wav", 1, ATTN_NORM);
		}
	} else {
		if (random() < 0.5) {
			sound(pl, 8, "weapons/pwrench_hit1.wav", 1, ATTN_NORM);
		} else {
			sound(pl, 8, "weapons/pwrench_hit2.wav", 1, ATTN_NORM);
		}
	}
#endif
}

void
w_pipewrench_secondary(player pl)
{

	if (!pl.w_attack_next) {
		/* Hack */
		if (pl.mode_wrench != 1) {
			Weapons_ViewAnimation(pl, PIPE_ATTACKBIGWIND);
			pl.mode_wrench = 1;
			pl.w_attack_next = 0.75f;
		}
	}
	pl.w_idle_next = 2.5f;
}

void
w_pipewrench_release(player pl)
{
	vector src;

	if (pl.w_attack_next > 0.0) {
		return;
	}

	if (pl.mode_wrench == 1) {
	#ifdef SERVER
		int hitsound = 0;
		string snd;
	#endif
		/* attack! */
		Weapons_MakeVectors(pl);
		src = Weapons_GetCameraPos(pl);
		traceline(src, src + (v_forward * 64), FALSE, pl);

		if (trace_fraction < 1.0) {
		#ifdef SERVER
			if (trace_ent.takedamage == DAMAGE_YES) {
				hitsound = floor(random(1, 2));
				/* TODO Damage is 45 - 200+ (?) */
				Damage_Apply(trace_ent, pl, 200, WEAPON_PIPEWRENCH, DMG_BLUNT);
			} else {
				hitsound = 3;
			}

			/* don't bother with decals, we got squibs */
			if (trace_ent.iBleeds) {
				FX_Blood(trace_endpos, [1,0,0]);
			} else {
				SurfData_Impact(trace_ent, trace_endpos, trace_plane_normal);
			}
		#endif
			Weapons_ViewAnimation(pl, PIPE_ATTACKBIGHIT);
			Weapons_ViewPunchAngle(pl, [-10,0,0]);
		} else {
			Weapons_ViewAnimation(pl, PIPE_ATTACKBIGMISS);
		}
#ifdef SERVER
		snd = "weapons/pwrench_big_miss.wav";
		switch (hitsound) {
		case 1:
			snd = "weapons/pwrench_big_hitbod1.wav";
			break;
		case 2:
			snd = "weapons/pwrench_big_hitbod2.wav";
			break;
		case 3:
			snd = "weapons/pwrench_big_hit1.wav";
			break;
		}
		sound(pl, CHAN_WEAPON, snd, 1.0f, ATTN_NORM);
#endif
		pl.w_attack_next = 1.0f;
		pl.w_idle_next = 10.0f;
		pl.mode_wrench = 0;
	}

	/* Pure cosmetics start here */
	if (pl.w_idle_next > 0.0) {
		return;
	}

	int r = floor(random(0,3));
	switch (r) {
	case 0:
		Weapons_ViewAnimation(pl, PIPE_IDLE1);
		pl.w_idle_next = 2.0f;
		break;
	case 1:
		Weapons_ViewAnimation(pl, PIPE_IDLE2);
		pl.w_idle_next = 3.0f;
		break;
	case 2:
		Weapons_ViewAnimation(pl, PIPE_IDLE3);
		pl.w_idle_next = 3.0f;
		break;
	}
}

float
w_pipewrench_aimanim(player pl)
{
	return self.flags & FL_CROUCHING ? ANIM_CR_AIMCROWBAR : ANIM_AIMCROWBAR;
}

void
w_pipewrench_hudpic(player pl, int selected, vector pos, float a)
{
#ifdef CLIENT
	if (selected) {
		drawsubpic(
			pos,
			[170,45],
			g_ofhud2_spr,
			[0,0],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	} else {
		drawsubpic(
			pos,
			[170,45],
			g_ofhud1_spr,
			[0,0],
			[170/256,45/256],
			g_hud_color,
			a,
			DRAWFLAG_ADDITIVE
		);
	}
#endif
}

weapon_t w_pipewrench =
{
	.name		= "pipewrench",
	.id		= ITEM_PIPEWRENCH,
	.slot		= 0,
	.slot_pos	= 1,
	.draw		= w_pipewrench_draw,
	.holster	= w_pipewrench_holster,
	.primary	= w_pipewrench_primary,
	.secondary	= w_pipewrench_secondary,
	.reload		= w_pipewrench_release,
	.release	= w_pipewrench_release,
	.postdraw	= __NULL__,
	.precache	= w_pipewrench_precache,
	.pickup		= __NULL__,
	.updateammo	= w_pipewrench_updateammo,
	.wmodel		= w_pipewrench_wmodel,
	.pmodel		= w_pipewrench_pmodel,
	.deathmsg	= w_pipewrench_deathmsg,
	.aimanim	= w_pipewrench_aimanim,
	.hudpic		= w_pipewrench_hudpic
};