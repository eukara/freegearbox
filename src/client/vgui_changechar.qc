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

static string g_charDescrAdrian;
static string g_charDescrBarney;
static string g_charDescrCivRandom;
static string g_charDescrCleansuit;
static string g_charDescrDrillsgt;
static string g_charDescrGina;
static string g_charDescrGordon;
static string g_charDescrGrunt;
static string g_charDescrRandom;
static string g_charDescrOtis;
static string g_charDescrTandom;
static string g_charDescrRecruit;
static string g_charDescrScientist;
static string g_charDescrSquadleader;
static string g_charDescrTower;

static void
OP4Char_Init(void)
{
	g_charDescrAdrian = textfile_to_string("classes/short_adrian.txt");
	g_charDescrBarney = textfile_to_string("classes/short_barney.txt");
	g_charDescrCivRandom = textfile_to_string("classes/short_civ_random.txt");
	g_charDescrCleansuit = textfile_to_string("classes/short_cleansuit.txt");
	g_charDescrDrillsgt = textfile_to_string("classes/short_drillsgt.txt");
	g_charDescrGina = textfile_to_string("classes/short_gina.txt");
	g_charDescrGordon = textfile_to_string("classes/short_gordon.txt");
	g_charDescrGrunt = textfile_to_string("classes/short_grunt.txt");
	g_charDescrRandom = textfile_to_string("classes/short_op4_random.txt");
	g_charDescrOtis = textfile_to_string("classes/short_otis.txt");
	g_charDescrTandom = textfile_to_string("classes/short_random.txt");
	g_charDescrRecruit = textfile_to_string("classes/short_recruit.txt");
	g_charDescrScientist = textfile_to_string("classes/short_scientist.txt");
	g_charDescrSquadleader = textfile_to_string("classes/short_squadleader.txt");
	g_charDescrTower = textfile_to_string("classes/short_tower.txt");

}

static VGUIWindow winCharSelection;
static VGUIPic imgCharPreview;
static VGUILabel lblCharTitle;
static VGUILabel lblCharDescription;
static VGUILabel lblCharCounter;

class OP4CharButton:VGUIButton
{
	void OP4CharButton(void);

	virtual void OnMouseUp(void);
	virtual void OnMouseEntered(void);
};

void
OP4CharButton::OP4CharButton(void)
{
}

void
OP4CharButton::OnMouseUp(void)
{
	int classSelection = GetTag();
	sendevent("ClassJoin", "f", (float)classSelection);
	winCharSelection.Hide();
}

void
OP4CharButton::OnMouseEntered(void)
{
	int classSelection = GetTag();

	switch (classSelection) {
		case 1:
			lblCharTitle.SetTitle(Titles_GetTextBody("CTFTitle_Barney"));
			imgCharPreview.SetImage("gfx/vgui/640_barney");
			lblCharDescription.SetTitle(g_charDescrBarney);
			break;
		case 2:
			lblCharTitle.SetTitle(Titles_GetTextBody("CTFTitle_Cleansuit"));
			imgCharPreview.SetImage("gfx/vgui/640_cleansuit");
			lblCharDescription.SetTitle(g_charDescrCleansuit);
			break;
		case 3:
			lblCharTitle.SetTitle(Titles_GetTextBody("CTFTitle_Gina"));
			imgCharPreview.SetImage("gfx/vgui/640_gina");
			lblCharDescription.SetTitle(g_charDescrGina);
			break;
		case 4:
			lblCharTitle.SetTitle(Titles_GetTextBody("CTFTitle_Gordon"));
			imgCharPreview.SetImage("gfx/vgui/640_gordon");
			lblCharDescription.SetTitle(g_charDescrGordon);
			break;
		case 5:
			lblCharTitle.SetTitle(Titles_GetTextBody("CTFTitle_Otis"));
			imgCharPreview.SetImage("gfx/vgui/640_otis");
			lblCharDescription.SetTitle(g_charDescrOtis);
			break;
		case 6:
			lblCharTitle.SetTitle(Titles_GetTextBody("CTFTitle_Scientist"));
			imgCharPreview.SetImage("gfx/vgui/640_scientist");
			lblCharDescription.SetTitle(g_charDescrScientist);
			break;
		case 0:
			lblCharTitle.SetTitle(Titles_GetTextBody("CTFTitle_Civ_Random"));
			imgCharPreview.SetImage("gfx/vgui/640_civ_random");
			lblCharDescription.SetTitle(g_charDescrCivRandom);
			break;

		case 7:
			lblCharTitle.SetTitle(Titles_GetTextBody("CTFTitle_SquadLeader"));
			imgCharPreview.SetImage("gfx/vgui/640_squadleader");
			lblCharDescription.SetTitle(g_charDescrSquadleader);
			break;
		case 8:
			lblCharTitle.SetTitle(Titles_GetTextBody("CTFTitle_DrillSgt"));
			imgCharPreview.SetImage("gfx/vgui/640_drillsgt");
			lblCharDescription.SetTitle(g_charDescrDrillsgt);
			break;
		case 9:
			lblCharTitle.SetTitle(Titles_GetTextBody("CTFTitle_Grunt"));
			imgCharPreview.SetImage("gfx/vgui/640_grunt");
			lblCharDescription.SetTitle(g_charDescrGrunt);
			break;
		case 10:
			lblCharTitle.SetTitle(Titles_GetTextBody("CTFTitle_Recruit"));
			imgCharPreview.SetImage("gfx/vgui/640_recruit");
			lblCharDescription.SetTitle(g_charDescrRecruit);
			break;
		case 11:
			lblCharTitle.SetTitle(Titles_GetTextBody("CTFTitle_Adrian"));
			imgCharPreview.SetImage("gfx/vgui/640_adrian");
			lblCharDescription.SetTitle(g_charDescrAdrian);
			break;
		case 12:
			lblCharTitle.SetTitle(Titles_GetTextBody("CTFTitle_Tower"));
			imgCharPreview.SetImage("gfx/vgui/640_tower");
			lblCharDescription.SetTitle(g_charDescrTower);
			break;
		case 13:
			lblCharTitle.SetTitle(Titles_GetTextBody("CTFTitle_Op4_Random"));
			imgCharPreview.SetImage("gfx/vgui/640_op4_random");
			lblCharDescription.SetTitle(g_charDescrTandom);
			break;
	}
}


/*
Char/Char list:

Barney
CleansuitSci
Gina
Freeman
Otis
Walter(Scientist)
Random

Squad Leader
Drill Sgt
Grunt
Recruit
Shepard
Tower
OP4Random
*/

string g_classnames_blackmesa [] = {
	"Barney",
	"Cleansuit",
	"Gina",
	"Gordon",
	"Otis",
	"Scientist",
	"Civ_Random"
};

string g_classnames_opfor [] = {
	"SquadLeader",
	"DrillSgt",
	"Grunt",
	"Recruit",
	"Adrian",
	"Tower",
	"Op4_Random"
};

void
VGUI_ChooseClass(float teamChoice)
{
	static int initialized;
	static OP4CharButton *btns;
	static VGUILabel lblSelectChar;
	static VGUIFrame frmCharInfo;

	if (!teamChoice)
		teamChoice = getplayerkeyfloat(player_localnum, "*team");

	if (!initialized) {
		vector btnpos = [40,80];
		initialized = TRUE;

		OP4Char_Init();

		winCharSelection = spawn(VGUIWindow);
		winCharSelection.SetSize([640, 480]);
		winCharSelection.SetStyleMask(VGUIWindowBorderless | VGUIWindowFullscreen);

		lblSelectChar = spawn(VGUILabel);
		lblSelectChar.SetTitle(Titles_GetTextBody("CTFTitle_SelectYourCharacter"));
		lblSelectChar.SetTextSize(19);
		lblSelectChar.SetPos([40, 38]);
		lblSelectChar.SetSize([400, 24]);

		frmCharInfo = spawn(VGUIFrame);
		frmCharInfo.SetPos([176, 80]);
		frmCharInfo.SetSize([424, 312]);

		imgCharPreview = spawn(VGUIPic);
		imgCharPreview.SetPos([190, 90]);

		lblCharTitle = spawn(VGUILabel);
		lblCharTitle.SetPos([338, 90]);
		lblCharTitle.SetTextSize(19);
		lblCharTitle.SetSize([320, 24]);

		lblCharCounter = spawn(VGUILabel);
		lblCharCounter.SetPos([338, 90 + 32]);
		lblCharCounter.SetSize([320, 18]);

		lblCharDescription = spawn(VGUILabel);
		lblCharDescription.SetPos([338, 90 + 32 + 32]);
		lblCharDescription.SetSize([250, 240]);

		g_uiDesktop.Add(winCharSelection);
		winCharSelection.Add(lblSelectChar);
		winCharSelection.Add(frmCharInfo);
		winCharSelection.Add(imgCharPreview);
		winCharSelection.Add(lblCharTitle);
		winCharSelection.Add(lblCharCounter);
		winCharSelection.Add(lblCharDescription);

		btns = memalloc(sizeof(OP4CharButton) * g_classnames_blackmesa.length);
		for (int i = 0; i < g_classnames_blackmesa.length; i++) {
			btns[i] = spawn(OP4CharButton);
			btns[i].SetTitle(Titles_GetTextBody(g_classnames_blackmesa[i]));
			btns[i].SetSize([124, 24]);
			btns[i].SetPos(btnpos);

			if (i == 7) {
				btns[i].SetKeyEquivalent("0");
				btns[i].SetTag(0);
			} else {
				btns[i].SetKeyEquivalent(ftos((float)i+1));
				btns[i].SetTag(i+1i);
			}

			winCharSelection.Add(btns[i]);
			btnpos[1] += 32;
		}
	}

	/* relabel the buttons for the currently selected team. */
	for (int i = 0; i < g_classnames_blackmesa.length; i++) {
		if (teamChoice == 1) {
			btns[i].SetTitle(Titles_GetTextBody(g_classnames_blackmesa[i]));

			if (i == 6) {
				btns[i].SetKeyEquivalent("0");
				btns[i].SetTag(0);
			} else {
				btns[i].SetKeyEquivalent(ftos((float)i+1));
				btns[i].SetTag(i+1i);
			}
		} else {
			btns[i].SetTitle(Titles_GetTextBody(g_classnames_opfor[i]));

			if (i == 6) {
				btns[i].SetTag(13);
				btns[i].SetKeyEquivalent("0");
			} else {
				btns[i].SetTag(6 + i+1i);
				btns[i].SetKeyEquivalent(ftos((float)i+1));
			}
		}
	}

	winCharSelection.Show();
	winCharSelection.SetPos((video_res / 2) - (winCharSelection.GetSize() / 2));
}