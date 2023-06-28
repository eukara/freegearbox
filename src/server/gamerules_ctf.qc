/*
 * Copyright (c) 2023 Marco Cawthorne <marco@icculus.org>
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

void
OP4CTFRules::OP4CTFRules(void)
{
}

void
OP4CTFRules::InitPostEnts(void)
{
	/* Opfor CTF only has two teams. */
	forceinfokey(world, "teams", "2");
	forceinfokey(world, "team_1", "Black Mesa");
	forceinfokey(world, "teamscore_1", "0");
	forceinfokey(world, "team_2", "Opposing Force");
	forceinfokey(world, "teamscore_2", "0");

	forceinfokey(world, "ctfflag_1", "0");
	forceinfokey(world, "ctfflag_2", "0");
	forceinfokey(world, "scorepoints", "1");

	Sound_Precache("op4ctf_bm.flag_taken");
	Sound_Precache("op4ctf_bm.flag_capture");

	Sound_Precache("op4ctf_op4.flag_taken");
	Sound_Precache("op4ctf_op4.flag_capture");
}

void
OP4CTFRules::PlayerConnect(NSClientPlayer pp)
{
	super::PlayerConnect(pp);
	pp.frags = 0;
	forceinfokey(pp, "*deaths", "0");
	forceinfokey(pp, "*score", "0");
	forceinfokey(pp, "*icon1", "");
	forceinfokey(pp, "*icon2", "");
}

void
OP4CTFRules::PlayerDisconnect(NSClientPlayer pl)
{
	DropFlag(pl);
	super::PlayerDisconnect(pl);
}

void
OP4CTFRules::PlayerSpawn(NSClientPlayer pp)
{
	player pl = (player)pp;

	/* not in a team yet, force them into spectator */
	if (pl.team == 0) {
		pl.MakeTempSpectator(); /* replace this with a non-spectator ghost */
		Spawn_ObserverCam(pl);
		return;
	}

	CharacterSpawn(pp, pl.m_oldModel);
}

void
OP4CTFRules::CharacterSpawn(NSClientPlayer playerEnt, string playerModel)
{
	player pl = (player)playerEnt;

	pl.m_oldModel = playerModel;
	pl.health = pl.max_health = 100;
	pl.SetTakedamage(DAMAGE_YES);
	pl.SetSolid(SOLID_SLIDEBOX);
	pl.SetMovetype(MOVETYPE_WALK);
	pl.SetModel(playerModel);
	pl.SetSize(VEC_HULL_MIN, VEC_HULL_MAX);
	pl.ClearVelocity();
	pl.flags = FL_CLIENT;
	pl.viewzoom = 1.0;

	pl.iBleeds = TRUE;
	pl.SetInfoKey("*spec", "0");
	pl.SetInfoKey("*dead", "0");

	/* give inventory */
	pl.g_items = ITEM_CROWBAR | ITEM_GLOCK | ITEM_SUIT;
	pl.activeweapon = WEAPON_GLOCK;
	pl.glock_mag = 18;
	pl.ammo_9mm = 44;

	entity spot = Spawn_SelectRandom(strcat("info_ctfspawn_", ftos(pl.team)));
	pl.Transport(spot.origin, spot.angles);
	Weapons_RefreshAmmo(pl);
	Client_FixAngle(pl, pl.angles);
}

void
OP4CTFRules::CaptureFlag(NSClientPlayer pp)
{
	player pl = (player)pp;
	NSEntity enemyFlag;
	string flagName;
	string teamScore;
	string captureSound;

	/* detach flag */
	pl.g_items &= ~ITEM_GOALITEM;
	pl.flagmodel = 0;
	pl.score += 10;
	forceinfokey(pl, "*icon1", "");

	if (pl.team == 1) {
		flagName = "info_ctfflag_2";
		teamScore = "teamscore_1";
		captureSound = "op4ctf_bm.flag_capture";
	} else {
		flagName = "info_ctfflag_1";
		teamScore = "teamscore_2";
		captureSound = "op4ctf_op4.flag_capture";
	}

	/* increment score */
	forceinfokey(world, teamScore, sprintf("%d", serverkeyfloat(teamScore) + 1));

	enemyFlag = (NSEntity)find(world, ::classname, flagName);

	if (!enemyFlag) {
		error("What the hell? There's no flag back there!");
		return;
	}

	enemyFlag.StartSoundDef(captureSound, CHAN_ITEM, true);
	enemyFlag.Respawn();
}

void
OP4CTFRules::PlayerDeath(NSClientPlayer pp)
{
	DropFlag(pp);
	super::PlayerDeath(pp);
}

void
OP4CTFRules::DropFlag(NSClientPlayer pp)
{
	player pl = (player)pp;
	item_ctfflag targetFlag;
	string flagName;

	/* skip normal players */
	if (!(pl.g_items & ITEM_GOALITEM))
		return;

	if (pl.team == 1) {
		flagName = "info_ctfflag_2";
	} else {
		flagName = "info_ctfflag_1";
	}

	for (entity e = world; (e = find(e, ::classname, flagName));) {
		targetFlag = (item_ctfflag)e;

		/* item is still pick-upable */
		if (targetFlag.GetSolid() != SOLID_NOT) {
			print("the item is not picked up. \n");
			continue;
		}

		/* that's us, yup */
		if (targetFlag.m_eActivator == pl) {
			targetFlag.FlagDrop(pl);
			return;
		}
	}

	print("^1WARNING: ^7Player marked as having impossible goal-item\n");
}

void
CSEv_TeamJoin_f(float teamChoice)
{
	self.team = teamChoice;
	forceinfokey(self, "*team", ftos(teamChoice));

	/* they'll become spectator */
	if (teamChoice == 0) {
		OP4CTFRules rule = (OP4CTFRules)g_grMode;
		rule.PlayerSpawn((NSClientPlayer)self);
	}
}

void
CSEv_ClassJoin_f(float classSelection)
{
	OP4CTFRules rule = (OP4CTFRules)g_grMode;
	string playerModel;
	player pl = (player)self;

	/* random black mesa char */
	if (classSelection == 0)
		classSelection = floor(random(1, 7));
	/* random opfor char */
	if (classSelection == 13)
		classSelection = floor(random(7, 13));

	switch (classSelection) {
	/* black mesa */
	case 1:
		playerModel = "models/player/ctf_barney/ctf_barney.mdl";
		break;
	case 2:
		playerModel = "models/player/cl_suit/cl_suit.mdl";
		break;
	case 3:
		playerModel = "models/player/ctf_gina/ctf_gina.mdl";
		break;
	case 4:
		playerModel = "models/player/ctf_gordon/ctf_gordon.mdl";
		break;
	case 5:
		playerModel = "models/player/otis/otis.mdl";
		break;
	case 6:
		playerModel = "models/player/ctf_scientist/ctf_scientist.mdl";
		break;
	/* opfor */
	case 7:
		playerModel = "models/player/beret/beret.mdl";
		break;
	case 8:
		playerModel = "models/player/drill/drill.mdl";
		break;
	case 9:
		playerModel = "models/player/grunt/grunt.mdl";
		break;
	case 10:
		playerModel = "models/player/recruit/recruit.mdl";
		break;
	case 11:
		playerModel = "models/player/shephard/shephard.mdl";
		break;
	case 12:
		playerModel = "models/player/tower/tower.mdl";
		break;
	}

	/* if we're alive, kill them (we need to drop the flag anyhow */
	if (pl.IsAlive()) {
		pl.m_oldModel = playerModel;
		rule.PlayerDeath(pl);
	} else {
		rule.CharacterSpawn((NSClientPlayer)self, playerModel);
	}
}