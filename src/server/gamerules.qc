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

bool
HLGameRules::IsMultiplayer(void)
{
	return true;
}

/* we check what fields have changed over the course of the frame and network
 * only the ones that have actually changed */
void
HLGameRules::PlayerPostFrame(ncPlayer pp)
{
}

void
HLGameRules::LevelNewParms(void)
{
	parm1 = parm2 = parm3 = parm4 = parm5 = parm6 = parm7 =
	parm8 = parm9 = parm10 = parm11 = parm12 = parm13 = parm14 =
	parm15 = parm16 = parm17 = parm18 = parm19 = parm20 = parm21 =
	parm22 = parm23 = parm24 = parm25 = parm26 = parm27 = parm28 =
	parm29 = parm30 = 0;
	parm64 = FL_CLIENT;
}

void
HLGameRules::LevelDecodeParms(ncPlayer pp)
{
	OP4Player pl = (OP4Player)pp;
	g_landmarkpos[0] = parm1;
	g_landmarkpos[1] = parm2;
	g_landmarkpos[2] = parm3;
	pl.angles[0] = parm4;
	pl.angles[1] = parm5;
	pl.angles[2] = parm6;
	pl.velocity[0] = parm7;
	pl.velocity[1] = parm8;
	pl.velocity[2] = parm9;
	pl.g_items = parm10;
	pl.activeweapon = parm11;
	pl.flags = parm64;
}

void
HLGameRules::LevelChangeParms(ncPlayer pp)
{
	OP4Player pl = (OP4Player)pp;
	parm1 = g_landmarkpos[0];
	parm2 = g_landmarkpos[1];
	parm3 = g_landmarkpos[2];
	parm4 = pl.angles[0];
	parm5 = pl.angles[1];
	parm6 = pl.angles[2];
	parm7 = pl.velocity[0];
	parm8 = pl.velocity[1];
	parm9 = pl.velocity[2];
	parm64 = pl.flags;
	parm10 = pl.g_items;
	parm11 = pl.activeweapon;
}

void
HLGameRules::PlayerConnect(ncPlayer pl)
{
	if (Plugin_PlayerConnect(pl) == FALSE)
		bprint(PRINT_HIGH, sprintf("%s connected\n", pl.netname));
}

void
HLGameRules::PlayerDisconnect(ncPlayer pl)
{
	bprint(PRINT_HIGH, sprintf("%s disconnected\n", pl.netname));

	/* Make this unusable */
	pl.solid = SOLID_NOT;
	pl.movetype = MOVETYPE_NONE;
	pl.modelindex = 0;
	pl.health = 0;
	pl.takedamage = 0;
	pl.SendFlags = PLAYER_MODELINDEX;
}

void
TriggerFlashlight(ncClient target)
{
	entity oldself = self;
	self = target;
	Flashlight_Toggle();
	self = oldself;
}

void
DropCTFItem(ncPlayer pl)
{
	string item;

	if (pl.classname != "player")
		return;

	if (pl.g_items & ITEM_CTF_JUMPPACK) {
		item = "item_ctflongjump";
		pl.g_items &= ~ ITEM_CTF_JUMPPACK;
	} else if (pl.g_items & ITEM_CTF_SHIELD) {
		item = "item_ctfportablehev";
		pl.g_items &= ~ ITEM_CTF_SHIELD;
	} else if (pl.g_items & ITEM_CTF_HEALTH) {
		item = "item_ctfregeneration";
		pl.g_items &= ~ ITEM_CTF_HEALTH;
	} else if (pl.g_items & ITEM_CTF_DEATH) {
		item = "item_ctfaccelerator";
		pl.g_items &= ~ ITEM_CTF_DEATH;
	} else if (pl.g_items & ITEM_CTF_BACKPACK) {
		item = "item_ctfbackpack";
		pl.g_items &= ~ ITEM_CTF_BACKPACK;
	}
}

bool
HLGameRules::ImpulseCommand(ncClient bp, float num)
{
	switch (num) {
	case 100:
		TriggerFlashlight(bp);
		break;
	case 205:
		DropCTFItem((OP4Player)bp);
		break;
	default:
		return super::ImpulseCommand(bp, num);
	}

	return true;
}