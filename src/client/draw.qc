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

void HUD_DrawNums(float fNumber, vector vecPos, float fAlpha, vector vColor);

void
OP4CTF_DrawHud(player pl)
{
	vector iconPos = g_vec_null;
	vector iconBMOfs = g_vec_null;
	vector iconOP4Ofs = g_vec_null;

	bool myTeam = getplayerkeyfloat(player_localnum, "*team");

	iconPos = g_hudmins + [16, g_hudres[1] - 142];

	if (serverkeyfloat("ctfflag_1") == CTFFLAG_IDLE)
		iconBMOfs = [67/256, 77/256];
	else if (serverkeyfloat("ctfflag_1") == CTFFLAG_TAKEN && myTeam == 1)
		iconBMOfs = [105/256, 77/256];
	else if (serverkeyfloat("ctfflag_1") == CTFFlAG_MISSING)
		iconBMOfs = [143/256, 77/256];
	else if (serverkeyfloat("ctfflag_1") == CTFFLAG_TAKEN )
		iconBMOfs = [181/256, 77/256];

	if (serverkeyfloat("ctfflag_2") == CTFFLAG_IDLE)
		iconOP4Ofs = [67/256, 77/256];
	else if (serverkeyfloat("ctfflag_2") == CTFFLAG_TAKEN && myTeam == 2)
		iconOP4Ofs = [105/256, 77/256];
	else if (serverkeyfloat("ctfflag_2") == CTFFlAG_MISSING)
		iconOP4Ofs = [143/256, 77/256];
	else if (serverkeyfloat("ctfflag_2") == CTFFLAG_TAKEN)
		iconOP4Ofs = [181/256, 77/256];

	/* black mesa team flag */
	drawsubpic(
		iconPos,
		[38, 38],
		g_ctfhud1_spr,
		iconBMOfs,
		[38/256, 38/256],
		[1,1,0],
		1.0f,
		DRAWFLAG_ADDITIVE
	);
	HUD_DrawNums(serverkeyfloat("teamscore_1"), iconPos + [64, 6], 1.0, [1,1,0]);

	/* opfor team flag */
	drawsubpic(
		iconPos + [0, 38],
		[38, 38],
		g_ctfhud1_spr,
		iconOP4Ofs,
		[38/256, 38/256],
		[0,1,0],
		1.0f,
		DRAWFLAG_ADDITIVE
	);
	HUD_DrawNums(serverkeyfloat("teamscore_2"), iconPos + [64, 44], 1.0, [0,1,0]);
}

void
ClientGame_PreDraw(void) 
{
	Nightvision_PreDraw();
}

void
ClientGame_PostDraw(void)
{
	Nightvision_PostDraw();

	/* CTF Power-Up icons */
	{
		player pl = (player)pSeat->m_ePlayer;
		vector pickupPos;
		pickupPos = g_hudmins + [16, (g_hudres[1] / 2) - 32];

		if (OP4_IsCTF()) {
			OP4CTF_DrawHud(pl);
		}

		if (pl.g_items & ITEM_CTF_HEALTH) {
			drawsubpic(
				pickupPos,
				[64, 64],
				g_ctfhud1_spr,
				[0, 0],
				[0.25, 0.25],
				[0,1,0],
				1.0f,
				DRAWFLAG_ADDITIVE
			);
		}
		if (pl.g_items & ITEM_CTF_DEATH) {
			drawsubpic(
				pickupPos,
				[64, 64],
				g_ctfhud1_spr,
				[0.25, 0],
				[0.25, 0.25],
				[1,0,0],
				1.0f,
				DRAWFLAG_ADDITIVE
			);
		}
		if (pl.g_items & ITEM_CTF_JUMPPACK) {
			drawsubpic(
				pickupPos,
				[64, 64],
				g_ctfhud1_spr,
				[0.5, 0],
				[0.25, 0.25],
				[1,0.5,0],
				1.0f,
				DRAWFLAG_ADDITIVE
			);
		}
		if (pl.g_items & ITEM_CTF_SHIELD) {
			drawsubpic(
				pickupPos,
				[64, 64],
				g_ctfhud1_spr,
				[0.75, 0],
				[0.25, 0.25],
				[0.25,0.25,1],
				1.0f,
				DRAWFLAG_ADDITIVE
			);
		}
		if (pl.g_items & ITEM_CTF_BACKPACK) {
			drawsubpic(
				pickupPos,
				[64, 64],
				g_ctfhud1_spr,
				[0, 0.25],
				[0.25, 0.25],
				[1,1,0],
				1.0f,
				DRAWFLAG_ADDITIVE
			);
		}
			
	}
}
