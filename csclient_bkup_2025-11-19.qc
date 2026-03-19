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



void () CSQC_Parse_Event =
{
	float ev = readbyte();
	if (ev == EVENT_HUD_ITEM)
	{
		print("mouse 1 pressed via sent byte\n");
		catswipe_released = FALSE;
		catswipe_pressed = TRUE;
		catswipe_release_delay = 0;
	}
	else
	    {
		print("mouse 1 released\n");
		catswipe_pressed = FALSE;
		catswipe_released = TRUE;
		catswipe_charge = 0;
	    }
		
};

//=================================================================================================
//                                      Engine hooks
//=================================================================================================

void(float apilevel, string enginename, float engineversion) CSQC_Init = {
	previtems2 = -1;
	prevweapons = -1;
	precache_pic("gfx/pawprint.png");
	precache_pic("gfx/jumpicon_7x8.png");
};



float(float evtype, float scanx, float chary, float devid) CSQC_InputEvent = {
	
	switch(evtype)
	{
		case IE_KEYDOWN:
			print("Key pressed: ", ftos(scanx), "\n");
			if (scanx == K_MOUSE2) {
				if (time > nextthinkclient) {
					//print("mouse 2 pressed down!\n");
					catjump_released = FALSE;
					catjump_pressed = TRUE;
					catjump_release_delay = 0;
					nextthinkclient = time;
				}
			}
			if (scanx == K_SPACE) {
				//print("mouse 2 pressed down!\n");
				catjump_pressed = FALSE;
				catjump_released = TRUE;
				nextthinkclient = time + 1;
			}
			if (scanx == K_LSHIFT) {
				float cam_id = getstatf(STAT_VIEW2);
				if (cam_id) {
				    // Send a command to the server to clear view2
				    localcmd("cmd clearview2\n");
				}
			}
		default: break;
		
	}
	
	
};
void(vector viewsize, float scoresshown) CSQC_DrawScores = {
	//check for mouse 1
    
    
    if (catjump_pressed & 1)
    {
    	catjump_charge += frametime;
    	if (catjump_charge > 1)
		catjump_charge = 1;
    } 
    if (catjump_released)
		catjump_charge = 0;
		
    if (catswipe_pressed) {
    	catswipe_charge += frametime;
    	if (catswipe_charge > 0.7)
		catswipe_charge = 0.7;
    } 
    if (catswipe_released)
		catswipe_charge = 0;
};

void(vector virtsize, float showscores) CSQC_DrawHud = {
    screensize_x = virtsize_x;
    screensize_y = virtsize_y;
    screensize_z = 0;
    
    drawfill([screensize_x/2-100, screensize_y-27], [200, 2], '1 1 1', 0.3);
    drawfill([screensize_x/2-100, screensize_y-13], [200, 2], '1 1 1', 0.3);
    
    drawfill([(screensize_x/2)-110, screensize_y-27], [10, 16], '1 1 1', 0.3);
    drawfill([(screensize_x/2)+100, screensize_y-27], [10, 16], '1 1 1', 0.3);
    drawstring([(screensize_x/2)-150, screensize_y-23], "JUMP", '10 10', '1 1 1', 0.5, DRAWFLAG_NORMAL);
    drawpic([(screensize_x/2)-170, screensize_y-23], "gfx/jumpicon_7x8.png", [7, 8], '1 1 1', 0.5, DRAWFLAG_NORMAL);
    if (catjump_pressed)
    {
    
    float ratio = catjump_charge / 1;
    //print(ftos(ratio));
    vector bar_pos = [(screensize_x/2)-99, screensize_y-24];
    vector bar_size = [200*ratio, 10];
    vector bar_color = '0 1 0';

    drawfill(bar_pos, bar_size, bar_color, 0.5);
    }
    
	//write the player speed to the screen
    float speed = getstatf(STAT_SPEED);
    vector speedcolor = (speed > 350) ? '1 0 0' : '1 1 1';
    vector speedpos = [(screensize_x/2), screensize_y/2-10];
    string speed_to_screen = ftos(rint(speed));
    drawstring(speedpos, speed_to_screen, '8 8 0', speedcolor, 1, 0);
	
    drawfill([screensize_x/2-100, screensize_y-45], [200, 2], '1 1 1', 0.3);
    drawfill([screensize_x/2-100, screensize_y-31], [200, 2], '1 1 1', 0.3);
    
    drawfill([(screensize_x/2)-110, screensize_y-45], [10, 16], '1 1 1', 0.3);
    drawfill([(screensize_x/2)+100, screensize_y-45], [10, 16], '1 1 1', 0.3);
    drawstring([(screensize_x/2)-160, screensize_y-42], "SWIPE", '10 10', '1 1 1', 0.5, DRAWFLAG_NORMAL);
    
    drawpic([(screensize_x/2)-170, screensize_y-42], "gfx/pawprint.png", [8, 8], '1 1 1', 0.5, DRAWFLAG_NORMAL);

    // Swipe charge bar (above cat jump bar)
    if (catswipe_pressed)
    {
    	dprint("catswipe being pressed\n");
        float swipe_ratio = catswipe_charge / 0.7;
        vector swipe_bar_pos = [(screensize_x/2)-99, screensize_y-42]; // above jump bar
        vector swipe_bar_size = [200*swipe_ratio, 10];
        vector swipe_bar_color = '0 0.4 1'; // bluish
        drawfill(swipe_bar_pos, swipe_bar_size, swipe_bar_color, 0.3);
    }
    
};
/*
void(float w, float h, float showmenu) CSQC_UpdateView =
{
    clearscene();

    // Main view setup
    setviewprop(VF_MIN, '0 0 0');
    setviewprop(VF_SIZE, [w, h, 0]);
    //setviewprop(VF_ORIGIN, getvieworg());
    //setviewprop(VF_ANGLES, getviewangles());
    setviewprop(VF_DRAWCROSSHAIR, TRUE);
    setviewprop(VF_DRAWENGINESBAR, TRUE);
    addentities(MASK_ENGINE | MASK_VIEWMODEL);
	
    renderscene();

    // PIP (secondary camera)
	float ssqcentnum = getstatf(STAT_VIEW2);
	if (ssqcentnum) {
		vector org = (vector)getentity(getstatf(STAT_VIEW2), GE_ORIGINANDVECTORS);
		vector ang = vectoangles(v_forward, v_up); ang_x *= autocvar(r_meshpitch, -1);
		setviewprop(VF_MIN, [0, 0]);
		setviewprop(VF_SIZE, [320, 200]);
		setviewprop(VF_DRAWENGINESBAR, FALSE); //no thanks....
		setviewprop(VF_DRAWCROSSHAIR, FALSE); //turn that off too.
		setviewprop(VF_ORIGIN, org);
		setviewprop(VF_ANGLES, ang);
		setviewprop(VF_VIEWENTITY, ssqcentnum); //note: will faff with RF_EXTERNALMODEL and strip any RF_VIEWMODEL ents
		renderscene();
	}
	CSQC_DrawScores([w,h,0], 0);
	CSQC_DrawHud([w,h,0],0);
};
*/
void(float w, float h, float showmenu) CSQC_UpdateView =
{
    clearscene();

    // ----------------------------------
    // Step 1: Render main view normally
    // ----------------------------------
    setviewprop(VF_MIN, '0 0 0');
    setviewprop(VF_SIZE, [w, h, 0]);
    setviewprop(VF_DRAWCROSSHAIR, TRUE);
    setviewprop(VF_DRAWENGINESBAR, TRUE);
    addentities(MASK_ENGINE | MASK_VIEWMODEL);

    renderscene();
    // ----------------------------------
    // Step 2: Render view2 (PiP) to texture
    // ----------------------------------
    float ssqcentnum = getstatf(STAT_VIEW2);
    if (ssqcentnum) {
    	setviewprop(VF_RT_DESTCOLOUR, "PiPScene", -IMGFMT_R8G8B8A8, [320, 200]); // nearest filtering
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
        setviewprop(VF_RT_DESTCOLOUR, (string)__NULL__); // reset output
        // ----------------------------------
        // Step 3: Post-process the PiP
        // ----------------------------------
        drawpic('0 0 0', "PiPScene", [320, 200, 0], '1 1 1', 1, DRAWFLAG_NORMAL);        
    }
    

    
    // Draw HUD elements after everything
    CSQC_DrawScores([w, h, 0], 0);
    CSQC_DrawHud([w, h, 0], 0);

};

/*
void(vector virtsize, float showscores) CSQC_DrawHud = {
    screensize_x = virtsize_x;
    screensize_y = virtsize_y;
    screensize_z = 0;
    
    drawfill([screensize_x/2-100, screensize_y-27], [200, 2], '1 1 1', 0.3);
    drawfill([screensize_x/2-100, screensize_y-13], [200, 2], '1 1 1', 0.3);
    
    drawfill([(screensize_x/2)-110, screensize_y-27], [10, 16], '1 1 1', 0.3);
    drawfill([(screensize_x/2)+100, screensize_y-27], [10, 16], '1 1 1', 0.3);
    drawstring([(screensize_x/2)-150, screensize_y-23], "JUMP", '10 10', '1 1 1', 0.5, DRAWFLAG_NORMAL);
    drawpic([(screensize_x/2)-170, screensize_y-23], "gfx/jumpicon_7x8.png", [7, 8], '1 1 1', 0.5, DRAWFLAG_NORMAL);
    if (catjump_pressed)
    {
    
    float ratio = catjump_charge / 1;
    //print(ftos(ratio));
    vector bar_pos = [(screensize_x/2)-99, screensize_y-24];
    vector bar_size = [200*ratio, 10];
    vector bar_color = '0 1 0';

    drawfill(bar_pos, bar_size, bar_color, 0.5);
    }
    
	//write the player speed to the screen
    float speed = getstatf(STAT_SPEED);
    vector speedcolor = (speed > 350) ? '1 0 0' : '1 1 1';
    vector speedpos = [(screensize_x/2), screensize_y/2-10];
    string speed_to_screen = ftos(rint(speed));
    drawstring(speedpos, speed_to_screen, '8 8 0', speedcolor, 1, 0);
	
    drawfill([screensize_x/2-100, screensize_y-45], [200, 2], '1 1 1', 0.3);
    drawfill([screensize_x/2-100, screensize_y-31], [200, 2], '1 1 1', 0.3);
    
    drawfill([(screensize_x/2)-110, screensize_y-45], [10, 16], '1 1 1', 0.3);
    drawfill([(screensize_x/2)+100, screensize_y-45], [10, 16], '1 1 1', 0.3);
    drawstring([(screensize_x/2)-160, screensize_y-42], "SWIPE", '10 10', '1 1 1', 0.5, DRAWFLAG_NORMAL);
    
    drawpic([(screensize_x/2)-170, screensize_y-42], "gfx/pawprint.png", [8, 8], '1 1 1', 0.5, DRAWFLAG_NORMAL);

    // Swipe charge bar (above cat jump bar)
    if (catswipe_pressed)
    {
        float swipe_ratio = catswipe_charge / 0.7;
        vector swipe_bar_pos = [(screensize_x/2)-99, screensize_y-42]; // above jump bar
        vector swipe_bar_size = [200*swipe_ratio, 10];
        vector swipe_bar_color = '0 0.4 1'; // bluish
        drawfill(swipe_bar_pos, swipe_bar_size, swipe_bar_color, 0.3);
    }
    
};
*/

