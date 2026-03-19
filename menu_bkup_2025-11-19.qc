// ============================================================================
// MENU.QC — Custom Menu System for Song of Boyd
// ============================================================================

#define MENU
#include "fteextensions.qc"

// ----------------------------------------------------------------------------
// GLOBAL MENU STATE
// ----------------------------------------------------------------------------
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

// ============================================================================
// ENGINE HOOKS
// ============================================================================

void() m_init =
{
    print("MENU: m_init\n");
    menu_selected = 0;
    menu_active = TRUE;
    setkeydest(2); // focus menu input
};

void() m_open  = { menu_active = TRUE;  setkeydest(2); };
void() m_close = { menu_active = FALSE; setkeydest(0); };

void(float wantmode) m_toggle =
{
    if (wantmode == 0) { m_close(); return; }
    if (wantmode == 1) { m_open(); return; }

    if (menu_active) m_close();
    else m_open();
};

// ============================================================================
// MAIN MENU DRAWING
// ============================================================================

void(vector screensize) m_draw =
{
    if (!menu_active)
        return;

    // Background darken
    drawfill('0 0 0', screensize, '0 0 0', 0.55, 0);

    // Title
    drawstring([screensize_x*0.5 - 150, screensize_y*0.22, 0],
               "Song of Boyd",
               [32,32,0], '1 1 1', 1, DRAWFLAG_NORMAL);

    // Draw entries
    float i;
    vector base = [screensize_x*0.5 - 60, screensize_y*0.40, 0];
    vector step = [0, 36, 0];

    for (i = 0; i < 5; i++)
    {
        vector col = (i == menu_selected) ? '1 1 0' : '1 1 1';
        drawstring(base + step * i,
                   main_menu_items[i],
                   [20,20,0], col,
                   1, DRAWFLAG_NORMAL);
    }
};



// ============================================================================
// SUBMENU: NEW GAME
// ============================================================================

void(string arg) menu_newgame_callback =
{
    if (arg == "cancel" || arg == "Back")
    {
        localcmd("menuclear\n");
        return;
    }

    if (arg == "Easy")      localcmd("skill 0; map start\n");
    if (arg == "Normal")    localcmd("skill 1; map start\n");
    if (arg == "Hard")      localcmd("skill 2; map start\n");
    if (arg == "Nightmare") localcmd("skill 3; map start\n");
};

void ShowNewGameMenu()
{
    localcmd("conmenu menu_newgame_callback\n");

    localcmd("menutextbig 0.30 0.20 \"NEW GAME\" 0\n");

    localcmd("menutext 0.30 0.35 \"Easy\" menu_newgame_callback\n");
    localcmd("menutext 0.30 0.42 \"Normal\" menu_newgame_callback\n");
    localcmd("menutext 0.30 0.49 \"Hard\" menu_newgame_callback\n");
    localcmd("menutext 0.30 0.56 \"Nightmare\" menu_newgame_callback\n");

    localcmd("menutext 0.30 0.70 \"Back\" menu_newgame_callback\n");
}

// ============================================================================
// SUBMENU: LOAD GAME
// ============================================================================

void(string arg) menu_loadgame_callback =
{
    if (arg == "cancel" || arg == "Back")
    {
        localcmd("menuclear\n");
        return;
    }

    // Load a save
    localcmd(strcat("load ", arg, "\n"));
};

void ShowLoadGameMenu()
{
    localcmd("conmenu menu_loadgame_callback\n");

    localcmd("menutextbig 0.30 0.20 \"LOAD GAME\" 0\n");

    float i;
    string savename;

    // List save0.sav through save9.sav
    for (i = 0; i < 10; i++)
    {
        savename = strcat("save", ftos(i), ".sav");

        if (whichpack(savename)) // file exists?
        {
            string cmd = savename;
            vector ypos = [0.30, 0.35 + (i*0.05), 0];
            localcmd(strcat("menutext 0.30 ", ftos(0.35 + (i*0.05)),
                            " \"", savename, "\" menu_loadgame_callback\n"));
        }
    }

    localcmd("menutext 0.30 0.80 \"Back\" menu_loadgame_callback\n");
}

// ============================================================================
// SUBMENU: OPTIONS
// ============================================================================

void(string arg) menu_options_callback =
{
    if (arg == "cancel" || arg == "Back")
    {
        localcmd("menuclear\n");
        return;
    }
};

void ShowOptionsMenu()
{
    localcmd("conmenu menu_options_callback\n");

    // Root panel (prevents overlap)
    localcmd("menubox 0.20 0.10 0.60 0.80\n");

    // Title
    localcmd("menutextbig 0.30 0.18 \"OPTIONS\" 0\n");

    // Entries
    localcmd("menucomboi 0.30 0.32 \"Graphics Quality\" r_picmip 0 1 2 3\n");
    localcmd("menuslider 0.30 0.42 \"Music Volume\" bgmvolume 0 1\n");
    localcmd("menuslider 0.30 0.52 \"Sound Volume\" volume 0 1\n");

    // Back
    localcmd("menutext 0.30 0.70 \"Back\" menu_options_callback\n");
}

// ============================================================================
// LOADING SCREEN
// ============================================================================

void(vector screensize, float opaque) m_drawloading =
{
    drawstring([screensize_x*0.5 - 60, screensize_y*0.5, 0],
               "Loading...", [20,20,0],
               '1 1 1', 1, DRAWFLAG_NORMAL);
};

// ============================================================================
// OPTIONAL CLEANUP
// ============================================================================
void() m_shutdown =
{
    print("MENU: m_shutdown\n");
};

// ============================================================================
// MAIN MENU INPUT
// ============================================================================

float(float evtype, float scanx, float chary, float devid) Menu_InputEvent =
{
    if (!menu_active)
        return FALSE;

    if (evtype == IE_KEYDOWN)
    {
        // Navigate
        if (scanx == K_DOWNARROW)
        {
            menu_selected = (menu_selected + 1) % 5;
            return TRUE;
        }
        if (scanx == K_UPARROW)
        {
            menu_selected--;
            if (menu_selected < 0) menu_selected = 4;
            return TRUE;
        }

        // Activate selection
        if (scanx == K_ENTER || scanx == K_MOUSE1)
        {
            if (menu_selected == 0)
            {
                // Play
                m_close();
                localcmd("map start\n");
            }
            else if (menu_selected == 1)
            {
                ShowNewGameMenu();
            }
            else if (menu_selected == 2)
            {
                ShowLoadGameMenu();
            }
            else if (menu_selected == 3)
            {
                ShowOptionsMenu();
            }
            else if (menu_selected == 4)
            {
                localcmd("quit\n");
            }
            return TRUE;
        }

        // ESC closes menu
        if (scanx == K_ESCAPE)
        {
            m_close();
            return TRUE;
        }
    }

    return FALSE;
};
