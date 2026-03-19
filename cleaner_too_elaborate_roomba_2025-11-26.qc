/*
==============================================================================

cleaner

==============================================================================
*/
$cd id1/models/cleaner
$origin 0 0 24
$base base
$skin skin

$frame attack1 attack2 attack3 attack4 attack5 attack6 attack7 attack8

$frame death1 death2 death3 death4 death5 death6 death7 death8 death9

$frame deathb1 deathb2 deathb3 deathb4 deathb5 deathb6 deathb7 deathb8
$frame deathb9

$frame pain1 pain2 pain3 pain4 pain5 pain6

$frame painb1 painb2 painb3 painb4 painb5 painb6 painb7 painb8 painb9 painb10
$frame painb11 painb12 painb13 painb14 painb15 painb16

$frame run1 run2 run3 run4 run5 run6 run7 run8 run9 run10 run11 run12

$frame leap1 leap2 leap3 leap4 leap5 leap6 leap7 leap8 leap9

$frame stand1 stand2 stand3 stand4 stand5 stand6 stand7 stand8 stand9

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8


void() cleaner_leap1;
void() cleaner_run1;

/*
================
cleaner_bite

================
*/
void() cleaner_bite =
{
	local vector delta, bop_dir;
	local float  bop_strength, z_strength;

	if (!self.enemy)
		return;

	ai_charge(10);

	if (!CanDamage(self.enemy, self))
		return;

	delta = self.enemy.origin - self.origin;

	if (vlen(delta) > 100)
		return;

	// Calculate normalized bop direction
	bop_dir = normalize(delta);

	// Bop strength: adjust this to control how hard the player is launched
	if (!self.speed)
		bop_strength = 300;
	else
		bop_strength = self.speed * 300;
	
	z_strength = bop_strength * 0.3;
	

	// Apply a "bop" by setting velocity on the enemy
	// Make sure enemy is a player or monster
	if (self.enemy.takedamage)
	{
		self.enemy.velocity = self.enemy.velocity + bop_dir * bop_strength;
		self.enemy.velocity_z = self.enemy.velocity_z + z_strength;
	}

	// Optional: play a sound or animation here
	// sound(self, CHAN_VOICE, "roomba_bop.wav", 1, ATTN_NORM);
};

void()	cleaner_JumpTouch =
{
	local	float	ldmg;
	local float  bop_strength, z_strength;
	local vector bop_dir, delta;

	if (self.health <= 0)
		return;

	if (other.takedamage)
	{
		if ( vlen(self.velocity) > 300 )
		{
			if !(self.worldtype)
	      {
					//ldmg = 10 + 10*random();
					//T_Damage (other, self, self, ldmg);
					// Calculate normalized bop direction
					delta = other.origin - self.origin;
					delta_z = 0;
					bop_dir = normalize(delta);
					// Bop strength: adjust this to control how hard the player is launched
					if (!self.speed)
						bop_strength = 300;
					else
						bop_strength = self.speed * 300;
					
					z_strength = bop_strength * 0.3;
										
					other.velocity = other.velocity + bop_dir * bop_strength;
					other.velocity_z = other.velocity_z + z_strength;
					
					if (other.health > 0) // is the player still alive? Preach's instakill bug check - dumptruck_ds
					self.worldtype = 1;
				}
		}
	}

	if (!checkbottom(self))
	{
		if (self.flags & FL_ONGROUND)
		{	// jump randomly to not get hung up
//dprint ("popjump\n");
// 1998-09-16 Sliding/not-jumping on monsters/boxes/players fix by Maddes/Kryten  start
//			self.touch = SUB_Null;
	self.touch = monster_touch;
// 1998-09-16 Sliding/not-jumping on monsters/boxes/players fix by Maddes/Kryten  end
	self.think = cleaner_leap1;
	self.nextthink = time + 0.1;

//			self.velocity_x = (random() - 0.5) * 600;
//			self.velocity_y = (random() - 0.5) * 600;
//			self.velocity_z = 200;
//			self.flags = self.flags - FL_ONGROUND;
		}
		return;	// not on ground yet
	}

	// 1998-09-16 Sliding/not-jumping on monsters/boxes/players fix by Maddes/Kryten  start
	//	self.touch = SUB_Null;
	self.touch = monster_touch;
	// 1998-09-16 Sliding/not-jumping on monsters/boxes/players fix by Maddes/Kryten  end
	self.think = cleaner_run1;
	self.nextthink = time + 0.1;
};


void() cleaner_stand1	=[	$stand1,	cleaner_stand2	] {ai_stand();};
void() cleaner_stand2	=[	$stand2,	cleaner_stand3	] {ai_stand();};
void() cleaner_stand3	=[	$stand3,	cleaner_stand4	] {ai_stand();};
void() cleaner_stand4	=[	$stand4,	cleaner_stand5	] {ai_stand();};
void() cleaner_stand5	=[	$stand5,	cleaner_stand6	] {ai_stand();};
void() cleaner_stand6	=[	$stand6,	cleaner_stand7	] {ai_stand();};
void() cleaner_stand7	=[	$stand7,	cleaner_stand8	] {ai_stand();};
void() cleaner_stand8	=[	$stand8,	cleaner_stand9	] {ai_stand();};
void() cleaner_stand9	=[	$stand9,	cleaner_stand1	] {ai_stand();};

void() cleaner_walk1	=[	$walk1 ,	cleaner_walk2	] {
if (random() < 0.2)
	sound_idle (self, CHAN_VOICE, "cleaner/idle.wav", 1, ATTN_IDLE); //dumptruck_ds
ai_walk(8);};
void() cleaner_walk2	=[	$walk2 ,	cleaner_walk3	] {ai_walk(8);};
void() cleaner_walk3	=[	$walk3 ,	cleaner_walk4	] {ai_walk(8);};
void() cleaner_walk4	=[	$walk4 ,	cleaner_walk5	] {ai_walk(8);};
void() cleaner_walk5	=[	$walk5 ,	cleaner_walk6	] {ai_walk(8);};
void() cleaner_walk6	=[	$walk6 ,	cleaner_walk7	] {ai_walk(8);};
void() cleaner_walk7	=[	$walk7 ,	cleaner_walk8	] {ai_walk(8);};
void() cleaner_walk8	=[	$walk8 ,	cleaner_walk1	] {ai_walk(8);};

void() cleaner_run1		=[	$run1  ,	cleaner_run2	] {
if (random() < 0.2)
	sound_idle (self, CHAN_VOICE, "cleaner/idle.wav", 1, ATTN_IDLE); //dumptruck_ds
ai_run(16);};
void() cleaner_run2		=[	$run2  ,	cleaner_run3	] {ai_run(32);};
void() cleaner_run3		=[	$run3  ,	cleaner_run4	] {ai_run(32);};
void() cleaner_run4		=[	$run4  ,	cleaner_run5	] {ai_run(20);};
void() cleaner_run5		=[	$run5  ,	cleaner_run6	] {ai_run(64);};
void() cleaner_run6		=[	$run6  ,	cleaner_run7	] {ai_run(32);};
void() cleaner_run7		=[	$run7  ,	cleaner_run8	] {ai_run(16);};
void() cleaner_run8		=[	$run8  ,	cleaner_run9	] {ai_run(32);};
void() cleaner_run9		=[	$run9  ,	cleaner_run10	] {ai_run(32);};
void() cleaner_run10	=[	$run10  ,	cleaner_run11	] {ai_run(20);};
void() cleaner_run11	=[	$run11  ,	cleaner_run12	] {ai_run(64);};
void() cleaner_run12	=[	$run12  ,	cleaner_run1	] {ai_run(32);};

void() cleaner_atta1	=[	$attack1,	cleaner_atta2	] {ai_charge(10);};
void() cleaner_atta2	=[	$attack2,	cleaner_atta3	] {ai_charge(10);};
void() cleaner_atta3	=[	$attack3,	cleaner_atta4	] {ai_charge(10);};
void() cleaner_atta4	=[	$attack4,	cleaner_atta5	] {
sound_attack (self, CHAN_VOICE, "cleaner/dattack1.wav", 1, ATTN_NORM); //dumptruck_ds
cleaner_bite();};
void() cleaner_atta5	=[	$attack5,	cleaner_atta6	] {ai_charge(10);};
void() cleaner_atta6	=[	$attack6,	cleaner_atta7	] {ai_charge(10);};
void() cleaner_atta7	=[	$attack7,	cleaner_atta8	] {ai_charge(10);};
void() cleaner_atta8	=[	$attack8,	cleaner_run1	] {ai_charge(10);};

void() cleaner_leap1	=[	$leap1,		cleaner_leap2	] {ai_face();};
void() cleaner_leap2	=[	$leap2,		cleaner_leap3	]
{
	ai_face();
	self.worldtype = 0; //fix for instakill bug -- dumptruck_ds
	self.touch = cleaner_JumpTouch;
	makevectors (self.angles);
	self.origin_z = self.origin_z + 1;
	self.velocity = v_forward * 300 + '0 0 200';
	if (self.flags & FL_ONGROUND)
		self.flags = self.flags - FL_ONGROUND;
};

void() cleaner_leap3	=[	$leap3,		cleaner_leap4	] {};
void() cleaner_leap4	=[	$leap4,		cleaner_leap5	] {};
void() cleaner_leap5	=[	$leap5,		cleaner_leap6	] {};
void() cleaner_leap6	=[	$leap6,		cleaner_leap7	] {};
void() cleaner_leap7	=[	$leap7,		cleaner_leap8	] {};
void() cleaner_leap8	=[	$leap8,		cleaner_leap9	] {};
void() cleaner_leap9	=[	$leap9,		cleaner_leap9	] {};

void() cleaner_pain1	=[	$pain1 ,	cleaner_pain2	] {};
void() cleaner_pain2	=[	$pain2 ,	cleaner_pain3	] {};
void() cleaner_pain3	=[	$pain3 ,	cleaner_pain4	] {};
void() cleaner_pain4	=[	$pain4 ,	cleaner_pain5	] {};
void() cleaner_pain5	=[	$pain5 ,	cleaner_pain6	] {};
void() cleaner_pain6	=[	$pain6 ,	cleaner_run1	] {};

void() cleaner_painb1	=[	$painb1 ,	cleaner_painb2	] {};
void() cleaner_painb2	=[	$painb2 ,	cleaner_painb3	] {};
void() cleaner_painb3	=[	$painb3 ,	cleaner_painb4	] {ai_pain(4);};
void() cleaner_painb4	=[	$painb4 ,	cleaner_painb5	] {ai_pain(12);};
void() cleaner_painb5	=[	$painb5 ,	cleaner_painb6	] {ai_pain(12);};
void() cleaner_painb6	=[	$painb6 ,	cleaner_painb7	] {ai_pain(2);};
void() cleaner_painb7	=[	$painb7 ,	cleaner_painb8	] {};
void() cleaner_painb8	=[	$painb8 ,	cleaner_painb9	] {ai_pain(4);};
void() cleaner_painb9	=[	$painb9 ,	cleaner_painb10	] {};
void() cleaner_painb10	=[	$painb10 ,	cleaner_painb11	] {ai_pain(10);};
void() cleaner_painb11	=[	$painb11 ,	cleaner_painb12	] {};
void() cleaner_painb12	=[	$painb12 ,	cleaner_painb13	] {};
void() cleaner_painb13	=[	$painb13 ,	cleaner_painb14	] {};
void() cleaner_painb14	=[	$painb14 ,	cleaner_painb15	] {};
void() cleaner_painb15	=[	$painb15 ,	cleaner_painb16	] {};
void() cleaner_painb16	=[	$painb16 ,	cleaner_run1	] {};

void(entity attacker, float damage) cleaner_pain =
{
	sound_pain (self, CHAN_VOICE, "cleaner/dpain1.wav", 1, ATTN_NORM); //dumptruck_ds

	if (random() > 0.5)
		cleaner_pain1 ();
	else
		cleaner_painb1 ();
};

void() cleaner_die1		=[	$death1,	cleaner_die2	] {};
void() cleaner_die2		=[	$death2,	cleaner_die3	] {};
void() cleaner_die3		=[	$death3,	cleaner_die4	] {};
void() cleaner_die4		=[	$death4,	cleaner_die5	] {};
void() cleaner_die5		=[	$death5,	cleaner_die6	] {};
void() cleaner_die6		=[	$death6,	cleaner_die7	] {};
void() cleaner_die7		=[	$death7,	cleaner_die8	] {};
void() cleaner_die8		=[	$death8,	cleaner_die9	] {};
void() cleaner_die9		=[	$death9,	cleaner_die9	] {};

void() cleaner_dieb1		=[	$deathb1,	cleaner_dieb2	] {};
void() cleaner_dieb2		=[	$deathb2,	cleaner_dieb3	] {};
void() cleaner_dieb3		=[	$deathb3,	cleaner_dieb4	] {};
void() cleaner_dieb4		=[	$deathb4,	cleaner_dieb5	] {};
void() cleaner_dieb5		=[	$deathb5,	cleaner_dieb6	] {};
void() cleaner_dieb6		=[	$deathb6,	cleaner_dieb7	] {};
void() cleaner_dieb7		=[	$deathb7,	cleaner_dieb8	] {};
void() cleaner_dieb8		=[	$deathb8,	cleaner_dieb9	] {};
void() cleaner_dieb9		=[	$deathb9,	cleaner_dieb9	] {};


void() cleaner_die =
{
// check for gib
	if (self.health < -35)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);

		if (self.mdl_gib1 != "") // custom models -- dumptruck_ds
		{
			ThrowGib (self.mdl_gib1, self.health);
		}
		else
		{
			ThrowGib ("progs/gib3.mdl", self.health);
		}
		if (self.mdl_gib2 != "")
		{
			ThrowGib (self.mdl_gib2, self.health);
		}
		else
		{
			ThrowGib ("progs/gib3.mdl", self.health);
		}
		if (self.mdl_gib3 != "")
		{
			ThrowGib (self.mdl_gib3, self.health);
		}
		else
		{
			ThrowGib ("progs/gib3.mdl", self.health);
		}
		if (self.mdl_head != "")
		{
			ThrowHead (self.mdl_head, self.health);
		}
		else
		{
			ThrowHead ("progs/h_cleaner.mdl", self.health);
		}
		DropStuff();
 		return;
	}

// regular death
	sound_death (self, CHAN_VOICE, "cleaner/ddeath.wav", 1, ATTN_NORM); //dumptruck_ds
	self.solid = SOLID_NOT;

	DropStuff();

	if (random() > 0.5)
		cleaner_die1 ();
	else
		cleaner_dieb1 ();
};

//============================================================================

/*
====================================================
  ROOMBA AI — Wall Hugging + Breadcrumb Mapping
====================================================
*/




/*  
----------------------------------------
  Breadcrumb nodes (mapping memory)
----------------------------------------
*/

vector reflect(vector v, vector n)
{
    // reflect v across normal n
    return v - n * (2 * (v * n));
}

void() crumb_think = 
{
	// invisible node
	setmodel(self, "progs/s_bubble.spr");
	setsize(self, '-1 -1 -1', '1 1 1');
	self.movetype = MOVETYPE_NONE;
	self.solid = SOLID_TRIGGER;
	// expire after some time
	self.nextthink = time + 30;
	self.think = SUB_Remove;
}


void() cleaner_drop_node =
{
    local entity c;
    c = spawn();

    c.classname = "roomba_crumb";
    c.owner = self;  // only belongs to this bot
    c.origin = self.origin;
    // appear after some time
    c.nextthink = time + 6;
    c.think = crumb_think;
};


/*
----------------------------------------
  Detect if roomba is revisiting an area
----------------------------------------
*/

float() cleaner_at_old_place =
{
	local vector raw_dir, flipped_dir;
	local float yaw;
    local entity c;
    c = findradius(self.origin, 80);

    while (c)
    {
    	dprint(c.classname);
    	dprint("\n");
        if (c.classname == "roomba_crumb") {
        	raw_dir = normalize(c.origin-self.origin);
        	flipped_dir = reflect(raw_dir, v_forward);
        	yaw = vectoyaw(flipped_dir);
        	return yaw;
	}
            

        c = c.chain;
    }

    return FALSE;
};


/*
----------------------------------------
  Side wall detection (for wall hugging)
----------------------------------------
*/

float cleaner_wall_detect_right()
{
    traceline(self.origin,
              self.origin + v_right * 44,
              FALSE, self);

    if (trace_fraction < 1)
        return TRUE;

    return FALSE;
}

float cleaner_wall_detect_left()
{
    traceline(self.origin,
              self.origin - v_right * 44,
              FALSE, self);

    if (trace_fraction < 1)
        return TRUE;

    return FALSE;
}


/*
----------------------------------------
  Turning logic (smooth turning)
----------------------------------------
*/

void() cleaner_turn =
{
    ChangeYaw();  // rotates toward ideal_yaw

    // Check if close enough to final angle
    float dy;
    dy = anglemod(self.ideal_yaw - self.angles_y);

    if (dy < 2 || dy > 358)
    {
        self.angles_y = self.ideal_yaw;
        self.think = cleaner_think;
    }

    self.nextthink = time + 0.05;
};


/*
----------------------------------------
  Start turning helper
----------------------------------------
*/

void(float newyaw) cleaner_start_turn =
{
    self.ideal_yaw = anglemod(newyaw);
    self.yaw_speed = 10;  // turning rate
    self.think = cleaner_turn;
    self.nextthink = time + 0.05;
};


/*
----------------------------------------
  Wall Hugging
----------------------------------------
*/

void() cleaner_wall_hug =
{
    makevectors(self.angles);

    // 1. Forward clear? Move ahead.
    if (walkmove(self.angles_y, 5))
    {
        // But if no wall on right, steer gently right
        if (!cleaner_wall_detect_right())
        {
            cleaner_start_turn(self.angles_y - 5);
        }
        return;
    }

    // 2. If blocked ahead, turn left sharply
    cleaner_start_turn(self.angles_y + 45);
};


/*
----------------------------------------
  Main Roomba Think
----------------------------------------
*/

void() cleaner_think =
{
	local float crumbyaw;
    if (!self.roomba_mode)
        return;

    /* ---- Drop breadcrumbs ---- */
    self.crumb_time += 0.1;

    if (self.crumb_time >= 1)
    {
        cleaner_drop_node();
        self.crumb_time = 0;
    }

    makevectors(self.angles);

    /* ---- Wall Hugging Priority ---- */

    if (cleaner_wall_detect_right() || cleaner_wall_detect_left())
    {
        cleaner_wall_hug();
        self.nextthink = time + 0.1;
        return;
    }

    /* ---- Open space behavior ---- */
	self.checkcrumbtime += 0.1;
	if (self.checkcrumbtime >= 5) {
		crumbyaw = cleaner_at_old_place();
		if (crumbyaw)
		{
			dprint("cleaner at old place\n");
			// turn away to avoid loop
			cleaner_start_turn(crumbyaw);
			self.nextthink = time + 0.1;
			self.checkcrumbtime = 0;
			return;
		}
	}

    // Try forward motion
    if (walkmove(self.angles_y, 5))
    {
        // good, continue straight
        self.nextthink = time + 0.1;
        return;
    }

    // If blocked unexpectedly, start wall hugging
    cleaner_start_turn(self.angles_y + random()*90 + 45);
    self.nextthink = time + 0.1;
};





/*
==============
CheckcleanerMelee

Returns TRUE if a melee attack would hit right now
==============
*/
float()	CheckcleanerMelee =
{
	if (enemy_range == RANGE_MELEE)
	{	// FIXME: check canreach
		self.attack_state = AS_MELEE;
		return TRUE;
	}
	return FALSE;
};

/*
==============
CheckcleanerJump

==============
*/
float()	CheckcleanerJump =
{
	local	vector	dist;
	local	float	d;

	if (self.origin_z + self.mins_z > self.enemy.origin_z + self.enemy.mins_z
	+ 0.75 * self.enemy.size_z)
		return FALSE;

	if (self.origin_z + self.maxs_z < self.enemy.origin_z + self.enemy.mins_z
	+ 0.25 * self.enemy.size_z)
		return FALSE;

	dist = self.enemy.origin - self.origin;
	dist_z = 0;

	d = vlen(dist);

	if (d < 80)
		return FALSE;

	if (d > 150)
		return FALSE;

	return TRUE;
};

float()	cleanerCheckAttack =
{

// if close enough for slashing, go for it
	if (CheckcleanerMelee ())
	{
		self.attack_state = AS_MELEE;
		return TRUE;
	}

	if (CheckcleanerJump ())
	{
		self.attack_state = AS_MISSILE;
		return TRUE;
	}

	return FALSE;
};


//===========================================================================

/*QUAKED monster_cleaner (1 0 0) (-32 -32 -24) (32 32 40) AMBUSH X X TRIGGER_SPAWNED X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
{
	model ("progs/cleaner.mdl");
}
Rottweiler.

Default health = 25

snd_death(string) : "Path to custom death sound"
snd_pain(string) : "Path to custom pain sound"
snd_sight(string) : "Path to custom sight sound"
snd_attack(string) : "Path to custom attack sound"
snd_idle(string) : "Path to custom idle sound"

mdl_head(string) : "Path to custom head model"
mdl_body(string) : "Path to custom body model"
skin_head(float) : "Skin index of custom head model"
mdl_gib1(string) : "Path to custom 1st gib model"
mdl_gib2(string) : "Path to custom 2nd gib model"
mdl_gib3(string) : "Path to custom 3rd gib model"

effects(choices) : "Add a visual effect to an entity"
0 : "None (Default)"
1 : "Brightfield (yellow particles)"
4 : "Bright light"
8 : "Dim light"

berserk(choices) "Skips certain pain animations similar to skill 3 (Makes a semi-nightmare monster!)"
0 : "Off (Default)"
1 : "Berserk (skip pain animations)"

delay(float) : "Delay spawn in for this amount of time"

wait(choices) : "Play an effect when trigger spawned?"
0 : "Teleport Effects (Default)"
1 : "Spawn Silently"

spawn_angry(Choices)
0 : "Only when trigger spawned, default behavior - not angry"
1 : "Only when trigger spawned, set to 1 to spawn angry at player"

infight_mode(Choices)
0 : "Default behavior, only with different classnames"
1 : "Infight with monsters with the same classname but a different mdl_body"
2 : "Infight with monsters with the same classname and model but a different skin"
3 : "Infight no matter what"

health(integer) : "Set this to a custom health amount"
pain_target(string) : "Fire this target when pain_threshold is reached"
pain_threshold(integer) : "Fire pain_target when health drops below this amount"
sight_trigger(integer) : "1 = Fire target upon seeing the player instead of death"
skin(integer) : "Skin index (default 0) Use this when your custom model has more than one skin to select"
obit_name(string) : "When used with obit_method, this will set part of the text for a custom obituary. e.g. a Super Soldier! Using the examples here, the obituary would read: Player was eviscerated by a Super Solider!"
obit_method(string) : "When used with obit_name, will set part of the text for a custom obituary. e.g. eviscerated - If empty, defaults to killed."
damage_mod(float) : "USE WITH CAUTION! Multiply all damage from this monster by this number (e.g. 4 = Quad damage)"

*/
void() monster_cleaner =
{
	if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
		return;

	if (self.spawnflags & I_AM_TURRET)
		objerror("Incompatible spawnflag: TURRET_MODE\n");

	if (deathmatch)
	{
		remove(self);
		return;
	}
	//dumptruck_ds --  model_custom and sounds changes
	//precache_head_model ("progs/h_cleaner.mdl");
	precache_body_model ("progs/cleaner.mdl");
	//precache_sound_attack ("cleaner/cattack1.wav");
	//precache_sound_death ("cleaner/cdeath.wav");
	//precache_sound_pain ("cleaner/cpain1.wav");
	//precache_sound_sight ("cleaner/csight.wav");
	//precache_sound_idle ("cleaner/idle.wav");

	precache_gib1 ("progs/gib1.mdl");
	precache_gib2 ("progs/gib2.mdl");
	precache_gib3 ("progs/gib3.mdl");

	// dumptruck_ds

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	body_model ("progs/cleaner.mdl"); //dumptruck_ds
	// setmodel (self, "progs/cleaner.mdl");

	setsize (self, '-40 -40 -12', '40 40 12');

	if (!self.health) //thanks RennyC -- dumptruck_ds
	self.health = 200;

	
	self.th_stand = cleaner_stand1;
	self.th_walk = cleaner_walk1;
	self.th_run = cleaner_run1;
	if !(self.berserk) //Berserk test from http://celephais.net/board/view_thread.php?id=4&start=3465 -- dumptruck_ds
		self.th_pain = cleaner_pain;
	else
		self.th_pain = SUB_NullPain;
	self.th_die = cleaner_die;
	self.th_melee = cleaner_atta1;
	self.th_missile = cleaner_leap1;

	walkmonster_start();
	
	if (self.count == TRUE) {
		// Init state
		self.roomba_mode = TRUE;
		self.think = cleaner_think;
		self.nextthink = time + 0.2;
	}
};

/* Scenic Dead Monster Patch stuff here from DeadStuff mod -- dumptruck_ds */

/*QUAKED monster_dead_cleaner (0 0.5 0.8) (-32 -32 -24) (32 32 64) SOLID X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
{
	model ({"path":"progs/cleaner.mdl","frame":16});
}
*/
void() monster_dead_cleaner =
{
	if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
		return;

	precache_model("progs/cleaner.mdl");
	setmodel(self, "progs/cleaner.mdl");
	self.frame = $death8;
        if (self.spawnflags & 1)
	{
		self.solid = SOLID_BBOX;
                setsize(self,'-24.51 -16.5 -50.37','28.2 13.81 30');
	}
	else
	{
		self.solid = SOLID_NOT;
	}
};
