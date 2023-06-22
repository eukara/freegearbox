/*
 * Copyright (c) 2016-2023 Marco Cawthorne <marco@icculus.org>
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

class OP4CTFRules:HLMultiplayerRules
{
	void OP4CTFRules(void);

	virtual void InitPostEnts(void);
	virtual void PlayerSpawn(NSClientPlayer);
	virtual void PlayerDeath(NSClientPlayer);
	virtual void PlayerConnect(NSClientPlayer);
	virtual void PlayerDisconnect(NSClientPlayer);

	nonvirtual void CharacterSpawn(NSClientPlayer, string);
	nonvirtual void CaptureFlag(NSClientPlayer);
	nonvirtual void DropFlag(NSClientPlayer);
};
