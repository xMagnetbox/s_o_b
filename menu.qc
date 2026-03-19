// MENU.QC — Prototype Full Menu System for Song of Boyd

#define MENU

// FORWARD DECLARATIONS //
void() ShowNewGameMenu;
void() ShowLoadGameMenu;
void() ShowOptionsMenu;
void() ShowGraphicsMenu;
void() ShowAudioMenu;
void() ShowQuitConfirmMenu;

void(string arg) menu_newgame_callback;
void(string arg) menu_loadgame_callback;
void(string arg) menu_options_callback;
void(string arg) menu_graphics_callback;
void(string arg) menu_audio_callback;
void(string arg) menu_quitconfirm_callback;

// GLOBAL STATE //
float menu_selected;
float menu_active;

string main_menu_items[5] =
{
    "Play",
    "New Game",
    "Load Game",
    "Options",
    "Quit"
};


// ENGINE ENTRYPOINTS //

void() m_init =
{
	print("MENU: m_init\n");
	menu_selected = 0;
	menu_active = TRUE;

	// Let conmenu use normalized coordinates (0.0–1.0)
	localcmd("menu_normalized 1\n");

	// 2 = keydest for menu (FTE)
	setkeydest(2);
};

void() m_open =
{
    menu_active = TRUE;
    setkeydest(2);
};

void() m_close =
{
    menu_active = FALSE;
    setkeydest(0); // return control to game
};

void(float wantmode) m_toggle =
{
    if (wantmode == 0)
    {
        m_close();
        localcmd("menuclear\n");
        return;
    }

    if (wantmode == 1)
    {
        m_open();
        return;
    }

    if (menu_active)
    {
        m_close();
        localcmd("menuclear\n");
    }
    else
        m_open();
};


// MAIN MENU DRAW //

void(vector screensize) m_draw =
{
    if (!menu_active)
        return;

    drawfill('0 0 0', screensize, '0 0 0', 0.55, 0);

    drawstring(
        [screensize_x * 0.5 - 150, screensize_y * 0.22, 0],
        "Song of Boyd",
        [32,32,0],
        '1 1 1',
        1,
        DRAWFLAG_NORMAL
    );

    float i;
    vector base = [screensize_x * 0.5 - 60, screensize_y * 0.40, 0];
    vector step = [0, 36, 0];

    for (i = 0; i < 5; i++)
    {
        vector col = (i == menu_selected) ? '1 1 0' : '1 1 1';

        drawstring(
            base + step * i,
            main_menu_items[i],
            [20,20,0],
            col,
            1,
            DRAWFLAG_NORMAL
        );
    }
};


// INPUT //

float(float evtype, float scanx, float chary, float devid) Menu_InputEvent =
{
    if (!menu_active)
        return FALSE;

    if (evtype == IE_KEYDOWN)
    {
        if (scanx == K_DOWNARROW)
        {
            menu_selected = (menu_selected + 1) % 5;
            return TRUE;
        }

        if (scanx == K_UPARROW)
        {
            menu_selected--;
            if (menu_selected < 0)
                menu_selected = 4;
            return TRUE;
        }

        if (scanx == K_ENTER || scanx == K_MOUSE1)
        {
            if (menu_selected == 0)
            {
                // "Play" — start the game immediately
                m_close();
                localcmd("menuclear\n");
                localcmd("map start\n");
            }
            else if (menu_selected == 1)
                ShowNewGameMenu();
            else if (menu_selected == 2)
                ShowLoadGameMenu();
            else if (menu_selected == 3)
                ShowOptionsMenu();
            else if (menu_selected == 4)
                ShowQuitConfirmMenu();

            return TRUE;
        }

        if (scanx == K_ESCAPE)
        {
            // From the main menu: close menus and return to game
            m_close();
            localcmd("menuclear\n");
            return TRUE;
        }
    }

    return FALSE;
};


// NEW GAME //

void(string arg) menu_newgame_callback =
{
    if (arg == "cancel" || arg == "Back")
    {
        localcmd("menuclear\n");
        return;
    }

    if (arg == "Easy")
        localcmd("skill 0; map start\n");
    if (arg == "Normal")
        localcmd("skill 1; map start\n");
    if (arg == "Hard")
        localcmd("skill 2; map start\n");
    if (arg == "Nightmare")
        localcmd("skill 3; map start\n");
};

void() ShowNewGameMenu =
{
    localcmd("conmenu menu_newgame_callback\n");
    localcmd("menubox 0.20 0.10 0.60 0.80\n");
    localcmd("menutextbig 0.30 0.18 \"NEW GAME\" 0\n");

    localcmd("menutext 0.30 0.32 \"Easy\" menu_newgame_callback\n");
    localcmd("menutext 0.30 0.39 \"Normal\" menu_newgame_callback\n");
    localcmd("menutext 0.30 0.46 \"Hard\" menu_newgame_callback\n");
    localcmd("menutext 0.30 0.53 \"Nightmare\" menu_newgame_callback\n");

    localcmd("menutext 0.30 0.70 \"Back\" menu_newgame_callback\n");
};


// LOAD GAME //

void(string arg) menu_loadgame_callback =
{
    if (arg == "cancel" || arg == "Back")
    {
        localcmd("menuclear\n");
        return;
    }

    localcmd(strcat("load ", arg, "\n"));
};

void() ShowLoadGameMenu =
{
    localcmd("conmenu menu_loadgame_callback\n");
    localcmd("menubox 0.20 0.10 0.60 0.80\n");
    localcmd("menutextbig 0.30 0.18 \"LOAD GAME\" 0\n");

    float i;
    string savename;

    for (i = 0; i < 10; i++)
    {
        savename = strcat("save", ftos(i), ".sav");

        if (whichpack(savename))
        {
            // Y position = 0.32 + i * 0.05
            localcmd(
                strcat(
                    "menutext 0.30 ",
                    ftos(0.32 + i * 0.05),
                    " \"",
                    savename,
                    "\" menu_loadgame_callback\n"
                )
            );
        }
    }

    localcmd("menutext 0.30 0.80 \"Back\" menu_loadgame_callback\n");
};


// OPTIONS MENU //

void(string arg) menu_options_callback =
{
    if (arg == "cancel" || arg == "Back")
    {
        localcmd("menuclear\n");
        return;
    }

    if (arg == "Audio")
        ShowAudioMenu();
    if (arg == "Graphics")
        ShowGraphicsMenu();
};

void() ShowOptionsMenu =
{
    localcmd("conmenu menu_options_callback\n");
    localcmd("menubox 0.20 0.10 0.60 0.80\n");

    localcmd("menutextbig 0.30 0.18 \"OPTIONS\" 0\n");

    localcmd("menutext 0.30 0.32 \"Audio\" menu_options_callback\n");
    localcmd("menutext 0.30 0.39 \"Graphics\" menu_options_callback\n");

    localcmd("menutext 0.30 0.70 \"Back\" menu_options_callback\n");
};


// AUDIO //

void(string arg) menu_audio_callback =
{
    if (arg == "cancel" || arg == "Back")
    {
        localcmd("menuclear\n");
        return;
    }

    // Later: handle actual cvar changes here if needed
};

void() ShowAudioMenu =
{
    localcmd("conmenu menu_audio_callback\n");
    localcmd("menubox 0.20 0.10 0.60 0.80\n");

    localcmd("menutextbig 0.30 0.18 \"AUDIO\" 0\n");

    localcmd("menuslider 0.30 0.32 \"Music Volume\" bgmvolume 0 1\n");
    localcmd("menuslider 0.30 0.42 \"Sound Volume\" volume 0 1\n");

    localcmd("menutext 0.30 0.70 \"Back\" menu_audio_callback\n");
};


// GRAPHICS (DUMMY OPTIONS) //

void(string arg) menu_graphics_callback =
{
    if (arg == "cancel" || arg == "Back")
    {
        localcmd("menuclear\n");
        return;
    }

    // Dummy modes
    if (arg == "Low")
        print("Graphics mode: LOW\n");
    if (arg == "Medium")
        print("Graphics mode: MEDIUM\n");
    if (arg == "High")
        print("Graphics mode: HIGH\n");
};

void() ShowGraphicsMenu =
{
    localcmd("conmenu menu_graphics_callback\n");
    localcmd("menubox 0.20 0.10 0.60 0.80\n");

    localcmd("menutextbig 0.30 0.18 \"GRAPHICS\" 0\n");

    localcmd("menutext 0.30 0.32 \"Low\" menu_graphics_callback\n");
    localcmd("menutext 0.30 0.39 \"Medium\" menu_graphics_callback\n");
    localcmd("menutext 0.30 0.46 \"High\" menu_graphics_callback\n");

    localcmd("menutext 0.30 0.70 \"Back\" menu_graphics_callback\n");
};


// QUIT CONFIRMATION //

void(string arg) menu_quitconfirm_callback =
{
    if (arg == "cancel" || arg == "No")
    {
        localcmd("menuclear\n");
        return;
    }

    if (arg == "Yes")
    {
        localcmd("quit\n");
    }
};

void() ShowQuitConfirmMenu =
{
    localcmd("conmenu menu_quitconfirm_callback\n");
    localcmd("menubox 0.20 0.20 0.60 0.60\n");

    localcmd("menutextbig 0.30 0.28 \"QUIT GAME?\" 0\n");

    localcmd("menutext 0.30 0.42 \"Yes\" menu_quitconfirm_callback\n");
    localcmd("menutext 0.30 0.49 \"No\" menu_quitconfirm_callback\n");
};


// LOADING SCREEN //

void(vector screensize, float opaque) m_drawloading =
{
    drawstring(
        [screensize_x * 0.5 - 60, screensize_y * 0.5, 0],
        "Loading…",
        [20,20,0],
        '1 1 1',
        1,
        DRAWFLAG_NORMAL
    );
};


// SHUTDOWN //

void() m_shutdown =
{
    print("MENU: m_shutdown\n");
};
