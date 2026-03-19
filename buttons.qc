.vector box_mins;
.vector box_maxs;

// button and multiple button

void() button_wait;
void() button_return;

void() button_wait =
{
	self.state = STATE_TOP;
	self.nextthink = self.ltime + self.wait;
	self.think = button_return;
	activator = self.enemy;
	self.frame = 1;			// use alternate textures

	if (self.estate != STATE_ACTIVE)
		return;
	
	SUB_UseTargets();
	
};

void() button_done =
{
	self.state = STATE_BOTTOM;
};

void() button_return =
{
	if (self.estate != STATE_ACTIVE) return;

	self.state = STATE_DOWN;
	SUB_CalcMove (self.pos1, self.speed, button_done);
	self.frame = 0;			// use normal textures
	if (self.health)
		self.takedamage = DAMAGE_YES;	// can be shot again
};


void() button_blocked =
{	// do nothing, just don't ome all the way back out
};


void() button_fire =
{
	if (self.estate != STATE_ACTIVE) return;

	if (self.state == STATE_UP || self.state == STATE_TOP)
		return;

	sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

	self.state = STATE_UP;
	SUB_CalcMove (self.pos2, self.speed, button_wait);
};


void() button_use =
{
	self.enemy = activator;
	button_fire ();
};

void() button_touch =
{
	if (other.classname != "player")
		return;
	self.enemy = other;
	button_fire ();
};

void() button_killed =
{
	if (self.estate != STATE_ACTIVE) return;

	self.enemy = damage_attacker;
	self.health = self.max_health;
	self.takedamage = DAMAGE_NO;	// wil be reset upon return
	button_fire ();
};



// adapted from Copper, thanks Lunaran
void(entity b) button_lock =
{
	entity oself;

	if (b.estate == STATE_INACTIVE)
		return;

	oself = self;
	self = b;

	if (self.state == STATE_UP || self.state == STATE_TOP)
		self.prevstate = STATE_TOP;
	else 
		self.prevstate = STATE_BOTTOM;

	if (self.max_health)
		self.takedamage = DAMAGE_NO;
	self.state = STATE_UP;
	SUB_CalcMove (self.pos2, self.speed, button_wait);
	self.estate = STATE_INACTIVE;

	self = oself;
}

void(entity b, float dontresetstate) button_unlock =
{
	entity oself;

	if (b.estate == STATE_ACTIVE)
		return;

	oself = self;
	self = b;

	if (!dontresetstate || self.wait != -1 || self.prevstate == STATE_BOTTOM) {
		if (self.max_health)
		{
			self.takedamage = DAMAGE_YES;
			self.health = self.max_health;
		}
		self.frame = 0;			// use normal textures
		self.state = STATE_DOWN;
		SUB_CalcMove (self.pos1, self.speed, button_done);
	}

	self.estate = STATE_ACTIVE;

	self = oself;
}


/*QUAKED func_button (0 .5 .8) ? X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
When a button is touched, it moves some distance in the direction of it's angle, triggers all of it's targets, waits some time, then returns to it's original position where it can be triggered again.

"angle"	determines the opening direction
"target"	all entities with a matching targetname will be used
"speed"	override the default 40 speed
"wait"	override the default 1 second wait (-1 = never return)
"lip"	override the default 4 pixel lip remaining at end of move
"health"	if set, the button must be killed instead of touched
"sounds"
0) steam metal
1) wooden clunk
2) metallic click
3) in-out
*/
void() func_button =
{
	if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
		return;

	if (self.sounds == 0)
	{
		precache_sound ("buttons/airbut1.wav");
		//self.noise = "buttons/airbut1.wav";
	}
	if (self.sounds == 1)
	{
		precache_sound ("buttons/switch21.wav");
		self.noise = "buttons/switch21.wav";
	}
	if (self.sounds == 2)
	{
		precache_sound ("buttons/switch02.wav");
		self.noise = "buttons/switch02.wav";
	}
	if (self.sounds == 3)
	{
		precache_sound ("buttons/switch04.wav");
		self.noise = "buttons/switch04.wav";
	}

	SetMovedir ();

	self.movetype = MOVETYPE_PUSH;
	self.solid = SOLID_BSP;
	setmodel (self, self.model);

	self.blocked = button_blocked;
	self.use = button_use;

	if (self.health)
	{
		self.max_health = self.health;
		self.th_die = button_killed;
		self.takedamage = DAMAGE_YES;
	}
	else
		self.touch = button_touch;

	if (!self.speed)
		self.speed = 40;
	if (!self.wait)
		self.wait = 1;
	if (!self.lip)
		self.lip = 4;

	self.state = STATE_BOTTOM;

	self.pos1 = self.origin;
	self.pos2 = self.pos1 + self.movedir*(fabs(self.movedir*self.size) - self.lip);
};


void() pressureplate_check =
{
	dprint("think logic at ");
	dprint(ftos(time));
	dprint("\n");
    entity pressure_plate_find;
    entity found_entity = other;
    //vector plate_mins = self.box_mins;
    //vector plate_maxs = self.box_maxs;
    vector plate_mins = self.absmin;
    vector plate_maxs = self.absmax;
    vector box_origin = (plate_mins + plate_maxs) * 0.5;
    float found = 0;
    dprint("think logic\n");
    pressure_plate_find = findradius(box_origin, 96);
    while(pressure_plate_find)
    {
    	dprint("check ent\n");
    	dprint("entity origin\n");
    	dprint(vtos(pressure_plate_find.origin));
    	dprint("\n");
    	
    	dprint("plate bounds:\n");
    	dprint(vtos(plate_mins));
    	dprint("\n");
    	dprint(vtos(plate_maxs+48));
    	dprint("\n");
    	
        if ((pressure_plate_find.flags & FL_CLIENT) || pressure_plate_find.movetype != MOVETYPE_NONE)
        {
        	dprint("check area\n");
        	dprint(pressure_plate_find.classname);
        	dprint("<--classname\n");
        	/*
        	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_GUNSHOT);
		WriteCoord (MSG_BROADCAST, box_origin_x);
		WriteCoord (MSG_BROADCAST, box_origin_y);
		WriteCoord (MSG_BROADCAST, box_origin_z+128);
		
        	WriteByte (MSG_BROADCAST, SVC_TEMPENTITY);
		WriteByte (MSG_BROADCAST, TE_KNIGHTSPIKE);
		WriteCoord (MSG_BROADCAST, pressure_plate_find.origin_x);
		WriteCoord (MSG_BROADCAST, pressure_plate_find.origin_y);
		WriteCoord (MSG_BROADCAST, pressure_plate_find.origin_z);
		*/
        	
            if (pressure_plate_find.origin_x >= plate_mins_x && pressure_plate_find.origin_x <= plate_maxs_x &&
                pressure_plate_find.origin_y >= plate_mins_y && pressure_plate_find.origin_y <= plate_maxs_y &&
                pressure_plate_find.origin_z >= plate_mins_z && pressure_plate_find.origin_z <= (plate_maxs_z+48))
            {
            	dprint("found something\n");
            	found_entity = pressure_plate_find;
                found = 1;
                break;
            }
        }
        pressure_plate_find = pressure_plate_find.chain;
    }

    if (found)
    {
        activator = found_entity;
        dprint("hey player and or object\n");
        SUB_UseTargets();
        self.nextthink = time + 0.1;
    }
    else
    {
    	dprint("lol peace\n");
        self.think = SUB_Null;
    }
};

void() pressureplate_touch =
{
	entity toucher; 
	toucher = other;
	activator = other;
    if (!(toucher.flags & FL_CLIENT) && toucher.movetype == MOVETYPE_NONE)
        return; // ignore world brushes

    // Optional: prevent constant triggering
    if (time < self.think_time_pressure)
        return;
    
    // Spawnflag-based behavior
    if (self.spawnflags & PRESSPLATE_CONTINUOUS)
    {   
	    //dprint("player (or something) is pressing\n");
	    self.think = pressureplate_check;
	    self.nextthink = time + 0.1;
	    //SUB_UseTargets();
	    //self.think_time_pressure = time + 0.1;
    }
    else
    {
    	dprint("using targets and setting wait time pressure\n");
        SUB_UseTargets();
        self.think_time_pressure = 99999999;        
    }

    //SUB_UseTargets();  // fire target

    // Optional: animate or play sound
    //sound(self, CHAN_VOICE, "buttons/airbut1.wav", 1, ATTN_NORM);
};


void() func_pressureplate =
{
    self.solid = SOLID_BBOX;
    self.movetype = MOVETYPE_NONE;
    self.touch = pressureplate_touch;
    setmodel(self, self.model);
    setsize(self, self.mins, self.maxs);
    self.box_mins = self.mins;
    self.box_maxs = self.maxs;
    //self.think = pressureplate_check;
    self.takedamage = DAMAGE_NO;

    // Optional visual cue
    //self.effects = EF_BLUE; // or whatever
};