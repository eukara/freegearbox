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

var string g_nightvision_a;
var string g_nightvision_b;
var string g_nightvision_c;
var string g_nightvision_d;
var string g_nightvision_e;
var string g_nightvision_i;

void
Nightvision_Init(void)
{
	g_nightvision_a = spriteframe("sprites/of_nv_a.spr", 0, 0.0f);
	g_nightvision_b = spriteframe("sprites/of_nv_a.spr", 1, 0.0f);
	g_nightvision_c = spriteframe("sprites/of_nv_a.spr", 2, 0.0f);
	g_nightvision_d = spriteframe("sprites/of_nv_a.spr", 3, 0.0f);
	g_nightvision_e = spriteframe("sprites/of_nv_a.spr", 4, 0.0f);
	g_nightvision_i = spriteframe("sprites/of_nv_int.spr", 0, 0.0f);
}

void
Nightvision_PreDraw(void) 
{
	player pl = (player)pSeat->m_ePlayer;

	if (!(pl.gflags & GF_FLASHLIGHT))
		return;

	dynamiclight_add(pSeat->m_vecPredictedOrigin, 768, [0.35,0.35,0.35]);
}

void
Nightvision_PostDraw(void)
{
	player pl = (player)pSeat->m_ePlayer;

	if (!(pl.gflags & GF_FLASHLIGHT))
		return;

	drawpic(video_mins, "fade_modulate", video_res, [0,1,0], 1.0f, 0);

	int r = (time * 10) % 4;

	switch (r) {
	case 1:
		drawpic(video_mins, g_nightvision_a, video_res, [0,1,0], 0.2f, 1);
		break;
	case 2:
		drawpic(video_mins, g_nightvision_b, video_res, [0,1,0], 0.2f, 1);
		break;
	case 3:
		drawpic(video_mins, g_nightvision_c, video_res, [0,1,0], 0.2f, 1);
		break;
	default:
		drawpic(video_mins, g_nightvision_d, video_res, [0,1,0], 0.2f, 1);
		break;
	}

	drawpic(video_mins, g_nightvision_i, video_res, [0,1,0], 0.05f, 1);
}
