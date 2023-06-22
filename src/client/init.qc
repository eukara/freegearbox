/*
 * Copyright (c) 2016-2020 Marco Cawthorne <marco@icculus.org>
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

float(entity foo, float chanid) getchannellevel = #0;
void VGUI_ChooseTeam(void);

/*
=================
ClientGame_Init

Comparable to worldspawn in SSQC in that it's mostly used for precaches
=================
*/
void
ClientGame_Init(float apilevel, string enginename, float engineversion)
{
	registercommand("changeteam");
	registercommand("changeclass");
	Obituary_Init();
}

void
ClientGame_InitDone(void)
{
	if (OP4_IsCTF()) {
		VGUI_ChooseTeam();
	}
}

void HLSprite_Init(void);
void
ClientGame_RendererRestart(string rstr)
{
	Nightvision_Init();
	Obituary_Precache();
	Damage_Precache();
	HLSprite_Init();

	FX_Blood_Init();
	FX_BreakModel_Init();
	FX_Explosion_Init();
	FX_GibHuman_Init();
	FX_Spark_Init();
	FX_Impact_Init();

	g_ofhud1_spr = spriteframe("sprites/640hudof01.spr", 0, 0.0f);
	g_ofhud2_spr = spriteframe("sprites/640hudof02.spr", 0, 0.0f);
	g_ofhud3_spr = spriteframe("sprites/640hudof03.spr", 0, 0.0f);
	g_ofhud4_spr = spriteframe("sprites/640hudof04.spr", 0, 0.0f);
	g_ofhud5_spr = spriteframe("sprites/640hudof05.spr", 0, 0.0f);
	g_ofhud6_spr = spriteframe("sprites/640hudof06.spr", 0, 0.0f);
	g_ofch1_spr = spriteframe("sprites/ofch1.spr", 0, 0.0f);
	g_ofch2_spr = spriteframe("sprites/ofch2.spr", 0, 0.0f);
	precache_model("sprites/320hudof01.spr");

	g_ctfhud1_spr = spriteframe("sprites/ctf_hud1.spr", 0, 0.0f);
	g_ctfhud2_spr = spriteframe("sprites/ctf_hud1.spr", 0, 0.0f);

	/* there's also muzzleflash.spr, but that's just MUZZLE_SMALL again */
	MUZZLE_RIFLE = (int)getmodelindex("sprites/muzzleflash1.spr");
	MUZZLE_SMALL = (int)getmodelindex("sprites/muzzleflash2.spr");
	MUZZLE_WEIRD = (int)getmodelindex("sprites/muzzleflash3.spr");

	BEAM_TRIPMINE = particleeffectnum("weapon_tripmine.beam");
}
