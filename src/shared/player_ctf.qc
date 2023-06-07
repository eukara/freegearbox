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

#ifdef SERVER
void
player::PowerupThink(void)
{
	if (m_flPickUpTime > time)
		return;

	if (g_items & ITEM_CTF_SHIELD) {
		armor += 1;
		m_flPickUpTime = time + 0.5f;
	} else if (g_items & ITEM_CTF_HEALTH) {
		health += 1;
		m_flPickUpTime = time + 0.5f;
	} else if (g_items & ITEM_CTF_BACKPACK) {
		print("add ammo!\n");
		m_flPickUpTime = time + 0.5f;
	}
}
#endif