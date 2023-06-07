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

/*QUAKED info_ctfspawn (0 0.8 0.8) (-16 -16 -36) (16 16 36)
# OVERVIEW
CTF Player Start

# KEYS
- "team_no" : Team

# TRIVIA
This entity was introduced in Half-Life: Opposing Force (1999)
*/

class
info_ctfspawn:NSEntity
{
	void info_ctfspawn(void);

	virtual void Respawn(void);
	virtual void SpawnKey(string, string);
};

void
info_ctfspawn::info_ctfspawn(void)
{

}

void
info_ctfspawn::SpawnKey(string strKey, string strValue)
{
	switch (strKey) {
	case "team_no":
		team = ReadFloat(strValue);
		break;
	default:
		super::SpawnKey(strKey, strValue);
	}
}

void
info_ctfspawn::Respawn(void)
{
	SetOrigin(GetSpawnOrigin());
	SetSolid(SOLID_NOT);

	classname = strcat("info_ctfspawn_", ftos(team));
}