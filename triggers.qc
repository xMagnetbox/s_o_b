
// entity	s;


void() trigger_reactivate =
{
	self.solid = SOLID_TRIGGER;
};

//=============================================================================

float	SPAWNFLAG_NOMESSAGE = 1;
float	SPAWNFLAG_NOTOUCH = 1;
float SPAWNFLAG_TURNS_OFF = 2; //used for Wait for retrigger spawnflag

// the wait time has passed, so set back up for another activation
void() multi_wait =
{
	if (self.max_health)
	{
		self.health = self.max_health;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
	}
};


// the trigger was just touched/killed/used
// self.enemy should be set to the activator so it can be held through a delay
// so wait for the delay time before firing
void() multi_trigger =
{
	if (self.nextthink > time)
	{
		return;		// allready been triggered
	}

	if (self.classname == "trigger_secret")
	{
		if (self.enemy.classname != "player")
			return;
		if (cutscene)
				return;     // Don't activate in cutscene mode
		found_secrets = found_secrets + 1;
		WriteByte (MSG_ALL, SVC_FOUNDSECRET);
	}
	
	if (self.classname == "trigger_vhs_shader")
	{
		if (self.speed == 1)
		{
			cvar_set("r_postprocshader", "vhs_effect");
			cvar_set("r_vhs_scanstrength", "1");
			cvar_set("r_vhs_waviness", "0.002");
			cvar_set("r_vhs_desaturation", "0.45");
			dprint("vhs on \n\n");
		}
		else
		{
			cvar_set("r_vhs_scanstrength", "0");
			cvar_set("r_postprocshader", "");
			dprint("vhs off \n\n");
		}
	}

	if (self.noise != "")
		sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);

// don't trigger again until reset
	self.takedamage = DAMAGE_NO;

	activator = self.enemy;

	SUB_UseTargets();

	if (self.wait > 0)
	{
		self.think = multi_wait;
		self.nextthink = time + self.wait;
		if (self.spawnflags & SPAWNFLAG_TURNS_OFF)
		{
			self.is_waiting = 1;
			SUB_CheckWaiting();
		}
	}
	else
	{	// we can't just remove (self) here, because this is a touch function
		// called wheil C code is looping through area links...
		self.touch = SUB_Null;
		self.nextthink = time + 0.1;
		self.think = SUB_Remove;
	}
};

void() multi_killed = //dumptruck_ds
{
	if (self.estate != STATE_ACTIVE)	// Supa, restore health and do nothing if we're still waiting to be activated
	{
		self.health		= self.max_health;	// nyah nyah~!
		self.takedamage	= DAMAGE_YES;
		self.solid		= SOLID_BBOX;

		return;
	}

	self.enemy = damage_attacker;
	multi_trigger();
};

void() multi_use = //dumptruck_ds
{
	self.enemy = activator;
	multi_trigger();
};

void() multi_touch = //dumptruck_ds
{

	if (other.classname != "player")
		return;

	// from Copper -- dumptruck_ds
	if (other.movetype == MOVETYPE_NOCLIP)
		return;

	if (self.estate != STATE_ACTIVE)
		return;

// if the trigger has an angles field, check player's facing direction
	if (self.movedir != '0 0 0')
	{
		makevectors (other.angles);
		if (v_forward * self.movedir < 0)
			return;		// not facing the right way
	}

	self.enemy = other;
	multi_trigger ();
};

/*QUAKED trigger_multiple (.5 .5 .5) ? notouch WAIT_FOR_RETRIGGER X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY

Variable sized repeatable trigger.  Must be targeted at one or more entities.  If "health" is set, the trigger must be killed to activate each time.
If "WAIT_FOR_RETRIGGER" is set, it must be triggered by another entity before it can trigger again.
If "delay" is set, the trigger waits some time after activating before firing.
"wait" : Seconds between triggerings. (.2 default)
If notouch is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by trigger_relay!
sounds
1) secret
2) beep beep
3) large switch
set "message" to text string
"is_waiting" : If set to 1, this trigger will do nothing until another trigger activates it
*/
void() trigger_multiple =
{
	if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
		return;

	if (self.sounds == 1)
	{
		precache_sound ("misc/secret.wav");
		self.noise = "misc/secret.wav";
	}
	else if (self.sounds == 2)
	{
		precache_sound ("misc/talk.wav");
		self.noise = "misc/talk.wav";
	}
	else if (self.sounds == 3)
	{
		precache_sound ("misc/trigger1.wav");
		self.noise = "misc/trigger1.wav";
	}

	if (!self.wait)
	{
		self.wait = 0.2;
	}
	else if (self.wait < 0 && (self.spawnflags & SPAWNFLAG_TURNS_OFF))
	{
		objerror("Wait for retrigger and negative wait don't make sense");
	}
	self.use = multi_use;

	InitTrigger ();

	if (self.health)
	{
		if (self.spawnflags & SPAWNFLAG_NOTOUCH)
			objerror ("health and notouch don't make sense\n");
		self.max_health = self.health;
		self.th_die = multi_killed;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
		setorigin (self, self.origin);	// make sure it links into the world
	}
	else
	{
		if ( !(self.spawnflags & SPAWNFLAG_NOTOUCH) )
		{
			self.touch = multi_touch;
		}
	}

	SUB_CheckWaiting();
};

/*QUAKED trigger_multiple_shaderchange

Variable sized repeatable trigger.  Must be targeted at one or more entities.  
If "health" is set, the trigger must be killed to activate each time.
If "WAIT_FOR_RETRIGGER" is set, it must be triggered by another entity before it can trigger again.
If "delay" is set, the trigger waits some time after activating before firing.
"wait" : Seconds between triggerings. (.2 default)
If notouch is set, the trigger is only fired by other entities, not by touching.
NOTOUCH has been obsoleted by trigger_relay!
sounds
SET SPEED TO 1 TO TURN ON, DON'T SET TO TURN OFF
1) secret
2) beep beep
3) large switch
set "message" to text string
"is_waiting" : If set to 1, this trigger will do nothing until another trigger activates it
*/
void() trigger_vhs_shader =
{
	if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
		return;

	if (self.sounds == 1)
	{
		precache_sound ("misc/secret.wav");
		self.noise = "misc/secret.wav";
	}
	else if (self.sounds == 2)
	{
		precache_sound ("misc/talk.wav");
		self.noise = "misc/talk.wav";
	}
	else if (self.sounds == 3)
	{
		precache_sound ("misc/trigger1.wav");
		self.noise = "misc/trigger1.wav";
	}

	if (!self.wait)
	{
		self.wait = 0.2;
	}
	else if (self.wait < 0 && (self.spawnflags & SPAWNFLAG_TURNS_OFF))
	{
		objerror("Wait for retrigger and negative wait don't make sense");
	}
	self.use = multi_use;

	InitTrigger ();

	if (self.health)
	{
		if (self.spawnflags & SPAWNFLAG_NOTOUCH)
			objerror ("health and notouch don't make sense\n");
		self.max_health = self.health;
		self.th_die = multi_killed;
		self.takedamage = DAMAGE_YES;
		self.solid = SOLID_BBOX;
		setorigin (self, self.origin);	// make sure it links into the world
	}
	else
	{
		if ( !(self.spawnflags & SPAWNFLAG_NOTOUCH) )
		{
			self.touch = multi_touch;
		}
	}

	SUB_CheckWaiting();
};

/*QUAKED trigger_once (.5 .5 .5) ? notouch X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY

Variable sized trigger. Triggers once, then removes itself.  You must set the key "target" to the name of another object in the level that has a matching
"targetname".  If "health" is set, the trigger must be killed to activate.
If notouch is set, the trigger is only fired by other entities, not by touching.
if "killtarget" is set, any objects that have a matching "target" will be removed when the trigger is fired.
if "angle" is set, the trigger will only fire when someone is facing the direction of the angle.  Use "360" for an angle of 0.
sounds
1) secret
2) beep beep
3) large switch
set "message" to text string
*/
void() trigger_once =
{
	if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
		return;

	self.wait = -1;
	trigger_multiple();
};

//=============================================================================

/*QUAKED trigger_relay (.5 .5 .5) (-8 -8 -8) (8 8 8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
This fixed size trigger cannot be touched, it can only be fired by other events.  It can contain killtargets, targets, delays, and messages.
*/
void() trigger_relay =
{
	if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
		return;

	self.use = SUB_UseTargets;
};

/* Use if you want to have something displayed to the screen if it's an 'object' for song of boyd*/
void() trigger_relay_clientmessage =
{
	if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
		return;

	self.use = SUB_UseTargets;
};


//=============================================================================

/*QUAKED trigger_secret (.5 .5 .5) ? X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
secret counter trigger
sounds
1) secret
2) beep beep
set "message" to text string
*/
void() trigger_secret =
{
	if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
		return;

	total_secrets = total_secrets + 1;
	self.wait = -1;
	if (!self.message)
		self.message = "You found a secret area!";
	if (!self.sounds)
		self.sounds = 1;

	if (self.sounds == 1)
	{
		precache_sound ("misc/secret.wav");
		self.noise = "misc/secret.wav";
	}
	else if (self.sounds == 2)
	{
		precache_sound ("misc/talk.wav");
		self.noise = "misc/talk.wav";
	}

	trigger_multiple ();
};

//=============================================================================


void() counter_use =
{
	if (self.estate != STATE_ACTIVE) return;

	self.count = self.count - 1;
	if (self.count < 0)
		return;

	if (self.count != 0)
	{
		if (activator.classname == "player"
		&& (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0)
		{
			if (self.count >= 4)
				centerprint (activator, "There are more to go...");
			else if (self.count == 3)
				centerprint (activator, "Only 3 more to go...");
			else if (self.count == 2)
				centerprint (activator, "Only 2 more to go...");
			else
				centerprint (activator, "Only 1 more to go...");
		}
		return;
	}

	if (activator.classname == "player"
	&& (self.spawnflags & SPAWNFLAG_NOMESSAGE) == 0)
		centerprint(activator, "Sequence completed!");
	self.enemy = activator;
	multi_trigger ();
};

/*QUAKED trigger_counter (.5 .5 .5) ? nomessage X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY

Acts as an intermediary for an action that takes multiple inputs.

If nomessage is not set, t will print "1 more.. " etc when triggered and "sequence complete" when finished.

After the counter has been triggered "count" times (default 2), it will fire all of it's targets and remove itself.
*/
void() trigger_counter =
{
	if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
		return;

	self.wait = -1;
	if (!self.count)
		self.count = 2;

	self.use = counter_use;
};
//teleport stuff goes back here
/*
==============================================================================

trigger_setskill

==============================================================================
*/

void() trigger_skill_touch =
{
	// from Copper -- dumptruck_ds
	if (!CheckValidTouch()) return;

	cvar_set ("skill", self.message);
};

/*QUAKED trigger_setskill (.5 .5 .5) ? X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
sets skill level to the value of "message".
Only used on start map.
*/
void() trigger_setskill =
{
	if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
		return;

	InitTrigger ();
	self.touch = trigger_skill_touch;

	SUB_CheckWaiting();
};


/*
==============================================================================

ONLY REGISTERED TRIGGERS

==============================================================================
*/

void() trigger_onlyregistered_touch =
{
	// from Copper -- dumptruck_ds
	if (!CheckValidTouch()) return;
	if (self.attack_finished > time)
	return;

	self.attack_finished = time + 2;
	if (cvar("registered"))
	{
		self.message = "";
		SUB_UseTargets ();
		remove (self);
	}
	else
	{
		if (self.message != "")
		{
			centerprint (other, self.message);
			sound (other, CHAN_BODY, "misc/talk.wav", 1, ATTN_NORM);
		}
	}
};

/*QUAKED trigger_onlyregistered (.5 .5 .5) ?
Only fires if playing the registered version, otherwise prints the message
*/
void() trigger_onlyregistered =
{
	if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
		return;

	precache_sound ("misc/talk.wav");
	InitTrigger ();
	self.touch = trigger_onlyregistered_touch;

	SUB_CheckWaiting();
};

//============================================================================

// 1998-07-03 hurt_touch fix by Robert Field  start
/*
void() hurt_on =
{
	self.solid = SOLID_TRIGGER;
	self.nextthink = -1;
};
*/
// 1998-07-03 hurt_touch fix by Robert Field  end

void() hurt_touch =
{

	if (self.estate != STATE_ACTIVE) return;

	// from Copper -- dumptruck_ds
	if (other.movetype == MOVETYPE_NOCLIP)
		return;

	if (other.takedamage && self.nextthink < time)
	{
// 1998-07-03 hurt_touch fix by Robert Field  start
//		self.solid = SOLID_NOT;
		if (time != self.hurt_together_time)
			if (time < self.hurt_nextthink)
				return;
// 1998-07-03 hurt_touch fix by Robert Field  end
		T_Damage (other, self, self, self.dmg);
// 1998-07-03 hurt_touch fix by Robert Field  start
//		self.think = hurt_on;
//		self.nextthink = time + 1;
		self.hurt_together_time = time;
		self.hurt_nextthink = time + 1;
// 1998-07-03 hurt_touch fix by Robert Field  end
	}
	return;
};

/*QUAKED trigger_hurt (.5 .5 .5) ? X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Any object touching this will be hurt
set dmg to damage amount
defalt dmg = 5
*/
void() trigger_hurt =
{
	if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
		return;

	InitTrigger ();
	self.touch = hurt_touch;
	if (!self.dmg)
		self.dmg = 5;

	SUB_CheckWaiting();
};

//============================================================================

//////////////////////////////////////////////////////////////////////////////
// start dumptruck_ds additions //////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

float PUSH_ONCE = 1;
float DT_STARTOFF = 8;  // trigger will start off
float DT_SILENT = 16; // push silently
float DT_NOISE = 32; // use custom sound using noise key/value

void() trigger_push_touch =
{
	if (self.estate != STATE_ACTIVE) return;

	// from Copper -- dumptruck_ds
	if (other.movetype == MOVETYPE_NOCLIP)
		return;
	if (other.classname == "grenade")
		other.velocity = self.speed * self.movedir * 10;
	else if (other.health > 0)
	{
		/*
		other.velocity = other.velocity + (self.speed * self.movedir * 10); //changed velocity to additive
		if (other.classname == "player")
		if (!(self.spawnflags & DT_SILENT))
		*/
		//new code, hopefully makes it more like a jump pad
		float proj = dotproduct(other.velocity, self.movedir);
		vector parallel = self.movedir * proj;
		vector perpendicular = other.velocity - parallel;
		vector pushv = self.movedir * self.speed * 10;
		
		//combine
		other.velocity = perpendicular + pushv;
		{
			if (other.fly_sound < time)
			if (!(self.spawnflags & DT_NOISE))
			{
				other.fly_sound = time + 1.5;
				sound (other, CHAN_AUTO, "ambience/windfly.wav", 1, ATTN_NORM);
			}
			else
			{
			other.fly_sound = time + 1.5;
			sound (other, CHAN_AUTO, self.noise, 1, ATTN_NORM);
			}
		}
	}
	if (self.spawnflags & PUSH_ONCE)
		remove(self);
};

// void() trigger_push_use =      //dumptruck_ds
// {
//   self.is_waiting = !self.is_waiting;
// }

/*QUAKED trigger_push (.5 .5 .5) ? PUSH_ONCE X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Pushes the player
*/
void() trigger_push = //dumptruck_ds
{
	if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
		return;

	InitTrigger ();
	precache_sound ("ambience/windfly.wav");
	self.touch = trigger_push_touch;

	if (!self.speed)
		self.speed = 1000;

	SUB_CheckWaiting();
};


void() push_toggle = //dumptruck_ds was based on hipnotic blocker_use now Alklaine estate

{
	if (self.estate != STATE_ACTIVE)
		self.estate = STATE_ACTIVE;
	else
		self.estate = STATE_INACTIVE;
};

/*QUAKED trigger_push_custom (.5 .5 .5) ? PUSH_ONCE DT_STARTOFF DT_SILENT X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY


dumptruck_ds

trigger_push_custom is a new entity. This can be used to create traps,
jumppads, currents in water and more.

If DT_STARTOFF flag is set, this disables the trigger.  This can be targeted and
toggled off and on. If the DT_SILENT flag is set it won't make the windfly
sound. Use DT_CUSTOM spawnflag and the noise key/value to use a custom push
sound. Custom sounds should be "one off" sounds NOT be looping.

Adapted from Hipnotic's func_togglewall */

void() trigger_push_custom =
{
	if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
		return;

	InitTrigger();
	precache_sound ("ambience/windfly.wav");
	self.use = push_toggle;
	self.touch = trigger_push_touch;

	if ( self.spawnflags & DT_STARTOFF )
		 {
			 self.estate = STATE_INACTIVE;
		 }

	if ( self.noise != "" )
    {
    precache_sound(self.noise);
	  }

		if (!self.speed)
			self.speed = 1000;

		SUB_CheckWaiting();
};


//============================================================================

void() trigger_monsterjump_touch =
{
	if (self.estate != STATE_ACTIVE) return;

	if ( other.flags & (FL_MONSTER | FL_FLY | FL_SWIM) != FL_MONSTER )
		return;

// set XY even if not on ground, so the jump will clear lips
	other.velocity_x = self.movedir_x * self.speed;
	other.velocity_y = self.movedir_y * self.speed;

	if ( !(other.flags & FL_ONGROUND) )
		return;

	other.flags = other.flags - FL_ONGROUND;

	other.velocity_z = self.height;
};

/*QUAKED trigger_monsterjump (.5 .5 .5) ? X X X DT_STARTOFF X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY

Walking monsters that touch this will jump in the direction of the trigger's angle
"speed" default to 200, the speed thrown forward
"height" default to 200, the speed thrown upwards

If DT_STARTOFF flag is set, this makes the trigger
inactive. This can be targeted and toggled off and on.
*/
void() trigger_monsterjump =
{
	if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
		return;

	self.use = push_toggle;
	if ( self.spawnflags & DT_STARTOFF ) // dumptruck_ds
		 {
			 self.estate = STATE_INACTIVE;
		 }
	if (!self.speed)
		self.speed = 200;
	if (!self.height)
		self.height = 200;
	if (self.angles == '0 0 0')
		self.angles = '0 360 0';
	InitTrigger ();
	self.touch = trigger_monsterjump_touch;

	SUB_CheckWaiting();
};
//////////////////////////////////////////////////////////////////////////////
// end dumptruck_ds additions //////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

//This is necros' trigger_void from Lost Chapters pack, modified by dumptruck_ds

float 	MONSTER_SAFE = 1;
float 	PLAYER_SAFE = 2;

void() trigger_void_touch =
{
	if (self.estate != STATE_ACTIVE) return;

	if (other.movetype == MOVETYPE_NOCLIP) // from Copper -- dumptruck_ds
		return FALSE;

	if (self.spawnflags & MONSTER_SAFE && other.flags & FL_MONSTER) return; //ignore monsters
	if (self.spawnflags & PLAYER_SAFE && other.flags & FL_CLIENT) return; // ignore players

	if (other.takedamage)
	{
		other.invincible_finished = 0; // kills even with Pentagram, this took forever to figure out!! -- dumptruck_ds
		T_Damage (other, self, self, other.health + 1000 /*, DTH_TRIGGER_VOID, 1, 1*/);

		if (other.flags & FL_MONSTER)
		remove(other);
	}

	if (other.classname == "gib" ||
	other.classname == "grenade" ||
	other.classname == "spike" ||
	other.classname == "missile")
	remove(other);

	if (other.flags & FL_ITEM)
	remove(other);

	force_retouch = 2;
};

/*QUAKED trigger_void (.5 .5 .5) ? X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Use this for a 'void' area.  removes monsters, gibs, ammo, etc...  also kills player.
*/
void() trigger_void =
{
	if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
		return;

	InitTrigger ();
	self.touch = trigger_void_touch;

	SUB_CheckWaiting();
};

/*==============================================================================
GIVE AND TAKE STUFF (WIP)

This is Axe only at the moment. Need to research removing all weapons.
==============================================================================*/

void() take_weapon_use =  //thanks to ShanJaq and Spike for their help on this.

{
	// from Copper -- dumptruck_ds
	if (!CheckValidTouch()) return;

	if (!(other.flags & FL_CLIENT))
	return;

		{
			multi_trigger();
			other.items &= ~IT_SHOTGUN;
			other.currentammo = !other.ammo_shells;
			other.ammo_shells = !other.ammo_shells;
			other.items = other.items - ( other.items & IT_SHELLS);
			W_SetCurrentAmmo();
			W_BestWeapon();
		}
};
/*QUAKED trigger_take_weapon (.5 .5 .5) ? X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY

Removes shotgun upon touch. You can also set "reset_items" in the worldspawn entity to accomplish an axe only start.
*/
void() trigger_take_weapon =
{
	if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
		return;

	self.wait = -1;
	trigger_multiple();
	self.touch = take_weapon_use;

	SUB_CheckWaiting();
};

void(float newtrack) changemusic =
{
  *world_sounds = newtrack;  //changing the field via a pointer
  //world.sounds has now been changed via our pointer, newly connecting players (like those connecting after the game is loaded) will get sent the new cd track's number.

  //let everyone currently on the server know.
  WriteByte(MSG_ALL, SVC_CDTRACK);
  WriteByte(MSG_ALL, newtrack);  //initial track
  WriteByte(MSG_ALL, newtrack);  //looped track... should generally be set the same as the initial track as most engines ignore it entirely so it might as well be sane for those that care.
};

//thanks to jleww via changemusic.rar --dumptruck_ds

void() trigger_changemusic_touch =
{
	// from Copper -- dumptruck_ds
	if (!CheckValidTouch()) return;

	if (!(other.flags & FL_CLIENT))
	{
		return;
	}
	changemusic(self.sounds);
	self.touch = SUB_Null;
	self.nextthink = (time + 0.1);
	self.think = SUB_Remove;
};
/*QUAKED trigger_changemusic (.5 .5 .5) ? X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
A trigger brush that changes the currently playing music track. The number of the track to play goes in the sounds key (just like worldspawn). */
void() trigger_changemusic =
{
	if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
		return;
		if (!self.sounds)
		{
			objerror("ERROR: trigger_changemusic needs valid track number in sounds field");
			return;
		}
	InitTrigger();
	self.touch = trigger_changemusic_touch;

	SUB_CheckWaiting();
};

void() trigger_cdtrack_use = //point entity version uses count for music track number for backwards compatibly in Adoria mod -- dumptruck_ds
{
	changemusic(self.count);
};
/*QUAKED trigger_cdtrack (.7 .7 .7) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
A point entity that changes the currently playing music track when triggered. The number of the track to play goes in the count key. e.g. 32 for track32.ogg  See manual trigger_changemusic for more information on formats and more.

NOTE: the track number uses the count key here but trigger_changemusic uses the sound key for the same info.
*/
void() trigger_cdtrack =
{
	if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
		return;
		if (!self.count)
		{
			objerror("ERROR: trigger_cdtrack needs valid track number in count field");
			return;
		}
	InitTrigger();
	self.use = trigger_cdtrack_use;
};
///////////////////////////////////////////////////////////////
//trigger_look (a.k.a. trigger_onlookat from NullPointPaladin!)
///////////////////////////////////////////////////////////////
void() onlookat_touch =
{
	// from Copper -- dumptruck_ds
	if (!CheckValidTouch()) return;

  if (self.nextthink > time)
  {
        return;        // allready been triggered
  }

    //added player view offset to make this more accurate to the player crosshairs
    local vector player_offset;
    player_offset = other.origin + other.view_ofs;

    makevectors(other.v_angle);

    //using speed to determine the reach of the trace
    if(!self.speed)
        self.speed = 500;
    traceline(player_offset, (player_offset + (v_forward * self.speed)), FALSE, other);

    if ((trace_ent.targetname == self.target))
    {
        // Play message if available
        if (self.message != "")
        {
            centerprint (other, self.message);
        }
        self.use = multi_trigger;
        SUB_UseTargets();

				if (self.noise != "")
				sound (self, CHAN_VOICE, self.noise, 1, ATTN_NORM);
				else
				sound (self, CHAN_VOICE, self.noise1, 1, ATTN_NORM);

        // added wait
        if (self.wait > 0)
        {
            self.think = multi_wait;
            self.nextthink = time + self.wait;
        }
        else
        {    // we can't just remove (self) here, because this is a touch function
            // called wheil C code is looping through area links...
            self.touch = SUB_Null;
            self.nextthink = time + 0.1;
            self.think = SUB_Remove;
        }
    }
};
/*QUAKED trigger_look (.5 .5 .5) ? X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
This will trigger when a player is within the brush trigger and looks directly at a target entity.
Use the first target key for the "looked at entity" and use the subsequent targets (2-4) to trigger other events.

speed = Distance from player to search for trigger, adjust if the target is too far from the trigger  (default 500 units)
wait = Time between re-triggering (default 0)
sounds = 0-3 are standard Quake trigger choices, 4 allows a custom sound, requires a path set in noise1 key
noise1 = Path to custom sound. Use with sounds key set to 4  (e.g. fish/bite.wav)

See manual for complete details. See pd_cutscenes sample map for example
*/
void() trigger_look =
{
    if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
        return;

    //play all the sounds available for a normal trigger
    if (self.sounds == 0)
    {
        precache_sound ("misc/null.wav");
        self.noise = "misc/null.wav";
    }
    else if (self.sounds == 1)
    {
        precache_sound ("misc/secret.wav");
        self.noise = "misc/secret.wav";
    }
    else if (self.sounds == 2)
    {
        precache_sound ("misc/talk.wav");
        self.noise = "misc/talk.wav";
    }
    else if (self.sounds == 3)
    {
        precache_sound ("misc/trigger1.wav");
        self.noise = "misc/trigger1.wav";
    }
    else if (self.sounds == 4)
    {
			if (!self.noise1) //dumptruck_ds
			{
				objerror ("no soundfile set in noise1!\n");
				remove(self);
				return;
			}
			else
        precache_sound (self.noise1);
				self.noise = self.noise1;
    }

    InitTrigger();
    self.touch = onlookat_touch;

    SUB_CheckWaiting();
};





///////////////////////////////////////////////////////////////
//trigger_look_shader -- to replay roq files!!
///////////////////////////////////////////////////////////////
void() onlookat_touch_shader =
{
	// from Copper -- dumptruck_ds
	if (!CheckValidTouch()) return;
  if (self.shader_wait > time + self.wait)
  {
        dprint("showshaders is waiting\n");
        return;        // allready been triggered
  }
  if (self.nextthink > time)
  {
	cvar_set("r_showshaders", "0");
        dprint("showshaders 0\n");
        return;        // already been triggered
  }

    //added player view offset to make this more accurate to the player crosshairs
    local vector player_offset;
    player_offset = other.origin + other.view_ofs;

    makevectors(other.v_angle);

    //using speed to determine the reach of the trace
    if(!self.speed)
        self.speed = 500;
    traceline(player_offset, (player_offset + (v_forward * self.speed)), FALSE, other);

    if ((trace_ent.targetname == self.target))
    {
        
        // added wait
        if (self.wait > 0)
        {
		cvar_set("r_showshaders", "1");
		dprint("showshaders 1\n");
            self.think = multi_wait;
            self.nextthink = time + self.wait;
            self.shader_wait = time;
        }
        else
        {    // we can't just remove (self) here, because this is a touch function
            // called wheil C code is looping through area links...
            self.touch = SUB_Null;
            self.nextthink = time + 0.1;
            self.think = SUB_Remove;
        }
     }
};
/*QUAKED trigger_look (.5 .5 .5) ? X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
This will trigger when a player is within the brush trigger and looks directly at a target entity.
Use the first target key for the "looked at entity" and use the subsequent targets (2-4) to trigger other events.

speed = Distance from player to search for trigger, adjust if the target is too far from the trigger  (default 500 units)
wait = Time between re-triggering (default 0)
sounds = 0-3 are standard Quake trigger choices, 4 allows a custom sound, requires a path set in noise1 key
noise1 = Path to custom sound. Use with sounds key set to 4  (e.g. fish/bite.wav)

See manual for complete details. See pd_cutscenes sample map for example
*/
void() trigger_look_shader =
{
    if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
        return;

    //play all the sounds available for a normal trigger
    if (self.sounds == 0)
    {
        precache_sound ("misc/null.wav");
        self.noise = "misc/null.wav";
    }
    else if (self.sounds == 1)
    {
        precache_sound ("misc/secret.wav");
        self.noise = "misc/secret.wav";
    }
    else if (self.sounds == 2)
    {
        precache_sound ("misc/talk.wav");
        self.noise = "misc/talk.wav";
    }
    else if (self.sounds == 3)
    {
        precache_sound ("misc/trigger1.wav");
        self.noise = "misc/trigger1.wav";
    }
    else if (self.sounds == 4)
    {
			if (!self.noise1) //dumptruck_ds
			{
				objerror ("no soundfile set in noise1!\n");
				remove(self);
				return;
			}
			else
        precache_sound (self.noise1);
				self.noise = self.noise1;
    }

    InitTrigger();
    self.touch = onlookat_touch_shader;

    SUB_CheckWaiting();
};






void() trigger_target_change_use =
{
	if (self.estate != STATE_ACTIVE) return;

    for (entity e = world; (e = find(e, targetname, self.target)); )
    {
      if (!self.cnt || self.cnt == 1)
      {
        e.target = self.message;
      }
      else if (self.cnt == 2)
      {
        e.target2 = self.message;
      }
      else if (self.cnt == 3)
      {
        e.target3 = self.message;
      }
      else if (self.cnt == 4)
      {
        e.target4 = self.message;
      }
    }
};


/*QUAKED trigger_changetarget (.5 .5 .5) ?
Changes an entity's target field

target = entity to change
message = new value for target field
cnt = target field to change, null defaults to target

*/
void() trigger_changetarget =
{
    if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
        return;

    self.use = trigger_target_change_use;
};




/*
=============================================================

target_setstate

=============================================================
*/
float SETSTATE_STARTOFF = 1;
float SETSTATE_CLOSEALLDOORS = 2;
float SETSTATE_DONTRESETBUTTON = 4;

float(entity e) entity_get_state = {
	if(e.classname == "func_door") return e.owner.estate;
	else return e.estate;
};

void(entity e, float state, float flags) entity_set_state = {
	float closealldoors;

	if(e.classname == "func_button") {
		if (state == STATE_ACTIVE) button_unlock(e, flags & SETSTATE_DONTRESETBUTTON);
		else button_lock(e);
	}
	else if(e.classname == "func_door") {
		if (flags & SETSTATE_CLOSEALLDOORS) closealldoors = 1;

		if (state == STATE_ACTIVE) door_estate_unlock(e, closealldoors);
		else door_estate_lock(e, closealldoors);
	}
	else e.estate = state;

	if (e.is_waiting > 0 && state == STATE_ACTIVE) {
		SUB_CallAsSelf(SUB_EndWaiting, e);
	}

	//if (e.touch && e.touch != SUB_Null) {
	//	force_retouch = 2;
	//}
};

void(string matchstring, .string matchfield, float state, float flags) target_setstate_set_target = {
	local entity t;

	t = find (world, matchfield, matchstring);
	while (t != world) {
		if(state == -1){
			if(entity_get_state(t) == STATE_ACTIVE) entity_set_state(t, STATE_INACTIVE, flags);
			else entity_set_state(t, STATE_ACTIVE, flags);
		}
		else entity_set_state(t, state, flags);

		t = find (t, matchfield, matchstring);
	}
};

void(float state) target_setstate_set_alltargets = {
	if (self.target && self.target != "") {
		target_setstate_set_target(self.target, targetname, state, self.spawnflags);
		target_setstate_set_target(self.target, targetname2, state, self.spawnflags);
		target_setstate_set_target(self.target, targetname3, state, self.spawnflags);
		target_setstate_set_target(self.target, targetname4, state, self.spawnflags);
	}
	if (self.target2 && self.target2 != "") {
		target_setstate_set_target(self.target2, targetname, state, self.spawnflags);
		target_setstate_set_target(self.target2, targetname2, state, self.spawnflags);
		target_setstate_set_target(self.target2, targetname3, state, self.spawnflags);
		target_setstate_set_target(self.target2, targetname4, state, self.spawnflags);
	}
	if (self.target3 && self.target3 != "") {
		target_setstate_set_target(self.target3, targetname, state, self.spawnflags);
		target_setstate_set_target(self.target3, targetname2, state, self.spawnflags);
		target_setstate_set_target(self.target3, targetname3, state, self.spawnflags);
		target_setstate_set_target(self.target3, targetname4, state, self.spawnflags);
	}
	if (self.target4 && self.target4 != "") {
		target_setstate_set_target(self.target4, targetname, state, self.spawnflags);
		target_setstate_set_target(self.target4, targetname2, state, self.spawnflags);
		target_setstate_set_target(self.target4, targetname3, state, self.spawnflags);
		target_setstate_set_target(self.target4, targetname4, state, self.spawnflags);
	}
};

void() target_setstate_use = {
	local float state;

	if (self.style == 1) state = STATE_ACTIVE;
	else if (self.style == 2) state = STATE_INACTIVE;
	else state = -1;

	target_setstate_set_alltargets(state);

};

void() target_setstate_startoff_think = {
	target_setstate_set_alltargets(STATE_INACTIVE);
};

void() target_setstate = {
	self.use = target_setstate_use;

	if(self.spawnflags & SETSTATE_STARTOFF) {
		// wait a bit while doors finish being set up
		self.think = target_setstate_startoff_think;
		self.nextthink = time + 0.2;
	}
};




/*
=============================================================

trigger_filter

=============================================================
*/


float FILTER_FIELD_STATE = 0;
float FILTER_FIELD_HEALTH = 1;
float FILTER_FIELD_WEAPON = 2;
float FILTER_FIELD_FLAGS = 3;
float FILTER_FIELD_SPAWNFLAGS = 4;
float FILTER_FIELD_CLASSNAME = 5;
float FILTER_FIELD_ESTATE = 6;
float FILTER_FIELD_TARGETNAME = 8;
float FILTER_FIELD_ITEMS = 10;
float FILTER_FIELD_COUNT = 11;
float FILTER_FIELD_CNT = 12;
float FILTER_FIELD_TYPE = 13;


float FILTER_FIELDTYPE_FLOAT = 0;
float FILTER_FIELDTYPE_STRING = 1;
float FILTER_FIELDTYPE_FLAG = 2;

float FILTER_OP_EQUALS = 0;
float FILTER_OP_LT = 1;
float FILTER_OP_LTE = 2;
float FILTER_OP_GT = 3;
float FILTER_OP_GTE = 4;
float FILTER_OP_BITMASK_AND = 5;
float FILTER_OP_BITMASK_OR = 6;

void() trigger_filter_use = {
	self.state = 0;

	if (self.estate != STATE_ACTIVE) return;

	entity targ;
	float targfloat;
	string targstring;

	float fieldtype, op, result;

	if (self.include != "") {
		targ = find(world, targetname, self.include);
		dprint("targ classname is \n");
		dprint(targ.classname);
		dprint("\n");
		if (!targ) targ = find(world, targetname2, self.include);
		if (!targ) return;
	}
	else
		targ = activator;

	op = self.weapon;

	switch (self.style) {
		case FILTER_FIELD_STATE:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.state;
			break;

		case FILTER_FIELD_ESTATE:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.estate;
			break;

		case FILTER_FIELD_HEALTH:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.health;
			break;

		case FILTER_FIELD_COUNT:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.count;
			break;

		case FILTER_FIELD_CNT:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.cnt;
			break;

		case FILTER_FIELD_WEAPON:
			fieldtype = FILTER_FIELDTYPE_FLOAT;
			targfloat = targ.weapon;
			break;

		case FILTER_FIELD_FLAGS:
			fieldtype = FILTER_FIELDTYPE_FLAG;
			targfloat = targ.flags;
			break;

		case FILTER_FIELD_SPAWNFLAGS:
			fieldtype = FILTER_FIELDTYPE_FLAG;
			targfloat = targ.spawnflags;
			break;

		case FILTER_FIELD_ITEMS:
			fieldtype = FILTER_FIELDTYPE_FLAG;
			targfloat = targ.items;
			break;

		case FILTER_FIELD_CLASSNAME:
			fieldtype = FILTER_FIELDTYPE_STRING;
			targstring = targ.classname;
			dprint(targstring);
			dprint(" filtered by classname\n");
			break;

		case FILTER_FIELD_TARGETNAME:
			fieldtype = FILTER_FIELDTYPE_STRING;
			targstring = targ.targetname;
			break;

		case FILTER_FIELD_TYPE:
			fieldtype = FILTER_FIELDTYPE_STRING;
			targstring = targ.type;
			break;
	}

	if (fieldtype == FILTER_FIELDTYPE_FLOAT) {
		if 		(op == FILTER_OP_EQUALS) 		{if (targfloat == self.count) result = 1;}
		else if (op == FILTER_OP_LT) 			{if (targfloat <  self.count) result = 1;}
		else if (op == FILTER_OP_LTE) 			{if (targfloat <= self.count) result = 1;}
		else if (op == FILTER_OP_GT) 			{if (targfloat >  self.count) result = 1;}
		else if (op == FILTER_OP_GTE) 			{if (targfloat >= self.count) result = 1;}
		else if (op == FILTER_OP_BITMASK_AND)	{if (targfloat &  self.count) result = 1;}
		else if (op == FILTER_OP_BITMASK_OR)	{if (targfloat |  self.count) result = 1;}
		else 									{if (targfloat == self.count) result = 1;}
	}
	else if (fieldtype == FILTER_FIELDTYPE_FLAG) {
		if 		(op == FILTER_OP_EQUALS) 		{if (targfloat == self.aflag) result = 1;}
		else if (op == FILTER_OP_BITMASK_AND)	{if (targfloat &  self.aflag) result = 1;}
		else if (op == FILTER_OP_BITMASK_OR)	{if (targfloat |  self.aflag) result = 1;}
		else 									{if (targfloat == self.aflag) result = 1;}
	}
	else if (fieldtype == FILTER_FIELDTYPE_STRING) {
		dprint("targstring is \n");
		dprint(targstring);
		dprint("\n");
		dprint("self.type is \n");
		dprint(self.type);
		dprint("\n");

		if (targstring == self.type) result = 1;
	}
	else {
		objerror ("invalid fieldtype");
		return;
	}

	if (self.spawnflags & 1) result = 1 - result; // negate
	if (result) {
		self.state = 1;

		if (self.spawnflags & 2 && activator.owner) activator = activator.owner; // relay activator as owner

		SUB_UseTargets();
		if (other.classname == "trigger_everything" && other.spawnflags & 1) {
			if (other.wait)	other.attack_finished = time + other.wait;
		}

	}
};

void() trigger_filter = {
	self.use = trigger_filter_use;

};


/*
=============================================================

trigger_everything

=============================================================
*/
/*
void() trigger_everything_touch = {
	if (self.estate != STATE_ACTIVE) return;

	if (time < self.attack_finished) return;

	activator = other;

	SUB_UseSpecificTarget(self.target, targetname);

	if (self.wait)
		if (!(self.spawnflags & 1)) self.attack_finished = time + self.wait;

};

void() trigger_everything = {
	InitTrigger();

	self.touch = trigger_everything_touch;
	SUB_CheckWaiting();
};

*/
void() trigger_everything_touch = {
	if (self.estate != STATE_ACTIVE) return;

	if (time < self.attack_finished) return;
	
	//Try to promote player to activator
	if (other.flags & FL_CLIENT)
		activator = other;
	else if (other.owner && (other.owner.flags & FL_CLIENT))
		activator = other.owner; // projectiles
	else if (other.i_dont_need_client_message)
		activator = other; // use if you want to use a trigger_everything and trigger_filter to do something
	else
		activator = find(world, classname, "player"); // use if you want to play a message
		

	SUB_UseSpecificTarget(self.target, targetname);

	if (self.wait)
		if (!(self.spawnflags & 1)) self.attack_finished = time + self.wait;
	if (other.nonsolid_me)
	{
		other.solid = SOLID_NOT;
	}
	if (other.destroy_me)
	{
		other.solid = SOLID_NOT;
		other.nextthink = time + 10;
		other.think = SUB_Remove;
	}
		

};

void() trigger_everything = {
	InitTrigger();

	self.touch = trigger_everything_touch;
	SUB_CheckWaiting();
};


/*
=============================================================

target_setcount

=============================================================
*/

void(string name, .string fld) target_setcount_set = {
	local entity t;

	t = find(world, fld, name);

	while (t) {
		if (self.style == 1)
			t.count += self.count;
		else
			t.count = self.count;

		t = find(t, fld, name);
	}
};

void() target_setcount_use = {
	if (self.target && self.target != "") {
		target_setcount_set(self.target, targetname);
		target_setcount_set(self.target, targetname2);
		target_setcount_set(self.target, targetname3);
		target_setcount_set(self.target, targetname4);
	}
	if (self.target2 && self.target2 != "") {
		target_setcount_set(self.target2, targetname);
		target_setcount_set(self.target2, targetname2);
		target_setcount_set(self.target2, targetname3);
		target_setcount_set(self.target2, targetname4);
	}
	if (self.target3 && self.target3 != "") {
		target_setcount_set(self.target3, targetname);
		target_setcount_set(self.target3, targetname2);
		target_setcount_set(self.target3, targetname3);
		target_setcount_set(self.target3, targetname4);
	}
	if (self.target4 && self.target4 != "") {
		target_setcount_set(self.target4, targetname);
		target_setcount_set(self.target4, targetname2);
		target_setcount_set(self.target4, targetname3);
		target_setcount_set(self.target4, targetname4);
	}

	if (self.spawnflags & 1) {
		if (self.style == 1)
			activator.count += activator.count;
		else
			activator.count = activator.count;
	}
};

void() target_setcount = {
	self.use = target_setcount_use;

};

void() trigger_monsterface_touch =
{
  // only affect ground monsters
  if ( other.flags & (FL_MONSTER | FL_FLY | FL_SWIM) != FL_MONSTER )
    return;

  if (!visibleToOther(other.enemy)) { // enemy is hidden
    other.t_length = time + self.wait + 0.2; // don't dodge around, just go straight
    other.ideal_yaw = self.angles_y; // face where I want
  }
}

void() trigger_monsterface_init =
{
	self.solid = SOLID_TRIGGER;
  setmodel (self, self.model);    // set size and link into world
  self.movetype = MOVETYPE_NONE;
  self.modelindex = 0;
  self.model = "";

  if (self.angles == '0 0 0')
    self.angles = '0 360 0';

  self.touch = trigger_monsterface_touch;
}

/*QUAKED trigger_monsterface (.5 .0 .5)
Running monsters that do not see their target and touch this will face in the direction of the trigger's angle instead of the unseen target.
Use this trigger to make monsters leave their sniping spot and execute complex maneuvers.

Keys:
"angle" absolute angle in which the monster should face
"targetname" entity name
"wait" time to wait between retriggers
*/
void() trigger_monsterface =
{
  if (SUB_Inhibit())
    return;

  trigger_monsterface_init();
  // InitTrigger();
}
