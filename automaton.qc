/*
==============================================================================

AUTOMATON

==============================================================================
*/


$origin 0 0 0
$skin skin


$frame stand1

$frame walk1 walk2 walk3 walk4 walk5 walk6 walk7 walk8 walk9
$frame walk10 walk11 walk12 walk13 walk14 walk15 walk16 walk17

$frame run1 run2 run3 run4 run5 run6 run7 run8 run9 run10 run11

$frame hit1 hit2 hit3 hit4 hit5 hit6 hit7 hit8 hit9 hit10 hit11 hit12 hit13

$frame shoot1 shoot2 shoot3 shoot4 shoot5 shoot6 shoot7 shoot8 shoot9 shoot10 shoot11 shoot12

$frame die1 die2 die3 die4 die5 die6 die7






void() aut_Fire =
{
	vector		vec;
	vector		dst;

	if (self.owner.health > 0)
	{
		self.owner.effects = self.owner.effects | EF_MUZZLEFLASH;

		makevectors (self.enemy.angles);	
		dst = self.enemy.origin - 13*self.movedir;
	
		vec = normalize(dst - self.origin);
		

		launch_spike (self.origin, vec);
		newmis.velocity = vec*1300;
		newmis.owner = self.owner;
		//newmis.classname = "wizspike";
		newmis.touch = HorizonTouch;
		setmodel (newmis, "progs/horiz_proj.mdl");
		setsize (newmis, VEC_ORIGIN, VEC_ORIGIN);
		newmis.effects = EF_DIMLIGHT;
		newmis.avelocity = '100 100 700';		
	}

	remove (self);
};


void() aut_shoot = 
{
	entity	missile;
	
	self.v_angle = self.angles;
	makevectors (self.angles);

	missile = spawn ();
	missile.owner = self;
	missile.nextthink = time + 0.8;
	setsize (missile, '0 0 0', '0 0 0');		
	setorigin (missile, self.origin + '0 0 30' + v_forward*14 + v_right*14);
	missile.enemy = self.enemy;
	missile.nextthink = time + 0.6;
	missile.think = aut_Fire;
	missile.movedir = v_right;

};


//=============================================================================

void()	aut_stand1	=[	$stand1,	aut_stand1	] {ai_stand();};

//=============================================================================


void()	walk1	=[	$walk1,		walk2	] {ai_walk(5);};
void()	walk2	=[	$walk2,		walk3	] {ai_walk(5);};
void()	walk3	=[	$walk3,		walk4	] {ai_walk(5);};
void()	walk4	=[	$walk4,		walk5	] {ai_walk(5);};
void()	walk5	=[	$walk5,		walk6	] {ai_walk(5);};
void()	walk6	=[	$walk6,		walk7	] {ai_walk(5);};
void()	walk7	=[	$walk7,		walk8	] {ai_walk(5);};
void()	walk8	=[	$walk8,		walk9	] {ai_walk(5);};
void()	walk9	=[	$walk9,		walk10	] {ai_walk(5);};
void()	walk10	=[	$walk10,	walk11	] {ai_walk(5);};
void()	walk11	=[	$walk11,	walk12	] {ai_walk(5);};
void()	walk12	=[	$walk12,	walk13	] {ai_walk(5);};
void()	walk13	=[	$walk13,	walk14	] {ai_walk(5);};
void()	walk14	=[	$walk14,	walk15	] {ai_walk(5);};
void()	walk15	=[	$walk15,	walk16	] {ai_walk(5);};
void()	walk16	=[	$walk16,	walk17	] {ai_walk(5);};
void()	walk17	=[	$walk17,	walk1	] {ai_walk(5);};


//=============================================================================

void()	run1	=[	$run1,		run2	] {ai_run (5);};
void()	run2	=[	$run2,		run3	] {ai_run(38);};
void()	run3	=[	$run3,		run4	] {ai_run(38);};
void()	run4	=[	$run4,		run5	] {ai_run(38);};
void()	run5	=[	$run5,		run6	] {ai_run(5);};
void()	run6	=[	$run6,		run7	] {ai_run(5);};
void()	run7	=[	$run7,		run8	] {ai_run(38);};
void()	run8	=[	$run8,		run9 ] {ai_run(38);};
void()	run9	=[	$run9,		run10] {ai_run(38);};
void()	run10   =[	$run10,		run1] {ai_run(5);};

//=============================================================================

void()  aut_atk1        =[      $shoot1,    aut_atk2       ] {ai_face();};
void()  aut_atk2        =[      $shoot2,    aut_atk3       ]    {ai_face(); 
								sound_attack (self, CHAN_WEAPON, "dump/lguncharge.wav", 1, ATTN_NORM);
								particle (self.origin+'0 0 32', '0 0 5', 111, 20);
							};
void()  aut_atk3        =[      $shoot3,    aut_atk4       ] {ai_face();particle (self.origin+'0 0 32', '0 0 5', 144, 20);};
void()  aut_atk4        =[      $shoot4,    aut_atk5       ] {ai_face();particle (self.origin+'0 0 32', '0 0 5', 196, 20);};
void()  aut_atk5        =[      $shoot5,    aut_atk6       ] {ai_face();particle (self.origin+'0 0 32', '0 0 5', 194, 20);};
void()  aut_atk6        =[      $shoot6,    aut_atk7       ] {ai_face();particle (self.origin+'0 0 32', '0 0 5', 192, 10);};
void()  aut_atk7        =[      $shoot7,    aut_atk8       ] {ai_face(); aut_shoot();};
void()  aut_atk8        =[      $shoot8,    aut_atk9       ] {ai_face();
								if (random() > 0.333)	
									SUB_CheckRefire (aut_atk1);};
void()  aut_atk9        =[      $shoot9,    aut_atk10       ] {ai_face();};
void()  aut_atk10        =[      $shoot10,    aut_atk11       ] {ai_face();};
void()  aut_atk11       =[      $shoot11,    aut_atk12       ] {ai_face(); sound (self, CHAN_WEAPON, "dump/horiz_snd.wav", 1, ATTN_NORM);};
void()  aut_atk12       =[      $shoot12,    run1	        ] {ai_face();};

//=============================================================================

void()  hitee1     =[      $hit1,     hitee2     ] {ai_charge(6); ai_melee();ai_melee();sound_attack (self, CHAN_WEAPON, "automaton/aut_windup.wav", 1, ATTN_NORM);};
void()  hitee2     =[      $hit2,     hitee3     ] {ai_charge(6);};
void()  hitee3     =[      $hit3,     hitee4     ] {ai_charge(6);};
void()  hitee4     =[      $hit4,     hitee5     ] {ai_charge(6);};
void()  hitee5     =[      $hit5,     hitee6     ] {ai_charge(6);};
void()  hitee6     =[      $hit6,     hitee7     ] {ai_charge(12); ai_melee();};
void()  hitee7     =[      $hit7,     hitee8     ] {ai_charge(12); ai_melee();};
void()  hitee8     =[      $hit8,     hitee9     ] {ai_charge(12); ai_melee();ai_melee();sound_attack (self, CHAN_WEAPON, "automaton/aut_punch.wav", 1, ATTN_NORM);};
void()  hitee9     =[      $hit9,     hitee10     ] {ai_charge(12); };
void()  hitee10    =[      $hit10,    hitee11     ] {ai_charge(6);};
void()  hitee11    =[      $hit11,    hitee12     ] {ai_charge(6);};
void()  hitee12    =[      $hit12,    hitee13     ] {ai_charge(6);};
void()  hitee13    =[      $hit13,    run1        ] {ai_charge(6);};

//=============================================================================

void()  aut_death1     =[      $die1,     aut_death2     ] {};
void()  aut_death2     =[      $die2,     aut_death3     ] {};
void()  aut_death3     =[      $die3,     aut_death4     ] {self.solid = SOLID_NOT;self.ammo_nails = 10;DropBackpack();};
void()  aut_death4     =[      $die4,     aut_death5     ] {};
void()  aut_death5     =[      $die5,     aut_death6     ] {};
void()  aut_death6     =[      $die6,     aut_death7     ] {};
void()  aut_death7     =[      $die7,     aut_death7     ] {};


//=============================================================================


void() aut_die =
{
// check for gib
	if (self.health < -25)
	{
		sound (self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
		ThrowHead ("progs/and_head.mdl", self.health);
		ThrowGib ("progs/gib1.mdl", self.health);
		ThrowGib ("progs/gib2.mdl", self.health);
		ThrowGib ("progs/gib3.mdl", self.health);
		return;
	}

// regular death
	//sound (self, CHAN_VOICE, "soldier/death1.wav", 1, ATTN_NORM);
	aut_death1 ();
};



void() monster_automaton =
{
	if (deathmatch)
	{
		remove(self);
		return;
	}
	
	precache_model ("progs/automaton.mdl");
	precache_model ("progs/horiz_proj.mdl");
	precache_sound ("dump/lguncharge.wav");
	precache_sound ("automaton/aut_windup.wav");
	precache_sound ("automaton/aut_punch.wav");
	precache_model ("progs/and_head.mdl");
	precache_gib1 ("progs/gib1.mdl");
	precache_gib2 ("progs/gib2.mdl");
	precache_gib3 ("progs/gib3.mdl");
	precache_sound_sight ("automaton/aut_sight.wav");

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	setmodel (self, "progs/automaton.mdl");

	setsize (self, '-16 -16 -24', '16 16 40');
	self.health = 130;

	self.th_stand = aut_stand1;
	self.th_walk = walk1;
	self.th_run = run1;
	
	self.th_missile = aut_atk1;
	self.th_melee = hitee1;
	
	//self.th_pain = army_pain;
	self.th_die = aut_die;

	
	walkmonster_start ();
};