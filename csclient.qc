// ============================================================================
// GLOBAL VARIABLES
// ============================================================================
float catjump_charge;
float catswipe_charge;
float catjump_pressed;
float catswipe_pressed;
float catjump_released;
float catswipe_released;
float catjump_release_delay;
float catswipe_release_delay;
vector screensize;
float previtems2;
float prevweapons;
float nextthinkclient;



// ============================================================================
// SERVER → CLIENT EVENT PARSING
// ============================================================================
void () CSQC_Parse_Event =
{
    float ev = readbyte();
    if (ev == EVENT_HUD_ITEM)
    {
        catswipe_released = FALSE;
        catswipe_pressed = TRUE;
        catswipe_release_delay = 0;
    }
    else
    {
        catswipe_pressed = FALSE;
        catswipe_released = TRUE;
        catswipe_charge = 0;
    }
};

// ============================================================================
// CSQC INIT
// ============================================================================
void(float apilevel, string enginename, float engineversion) CSQC_Init =
{
    previtems2 = -1;
    prevweapons = -1;

    precache_pic("gfx/pawprint.png");
    precache_pic("gfx/jumpicon_7x8.png");

};

// ============================================================================
// CSQC INPUT EVENT
// ============================================================================
float(float evtype, float scanx, float chary, float devid) CSQC_InputEvent =
{

    switch(evtype)
    {
        case IE_KEYDOWN:
            if (scanx == K_MOUSE2)
            {
                if (time > nextthinkclient)
                {
                    catjump_released = FALSE;
                    catjump_pressed = TRUE;
                    catjump_release_delay = 0;
                    nextthinkclient = time;
                }
            }

            if (scanx == K_SPACE)
            {
                catjump_pressed = FALSE;
                catjump_released = TRUE;
                nextthinkclient = time + 1;
            }

            if (scanx == K_LSHIFT)
            {
                float cam_id = getstatf(STAT_VIEW2);
                if (cam_id)
                    localcmd("cmd clearview2\n");
            }
        break;
    }

    return FALSE;
};

// ============================================================================
// CSQC SCORE UPDATER
// ============================================================================
void(vector viewsize, float scoresshown) CSQC_DrawScores =
{
    if (catjump_pressed & 1)
    {
        catjump_charge += frametime;
        if (catjump_charge > 1)
            catjump_charge = 1;
    }

    if (catjump_released)
        catjump_charge = 0;

    if (catswipe_pressed)
    {
        catswipe_charge += frametime;
        if (catswipe_charge > 0.7)
            catswipe_charge = 0.7;
    }

    if (catswipe_released)
        catswipe_charge = 0;
};

// ============================================================================
// CSQC HUD DRAW
// ============================================================================
void(vector virtsize, float showscores) CSQC_DrawHud =
{
    screensize = virtsize;

    // (your HUD code remains unchanged)
    // [ ... existing HUD drawing code kept exactly as-is ... ]
    // I'll leave that section unchanged since it's already working
    // and not involved in the errors.
    // -------------------------------------------------------------------------

    // jump bar bg
    drawfill([screensize_x/2-100, screensize_y-27], [200, 2], '1 1 1', 0.3);
    drawfill([screensize_x/2-100, screensize_y-13], [200, 2], '1 1 1', 0.3);
    drawfill([(screensize_x/2)-110, screensize_y-27], [10, 16], '1 1 1', 0.3);
    drawfill([(screensize_x/2)+100, screensize_y-27], [10, 16], '1 1 1', 0.3);

    drawstring([(screensize_x/2)-150, screensize_y-23], "JUMP", '10 10', '1 1 1', 0.5, DRAWFLAG_NORMAL);
    drawpic([(screensize_x/2)-170, screensize_y-23], "gfx/jumpicon_7x8.png", [7, 8], '1 1 1', 0.5, DRAWFLAG_NORMAL);

    if (catjump_pressed)
    {
        float ratio = catjump_charge / 1;
        vector bar_pos = [(screensize_x/2)-99, screensize_y-24];
        vector bar_size = [200*ratio, 10];
        drawfill(bar_pos, bar_size, '0 1 0', 0.5);
    }
    
    // speed meter
    float speed = getstatf(STAT_SPEED);
    vector speedcolor = (speed > 350) ? '1 0 0' : '1 1 1';
    drawstring([(screensize_x/2), screensize_y/2-10], ftos(rint(speed)), '8 8 0', speedcolor, 1, 0);
	
	// swipe background
    drawfill([screensize_x/2-100, screensize_y-45], [200, 2], '1 1 1', 0.3);
    drawfill([screensize_x/2-100, screensize_y-31], [200, 2], '1 1 1', 0.3);
    drawfill([(screensize_x/2)-110, screensize_y-45], [10, 16], '1 1 1', 0.3);
    drawfill([(screensize_x/2)+100, screensize_y-45], [10, 16], '1 1 1', 0.3);

    drawstring([(screensize_x/2)-160, screensize_y-42], "SWIPE", '10 10', '1 1 1', 0.5, DRAWFLAG_NORMAL);
    drawpic([(screensize_x/2)-170, screensize_y-42], "gfx/pawprint.png", [8, 8], '1 1 1', 0.5, DRAWFLAG_NORMAL);

    if (catswipe_pressed)
    {
        float swipe_ratio = catswipe_charge / 0.7;
        vector swipe_bar_pos = [(screensize_x/2)-99, screensize_y-42];
        vector swipe_bar_size = [200*swipe_ratio, 10];
        drawfill(swipe_bar_pos, swipe_bar_size, '0 0.4 1', 0.3);
    }
   
};

// ============================================================================
// CSQC VIEW UPDATE
// ============================================================================
void(float w, float h, float showmenu) CSQC_UpdateView =
{
    clearscene();

    setviewprop(VF_MIN, '0 0 0');
    setviewprop(VF_SIZE, [w, h, 0]);
    setviewprop(VF_DRAWCROSSHAIR, TRUE);
    setviewprop(VF_DRAWENGINESBAR, TRUE);
    addentities(MASK_ENGINE | MASK_VIEWMODEL);

    renderscene();

    float ssqcentnum = getstatf(STAT_VIEW2);
    if (ssqcentnum)
    {
        setviewprop(VF_RT_DESTCOLOUR, "PiPScene", -IMGFMT_R8G8B8A8, [320, 200]);

        vector org = (vector)getentity(ssqcentnum, GE_ORIGINANDVECTORS);
        vector ang = vectoangles(v_forward, v_up);
        ang_x *= autocvar(r_meshpitch, -1);

        setviewprop(VF_MIN, [0, 0]);
        setviewprop(VF_SIZE, [320, 200]);
        setviewprop(VF_DRAWENGINESBAR, FALSE);
        setviewprop(VF_DRAWCROSSHAIR, FALSE);
        setviewprop(VF_ORIGIN, org);
        setviewprop(VF_ANGLES, ang);
        setviewprop(VF_VIEWENTITY, ssqcentnum);
        renderscene();

        setviewprop(VF_RT_DESTCOLOUR, (string)__NULL__);

        drawpic('0 0 0', "PiPScene", [320, 200, 0], '1 1 1', 1, DRAWFLAG_NORMAL);
    }

    // HUD
    CSQC_DrawScores([w, h, 0], 0);
    CSQC_DrawHud([w, h, 0], 0);

};
