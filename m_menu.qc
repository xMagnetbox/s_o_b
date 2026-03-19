vector MENU_BG = '0.2 0.3 0.4';
vector MENU_BG_DARK = '0.1 0.15 0.2';
vector MENU_BORDER = '0.3 0.4 0.5';
vector MENU_BUTTON = '0.3 0.4 0.5';
vector MENU_BUTTON_BORDER = '0.35 0.45 0.55';
vector MENU_TEXT_1 = '1 1 1';
vector MENU_TEXT_2 = '0.7 0.75 0.75';
vector MENU_HIGHLIGHT = '1 1 1';
vector MENU_DARKEN = '1 1 1';

vector MENU_TEXT_SMALL = '8 8 0';
vector MENU_TEXT_MEDIUM = '16 16 0';
vector MENU_TEXT_LARGE = '24 24 0';


// Save system globals
float saves_count;
string saves_list[64]; // up to 64 slots, change as desired

void() input_tester =
{
	float char = 0;
	float scan = 0;
	string printme = "";
	while (sui_get_input(char, scan))
	{
		printme = strcat(printme, chr2str(char));
	}
	if (printme != "") printf("INPUT: %s\n", printme); 
};

void(string id, vector pos, vector size, float maxlen, __inout string text, __inout float cursor) text_input_control =
{
	vector textsize = [size_y - 4, size_y - 4];
	sui_push_frame(pos, size);
	vector basecolor = sui_is_hovered(id) ? MENU_BG_DARK + MENU_HIGHLIGHT * 0.08 : MENU_BG_DARK; 
	sui_fill([0, 0], size, basecolor, 0.6, 0);
	
	sui_text_input(id, [0, 0], size, text, cursor);
	
	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_CENTER]);
	float focused = sui_is_last_clicked(id);
	// Under focus
	focused ? sui_border_box([0, 0], size, 1, MENU_BORDER, 0.6, 0) : 0;	
	
	sui_push_frame([2, 0], [size_x - 4, size_y - 4]);
	
	float cursorx;
	if (stringwidth(text, 1, textsize) > size_x - 4)
	{
		sui_clip_to_frame();
		cursorx = 0;
		sui_set_align([SUI_ALIGN_END, SUI_ALIGN_CENTER]);
		sui_text([0, 0], textsize, text, MENU_TEXT_1, 1, 0);
	}
	else
	{
		cursorx = stringwidth(substring(text, 0, cursor), 1, textsize);
		sui_text([0, 0], textsize, text, MENU_TEXT_1, 1, 0);
	}
	if (focused) 
	{
		sui_fill([cursorx, 0], [2, textsize_y], MENU_TEXT_1, fabs(sin(time * 4)), 0);
	}
	sui_reset_clip();
	sui_pop_frame();
	
	sui_pop_frame();
};

float(string id, vector pos, vector size, string text) my_button =
{
	sui_push_frame(pos, size);
	vector basecolor = sui_is_hovered(id) ? MENU_BUTTON + MENU_HIGHLIGHT * 0.25 : MENU_BUTTON; 
	basecolor = sui_is_held(id) ? MENU_BUTTON - MENU_DARKEN * 0.1 : basecolor;
	sui_fill([0, 0], size, basecolor, 0.6, 0);
	sui_border_box([0, 0], size, 1, MENU_BUTTON_BORDER, 0.4, 0);
	
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
	sui_text([0, 0], MENU_TEXT_SMALL, text, MENU_TEXT_1, 1, 0);	
	sui_action_element([0, 0], size, id, sui_noop);
	sui_pop_frame();
	
	return sui_is_clicked(id);
};


void(string id, vector pos, vector size, vector minmaxsteps, __inout float value) my_slider =
{
	sui_push_frame(pos, size);
	
	value = sui_slidercontrol(id, [0, 0], size, minmaxsteps, value, sui_slider_noop);
	float maxval = minmaxsteps[1];
	float sliderx = (value / maxval) * size_x;
	sui_fill([0, size_y * 0.25], [size_x, size_y * 0.5], MENU_BG_DARK, 1.0, 0);
	
	float is_active = sui_is_held(id) || (sui_is_hovered(id) && !sui_click_held());
	vector slider_ctrl_color = is_active ? MENU_BUTTON + MENU_HIGHLIGHT * 0.2 : MENU_BUTTON;
	sui_fill([sliderx - 2, 0], [4, size_y], slider_ctrl_color, 1.0, 0);
	
	sui_pop_frame();
};

void(vector pos, vector size, vector minmaxsteps, string cvar_s, string name, string format) cvar_slider =
{
	float current = cvar(cvar_s);
	float old = current;
	sui_push_frame(pos, [size_x, size_y * 0.5 - 4]);
	sui_text([0, 0], MENU_TEXT_SMALL, name, MENU_TEXT_1, 1, 0);
	sui_set_align([SUI_ALIGN_END, SUI_ALIGN_START]);
	sui_text([0, 0], MENU_TEXT_SMALL, sprintf(format, current), MENU_TEXT_1, 1, 0);
	sui_pop_frame();
	my_slider(strcat(cvar_s, "sldr"), [pos_x, pos_y + size_y * 0.5], [size_x, size_y * 0.5], minmaxsteps, current);
	if (current != old) cvar_set(cvar_s, ftos(current));
};

struct name_command {
	string name;
	string command;
};

name_command bindlist[] = 
{
	{ "Forward", "+forward" },
	{ "Back", "+back" },
	{ "Left", "+moveleft" },
	{ "Right", "+moveright" },
	{ "Jump", "+jump" },
	{ "Jump1", "+jump" },
	{ "Jump2", "+jump" },
	{ "Jump3", "+jump" },
	{ "Jump4", "+jump" },
	{ "Jump5", "+jump" },
	{ "Jump6", "+jump" },
	{ "Jump7", "+jump" },
	{ "Jump8", "+jump" },
	{ "Jump9", "+jump" },
	{ "Jump0", "+jump" },
};

void(string id, vector pos, vector size, string name, string command) bind_button =
{
	sui_push_frame(pos, size);
	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_CENTER]);
	string key = sui_binder(id, [0, 0], size, name, command);
	if (sui_is_hovered(id)) sui_fill([0, 0], size, MENU_HIGHLIGHT, 0.1, 0);
	sui_text([6, 0], MENU_TEXT_SMALL, name, MENU_TEXT_1, 1, 0);
	sui_set_align([SUI_ALIGN_END, SUI_ALIGN_CENTER]);
	sui_text([-6, 0], MENU_TEXT_SMALL, key, MENU_TEXT_1, 1, 0);
	
	sui_pop_frame();
};


void(string id, vector pos, vector size, __inout vector scrollofs) bind_list =
{
	sui_fill(pos, size, MENU_BG_DARK, 0.75, 0);
	sui_list_view_begin(strcat(id, "scrl"), pos, size, [size_x - 6, 24], bindlist.length, scrollofs, [0, 6]);
	vector listitem_pos = '0 0 0';
	for (float index = sui_list_item(listitem_pos); index > -1; index = sui_list_item(listitem_pos))
	{
		sui_push_frame(listitem_pos, [size_x - 6, 24]);
		bind_button(strcat(id, ftos(index)), [0, 0], [size_x - 6, 24], bindlist[index].name, bindlist[index].command);
		sui_pop_frame();
	}
	sui_list_view_end();	
};


float current_menu;
const float MENU_MAIN = 1;
const float MENU_SETTINGS = 2;
const float MENU_HELP = 3;
const float MENU_START_SUBMENU  = 4;
const float MENU_SAVE_MENU      = 5;
const float MENU_LOAD_MENU      = 6;

// Visual feedback when clicking a save slot
float save_flash_time;
string save_flash_slot;
string save_last_slot;

vector binds_scroll;

// Refresh list of .sav files from the FTE filesystem
void() SUI_RefreshSaveList =
{
    float h = search_begin("*.sav", 0, 0); // you can change this to "saves/*.sav" if needed
    float sz;
    string f;
    float i = 0;

    saves_count = 0;

    if (h < 0)
        return;

    sz = search_getsize(h);

    for (float n = 0; n < sz && i < 64; n++)
    {
        f = search_getfilename(h, n);
        saves_list[i] = f;
        i++;
    }

    saves_count = i;

    search_end(h);
};

void(string slot) SUI_DoSave =
{
    localcmd(strcat("save ", slot, "\n"));
};

void(string slot) SUI_DoLoad =
{
    localcmd(strcat("load ", slot, "\n"));
};


void() settings_menu =
{
	vector pos = [0, 0];
	vector size = [360, 360];
	
	sui_push_frame(pos, size);

	sui_fill([0, 0], size, MENU_BG, 0.75, 0);
	sui_border_box([0, 0], size, 2, MENU_BORDER, 0.3, 0);
	
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
	sui_text([0, 4], MENU_TEXT_MEDIUM, "Settings", MENU_TEXT_1, 1, 0);

	
	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_START]);
	
	float xpos = 8;
	float ypos = 32;
	float width = size_x * 0.5 - 8 * 2;

	cvar_slider([xpos, ypos], [width, 32], [0, 1], "volume", "Volume", "%.2f");
	ypos += 32 + 4;
	cvar_slider([xpos, ypos], [width, 32], [0, 1], "musicvolume", "Music Volume", "%.2f");
	ypos += 32 + 4;
	cvar_slider([xpos, ypos], [width, 32], [90, 135], "fov", "Field of View", "%.0f");
	ypos += 32 + 4;
	cvar_slider([xpos, ypos], [width, 32], [0.5, 1.5], "gamma", "Gamma", "%.2f");
	ypos += 32 + 4 + 32;
	
	sui_text([xpos, ypos], MENU_TEXT_SMALL, "Video", MENU_TEXT_1, 1, 0);
	ypos += 16;
	my_button("fs_btn", [xpos, ypos], [width, 20], "Fullscreen") ? localcmd("vid_fullscreen 2; vid_restart\n") : 0;
	ypos += 24;
	my_button("wn_btn", [xpos, ypos], [width, 20], "Windowed") ? localcmd("vid_fullscreen 0; vid_width 1024; vid_height 768; vid_restart\n") : 0;
	ypos += 24;
	sui_text([xpos, ypos], MENU_TEXT_SMALL, "Window can be resized.", MENU_TEXT_1, 0.8, 0);
	ypos += 16;

	ypos = 32;
	xpos = 8 + width + 8 + 8;
	
	sui_text([xpos, ypos], MENU_TEXT_SMALL, "Controls", MENU_TEXT_1, 1, 0);
	ypos += 16;
	bind_list("bindlist", [xpos, ypos], [width, 160], binds_scroll);
	ypos += 160 + 8;

	cvar_slider([xpos, ypos], [width, 32], [0.1, 10], "sensitivity", "Sensitivity", "%.2f");
	ypos += 32;

	sui_set_align([SUI_ALIGN_START, SUI_ALIGN_END]);
	my_button("stg_back", [8, -8], [80, 20], "Back") ? current_menu = MENU_MAIN : 0;

	sui_set_default_kb_focus("volume");

	if (sui_listen_back())
	{
	    current_menu = MENU_MAIN;
	    return; // prevents layout corruption
	}
	
	sui_pop_frame();
};

void() help_menu =
{
	vector pos = [0, 0];
	vector size = [360, 280];
	
	sui_push_frame(pos, size);

	sui_fill([0, 0], size, MENU_BG, 0.75, 0);
	sui_border_box([0, 0], size, 2, MENU_BORDER, 0.3, 0);
	
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
	sui_text([0, 4], MENU_TEXT_MEDIUM, "Help", MENU_TEXT_1, 1, 0);
	
	float xpos = 0;
	float ypos = 32;
	sui_text([xpos, ypos], MENU_TEXT_SMALL, "Controls", MENU_TEXT_1, 1, 0);
	ypos += 32 + 4;
	sui_text([xpos, ypos], MENU_TEXT_SMALL, "WASD - movement", MENU_TEXT_1, 1, 0);
	ypos += 32 + 4;
	sui_text([xpos, ypos], MENU_TEXT_SMALL, "Right mouse button - charge jump and dash", MENU_TEXT_1, 1, 0);
	ypos += 32 + 4;
	sui_text([xpos, ypos], MENU_TEXT_SMALL, "Left mouse button - swipe", MENU_TEXT_1, 1, 0);
	ypos += 32 + 4;
	sui_text([xpos, ypos], MENU_TEXT_SMALL, "Space - jump", MENU_TEXT_1, 1, 0);
	
	sui_set_align([SUI_ALIGN_END, SUI_ALIGN_END]);
	my_button("hlp_back", [-8, -8], [80, 20], "Back") ? current_menu = MENU_MAIN : 0;

	if (sui_listen_back())
	{
	    current_menu = MENU_MAIN;
	    return; // prevents layout corruption
	}

	sui_pop_frame();	
};

void() start_game_menu =
{
    vector pos = [0, 0];
    vector size = [260, 140];
    
    sui_push_frame(pos, size);
    sui_fill([0,0], size, MENU_BG, 0.75, 0);
    sui_border_box([0,0], size, 2, MENU_BORDER, 0.3, 0);

    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
    sui_text([0, 4], MENU_TEXT_MEDIUM, "Start Game", MENU_TEXT_1, 1, 0);

    // "New Game" preserves your existing behavior
    if (my_button("sg_new", [0, 30], [size_x - 16, 20], "New Game"))
        localcmd("map sob1m1-compile\n");

    if (my_button("sg_save", [0, 60], [size_x - 16, 20], "Save Game"))
    {
        SUI_RefreshSaveList();
        current_menu = MENU_SAVE_MENU;
    }

    if (my_button("sg_load", [0, 90], [size_x - 16, 20], "Load Game"))
    {
        SUI_RefreshSaveList();
        current_menu = MENU_LOAD_MENU;
    }

    sui_set_align([SUI_ALIGN_END, SUI_ALIGN_END]);
    if (my_button("sg_back", [-8, -8], [80, 20], "Back"))
        current_menu = MENU_MAIN;

    if (sui_listen_back())
	{
	    current_menu = MENU_MAIN;
	    return; // prevents layout corruption
	}

    sui_pop_frame();
};

vector save_scroll;

void() save_game_menu =
{
    vector pos = [0, 0];
    vector size = [300, 300];

    sui_push_frame(pos, size);

    sui_fill([0,0], size, MENU_BG, 0.75, 0);
    sui_border_box([0,0], size, 2, MENU_BORDER, 0.3, 0);

    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
    sui_text([0, 4], MENU_TEXT_MEDIUM, "Save Game", MENU_TEXT_1, 1, 0);

    // Scrollable slot list
    sui_list_view_begin("save_list",
                        [10, 40],
                        [size_x - 20, size_y - 90],
                        [size_x - 40, 24],
                        10,
                        save_scroll,
                        [0, 6]);

    vector itempos;

    for (float i = sui_list_item(itempos); i > -1; i = sui_list_item(itempos))
    {
        string slotname = strcat("slot", ftos(i));
        string filename = strcat(slotname, ".sav");

        float filled = FALSE;

        // Determine whether this slot exists
        for (float n = 0; n < saves_count; n++)
        {
            if (saves_list[n] == filename)
                filled = TRUE;
        }

        vector c = filled ? MENU_TEXT_1 : MENU_TEXT_2;

        // Base label
        string label = filled ? strcat(slotname, " (overwrite)")
                              : strcat(slotname, " (empty)");

        // If this is the recently saved slot, append "- SAVED"
        if (save_last_slot == slotname)
        {
            label = strcat(label, "   - SAVED");
        }

        string id = strcat("save_", slotname);

        sui_push_frame(itempos, [size_x - 40, 24]);

        // Default slot background
        vector bg = MENU_BG_DARK;

        // Flash highlight if this is the recently clicked slot
        if (save_flash_slot == slotname && time < save_flash_time)
        {
            // Brighten background noticeably
            bg = MENU_HIGHLIGHT;

            // Optional: add subtle animation effect
            float p = 0.4 + 0.6 * fabs(sin(time * 20));
            sui_fill([0,0], [size_x - 40, 24], bg, p, 0);
        }
        else
        {
            sui_fill([0,0], [size_x - 40, 24], bg, 0.5, 0);
        }

        sui_text([4,0], MENU_TEXT_SMALL, label, c, 1, 0);

        sui_action_element([0,0], [size_x - 40,24], id, sui_noop);

        if (sui_is_clicked(id))
        {
            SUI_DoSave(slotname);

            // Flash highlight for 0.5s
            save_flash_slot = slotname;
            save_flash_time = time + 0.5;

            // Change label to include "- SAVED"
            save_last_slot = slotname;
        }

        sui_pop_frame();
    }

    // Properly end the list view
    sui_list_view_end();

    // Back button at bottom-right
    sui_set_align([SUI_ALIGN_END, SUI_ALIGN_END]);
    if (my_button("sav_back", [-8, -8], [80, 20], "Back"))
    {
        current_menu = MENU_START_SUBMENU;
        sui_pop_frame();
        return;
    }

    // ESC / controller back
    if (sui_listen_back())
    {
        current_menu = MENU_START_SUBMENU;
        sui_pop_frame();
        return;
    }

    // Pop the main frame we pushed at the start
    sui_pop_frame();
};


vector load_scroll;

void() load_game_menu =
{
    vector pos = [0, 0];
    vector size = [300, 300];

    sui_push_frame(pos, size);

    sui_fill([0,0], size, MENU_BG, 0.75, 0);
    sui_border_box([0,0], size, 2, MENU_BORDER, 0.3, 0);

    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
    sui_text([0, 4], MENU_TEXT_MEDIUM, "Load Game", MENU_TEXT_1, 1, 0);

    // Scrollable slot list
    sui_list_view_begin("load_list", [10, 40], [size_x - 20, size_y - 90],
                        [size_x - 40, 24], 10, load_scroll, [0, 6]);

    vector itempos;

    for (float i = sui_list_item(itempos); i > -1; i = sui_list_item(itempos))
    {
        string slotname = strcat("slot", ftos(i));
        string filename = strcat(slotname, ".sav");

        float filled = FALSE;

        for (float n = 0; n < saves_count; n++)
        {
            if (saves_list[n] == filename)
                filled = TRUE;
        }

        vector c = filled ? MENU_TEXT_1 : MENU_TEXT_2;
        string label = filled ? slotname : strcat(slotname, " (empty)");

        sui_push_frame(itempos, [size_x - 40, 24]);
        sui_fill([0,0], [size_x - 40, 24], MENU_BG_DARK, 0.5, 0);
        sui_text([4,0], MENU_TEXT_SMALL, label, c, 1, 0);

        string id = strcat("load_", slotname);
        sui_action_element([0,0], [size_x - 40,24], id, sui_noop);

        if (filled && sui_is_clicked(id))
        {
            SUI_DoLoad(slotname);
        }

        sui_pop_frame();
    }

    sui_list_view_end();

    // Back
    sui_set_align([SUI_ALIGN_END, SUI_ALIGN_END]);
    if (my_button("load_back", [-8, -8], [80, 20], "Back"))
        current_menu = MENU_START_SUBMENU;

    if (sui_listen_back())
	{
	    current_menu = MENU_START_SUBMENU;
	    return; // prevents layout corruption
	}

    sui_pop_frame();
};

void() main_menu =
{
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
	sui_text([0, 204], MENU_TEXT_LARGE, "title goes here and can be long", [1, 1, 1], 1, 0);
	
	vector pos = [0, -24];
	vector size = [120, 140];
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_END]);
	sui_push_frame(pos, size);
	
	sui_fill([0, 0], size, MENU_BG, 0.3, 0);
	sui_border_box([0, 0], size, 2, MENU_BORDER, 0.2, 0);
	
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_START]);
	
	if (my_button("mm_start", [0, 8], [size_x - 16, 20], "Start Game"))
		current_menu = MENU_START_SUBMENU;
	my_button("mm_settings", [0, 8 + 24], [size_x - 16, 20], "Settings") ? current_menu = MENU_SETTINGS : 0;
	my_button("mm_help", [0, 8 + 48], [size_x - 16, 20], "Help") ? current_menu = MENU_HELP : 0;
	sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_END]);
	my_button("mm_quit", [0, -8], [size_x - 16, 20], "Quit") ? localcmd("quit\n") : 0;
	sui_pop_frame();	

	sui_set_default_kb_focus("mm_start");
};

void(vector size) root_menu =
{
    // Ensure the engine releases the mouse and uses absolute cursor coords for SUI
    setcursormode(TRUE);

    sui_set_align([SUI_ALIGN_CENTER, SUI_ALIGN_CENTER]);
    sui_fill([0, 0], size, '0 0 0', 0.5, 0);

    switch (current_menu)
    {
        case MENU_MAIN:           main_menu(); break;
        case MENU_SETTINGS:       settings_menu(); break;
        case MENU_HELP:           help_menu(); break;
        case MENU_START_SUBMENU:  start_game_menu(); break;
        case MENU_SAVE_MENU:      save_game_menu(); break;
        case MENU_LOAD_MENU:      load_game_menu(); break;
        default: break;
    }
};