/*
===============================================================================
trigger_trampoline
===============================================================================
*/

/*QUAKED trigger_trampoline (.5 .5 .5) ? X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Invisible trampoline entity. Reflects the player's velocity when touched.

Keys:

"elasticity" How much velocity is boosted after a bounce (ignoring gravity); default of 1 is perfectly elastic, values less than 1 will result in lower bounces, and values higher than 1 will provide 
a higher boost that is not physically possible. Small changes in elasticity greatly affect velocity; values between 0.9 and 1.1 are recommended, and the default of 1 should be used in almost all cases

"maxbounce" The maximum vertical velocity that a player can achieve using the trampoline. Use of this is highly recommended if elasticity > 1, as otherwise the player will continue to gain upwards 
speed indefinitely. Default of 0 means no limit.

"punchangle" Defines a custom bounce angle. If unset, entities bounce in the direction of the face they hit.

*/

//float TRACE_TO_SURFACE = 1; // deprecated
float BOUNCE_ON_TOUCH = 2;
float BOUNCE_NO_BOUNDS_CHECK = 4;

// for monsters
float NO_BOUNCING = 4194304;

void() bouncecontroller_think = {

	if (self != self.owner.bouncecontroller) { // lost link
		remove(self);
		return;
	}

	entity bouncee = self.owner;
	entity trp = self.enemy;
	entity oself;
	float ostate, fired;
	
	dprint6(bouncee.classname, " (", ftos(framecount), "): Bounce think, jump flag: ", ftos(bouncee.jump_flag), "\n");

	if (bouncee.button2 || bouncee.flags & FL_MONSTER || (bouncee.movetype == MOVETYPE_BOUNCE && bouncee.solid == SOLID_BBOX)) {
		
		if (bouncee.spawnflags & NO_BOUNCING)
		{
			return;
		}
		
		bouncee.flags &~= FL_ONGROUND;
		dprint6(bouncee.classname, " (", ftos(framecount), "): Bounced. Velocity ", vtos(self.movedir), "\n");
		bouncee.velocity = self.movedir;

		if (trp.noise != "") sound(trp, CHAN_AUTO, trp.noise, 1, ATTN_NORM);
		else if (trp.sounds == 1) sound(trp, CHAN_AUTO, "misc/bounce2.wav", 1, ATTN_NORM);
		else if (trp.sounds == 2) sound(trp, CHAN_AUTO, "misc/bounce3.wav", 1, ATTN_NORM);
		else if (trp.sounds == 3) sound(trp, CHAN_AUTO, "misc/bounce4.wav", 1, ATTN_NORM);
		else if (trp.sounds == 4) sound(trp, CHAN_AUTO, "misc/bounce5.wav", 1, ATTN_NORM);
		else if (trp.sounds == 5) sound(trp, CHAN_AUTO, "misc/bounce6.wav", 1, ATTN_NORM);
		else sound (trp, CHAN_AUTO, "misc/bounce1.wav", 1, ATTN_NORM);
					
		bouncee.maxbounce++;

		fired = STATE_RM_BOUNCING;
	}
	// this will always fire through the PlayerPostThink call
	else if (bouncee.flags & FL_CLIENT && (bouncee.flags & FL_ONGROUND) && (bouncee.health > 0)) {
		dprint4(bouncee.classname, " (", ftos(framecount), "): Cushioned\n");
		if (trp.noise2 != "") sound(bouncee, CHAN_AUTO, trp.noise2, 1, ATTN_NORM);
		else if (trp.sounds == 1) sound(bouncee, CHAN_AUTO, "misc/cushion2.wav", 1, ATTN_NORM);
		else if (trp.sounds == 2) sound(bouncee, CHAN_AUTO, "misc/cushion3.wav", 1, ATTN_NORM);
		else if (trp.sounds == 3) sound(bouncee, CHAN_AUTO, "misc/cushion4.wav", 1, ATTN_NORM);
		else if (trp.sounds == 4) sound(bouncee, CHAN_AUTO, "misc/cushion5.wav", 1, ATTN_NORM);
		else if (trp.sounds == 5) sound(bouncee, CHAN_AUTO, "misc/cushion6.wav", 1, ATTN_NORM);
		else sound(bouncee, CHAN_AUTO, "misc/cushion1.wav", 1, ATTN_NORM);

		fired = STATE_RM_CUSHIONED;
	}

	if (fired) {
		//Fire trampoline targets if bounced or cushioned
		ostate = bouncee.state;
		bouncee.state = ostate | fired;
		
		activator = bouncee;
		oself = self;
		self = trp;
		SUB_UseTargets();
		self = oself;

		bouncee.state = ostate;
		self.movedir = '0 0 0';
	}
	self.nextthink = 0;
}

void() trampoline_touch = {
		
	// from Copper -- dumptruck_ds
	if (!(CheckValidTouch() || (other.flags & FL_MONSTER || (other.movetype == MOVETYPE_BOUNCE && other.solid == SOLID_BBOX)) ))
		return;
	
	vector up;
	vector normal;
	vector touchpoint;
	vector traceorigin;
	float fraction, disttoplane, bouncehit;

	/*
	Does a lot of traces downwards to see where the entity will land.
	The "touch point" to be considered is the one closest to the bottom of the entity.
	From that, we basically take the distance to the bounce, and the surface normal
	for the entity be pushed towards.

	This is also used for the bounds check. If one of the traces hit a point
	outside of the trigger's area it gets marked as "not hit"
	*/

	traceline(other.origin + [0, 0, other.mins_z] , other.origin + [0, 0, other.mins_z] - '0 0 512', FALSE, other);
	//dprint7("Trace 1: ", vtos(trace_endpos), ", absmin: ", vtos(self.absmin), ", absmax: ", vtos(self.absmax), "\n");
	if (checkbounds(trace_endpos + '0 0 8', self.absmin + '1 1 1', self.absmax - '1 1 1')) {
		//dprint("Trace 1 out of bounds.\n");
		bouncehit = TRUE;
	}

	traceorigin	= other.origin + [0, 0, other.mins_z];
	fraction = trace_fraction;
	normal = trace_plane_normal;
	touchpoint = trace_endpos;

	traceline(other.origin + [other.mins_x, other.mins_y, other.mins_z] , other.origin + [other.mins_x, other.mins_y, other.mins_z] - '0 0 512', FALSE, other);
	//dprint7("Trace 2: ", vtos(trace_endpos), ", absmin: ", vtos(self.absmin), ", absmax: ", vtos(self.absmax), "\n");
	if (trace_fraction <= fraction) {
		//dprint("Trace 2 shorter. Replacing\n");
		if (checkbounds(trace_endpos + '0 0 8', self.absmin + '1 1 1', self.absmax - '1 1 1')) {
			//dprint("Trace 2 out of bounds.\n");
			bouncehit = TRUE;
		}
	
		traceorigin	= other.origin + [other.mins_x, other.mins_y, other.mins_z];
		fraction = trace_fraction;
		normal = trace_plane_normal;
		touchpoint = trace_endpos;
	}

	traceline(other.origin + [other.maxs_x, other.mins_y, other.mins_z] , other.origin + [other.maxs_x, other.mins_y, other.mins_z] - '0 0 512', FALSE, other);
	//dprint7("Trace 3: ", vtos(trace_endpos), ", absmin: ", vtos(self.absmin), ", absmax: ", vtos(self.absmax), "\n");
	if (trace_fraction <= fraction) {
		//dprint("Trace 3 shorter. Replacing\n");
		if (checkbounds(trace_endpos + '0 0 8', self.absmin + '1 1 1', self.absmax - '1 1 1')){
			//dprint("Trace 3 out of bounds.\n");
			bouncehit = TRUE;
		}
	
		traceorigin = other.origin + [other.maxs_x, other.mins_y, other.mins_z];
		fraction = trace_fraction;
		normal = trace_plane_normal;
		touchpoint = trace_endpos;
	}

	traceline(other.origin + [other.mins_x, other.maxs_y, other.mins_z] , other.origin + [other.mins_x, other.maxs_y, other.mins_z] - '0 0 512', FALSE, other);
	//dprint7("Trace 4: ", vtos(trace_endpos), ", absmin: ", vtos(self.absmin), ", absmax: ", vtos(self.absmax), "\n");
	if (trace_fraction <= fraction) {
		//dprint("Trace 4 shorter. Replacing\n");
		if (checkbounds(trace_endpos + '0 0 8', self.absmin + '1 1 1', self.absmax - '1 1 1')) {
			//dprint("Trace 4 out of bounds.\n");
			bouncehit = TRUE;
		}
	
		traceorigin = other.origin + [other.mins_x, other.maxs_y, other.mins_z];
		fraction = trace_fraction;
		normal = trace_plane_normal;
		touchpoint = trace_endpos;
	}

	traceline(other.origin + [other.maxs_x, other.maxs_y, other.mins_z] , other.origin + [other.maxs_x, other.maxs_y, other.mins_z] - '0 0 512', FALSE, other);
	//dprint7("Trace 5: ", vtos(trace_endpos), ", absmin: ", vtos(self.absmin), ", absmax: ", vtos(self.absmax), "\n");
	if (trace_fraction <= fraction) {
		//dprint("Trace 5 shorter. Replacing\n");
		if (checkbounds(trace_endpos + '0 0 8', self.absmin + '1 1 1', self.absmax - '1 1 1')){
			//dprint("Trace 5 out of bounds.\n");
			bouncehit = TRUE;
		}
	
		traceorigin = other.origin + [other.maxs_x, other.maxs_y, other.mins_z];
		fraction = trace_fraction;
		normal = trace_plane_normal;
		touchpoint = trace_endpos;
	}

	traceline(other.origin + [other.maxs_x*0.75, other.maxs_y*0.75, other.mins_z] , other.origin + [other.maxs_x*0.75, other.maxs_y*0.75, other.mins_z] - '0 0 512', FALSE, other);
	//dprint7("Trace 6: ", vtos(trace_endpos), ", absmin: ", vtos(self.absmin), ", absmax: ", vtos(self.absmax), "\n");
	if (trace_fraction <= fraction) {
		//dprint("Trace 6 shorter. Replacing\n");
		if (checkbounds(trace_endpos + '0 0 8', self.absmin + '1 1 1', self.absmax - '1 1 1')){
			//dprint("Trace 6 out of bounds.\n");
			bouncehit = TRUE;
		}
	
		traceorigin = other.origin + [other.maxs_x*0.75, other.maxs_y*0.75, other.mins_z];
		fraction = trace_fraction;
		normal = trace_plane_normal;
		touchpoint = trace_endpos;
	}

	traceline(other.origin + [other.mins_x*0.75, other.mins_y*0.75, other.mins_z] , other.origin + [other.mins_x*0.75, other.mins_y*0.75, other.mins_z] - '0 0 512', FALSE, other);
	//dprint7("Trace 2: ", vtos(trace_endpos), ", absmin: ", vtos(self.absmin), ", absmax: ", vtos(self.absmax), "\n");
	if (trace_fraction <= fraction) {
		//dprint("Trace 2 shorter. Replacing\n");
		if (checkbounds(trace_endpos + '0 0 8', self.absmin + '1 1 1', self.absmax - '1 1 1')) {
			//dprint("Trace 2 out of bounds.\n");
			bouncehit = TRUE;
		}
	
		traceorigin	= other.origin + [other.mins_x*0.75, other.mins_y*0.75, other.mins_z];
		fraction = trace_fraction;
		normal = trace_plane_normal;
		touchpoint = trace_endpos;
	}

	if (!bouncehit && !(self.spawnflags & BOUNCE_NO_BOUNDS_CHECK))
		return;

	up = normal;

	disttoplane = fabs(traceorigin_z - touchpoint_z);
	
	// Checks if there's something between the entity and the bounce point that's outside
	// the trigger's original bounds - for when you have something covering the
	// trampoline to "disable" it.
	// This must be done in a separate check, not in the bounds check,
	// because it must happen even when the "no bounds check" flag is on.
	if (touchpoint_z > self.absmin_z + self.height)
		return;

	// If the highest trace still fell below the trigger's lower bound,
	// set that as the bounce point, and set the default bounce angle as upwards.
	// This evaluation will only ever be true if the "no bounds check" flag is on,
	// otherwise the function would early out at the bouncehit check.
	if (touchpoint_z < self.absmin_z) {
		disttoplane = fabs(traceorigin_z - self.absmin_z);
		up = '0 0 1';
	}
	

	// optional bounce angle override
	if (self.punchangle != '0 0 0'){
		makevectors([-self.punchangle_x, self.punchangle_y, self.punchangle_z]);
		up = v_forward;
	}
	// "bounce on touch" triggers will have the bounce angle upwards by default
	else if (self.spawnflags & BOUNCE_ON_TOUCH)
		up = '0 0 1';
	
		
	// Player doesn't take any fall damage when landing on a trampoline
	other.cushion = self;
		
	entity ctrl;

	// setup bounce controller if not created yet
	if (other.bouncecontroller.classname != "bouncecontroller") {
		ctrl = spawn();
		other.bouncecontroller = ctrl;
		ctrl.classname = "bouncecontroller";
		ctrl.owner = other;
	}
	// otherwise, just fetch a reference to the existing one
	else
		ctrl = other.bouncecontroller;
	
	ctrl.think = bouncecontroller_think;
	ctrl.enemy = self;

	if (
		other.velocity_z > -fabs(self.speed) // Enforce a minimum velocity the player must fall so they won't just bounce endlessly
		|| self.speed == -1 // Cushion only (no bounce)
	) {
		//dprint4(other.classname, " (", ftos(framecount), "): low vertical speed, early out\n");
		//ctrl.movedir = '0 0 0';
		return;
	}

	vector playervel = other.velocity;

	float timetobounce;
	

	// Calculates at which time the bounce will happen.
	// Currently it's set to be at the surface and it works fine.

	// When the "bounce on touch" flag is on, the bounce will
	// happen when the entity hits the top of the original trigger size.
	
	if (self.spawnflags & BOUNCE_ON_TOUCH)
		timetobounce = fabs((self.absmin_z + self.height - other.absmin_z)/other.velocity_z);
	else
		timetobounce = fabs(disttoplane/other.velocity_z);

	// calculates the downwards velocity the player will have at the bounce point, accounting for gravity
	float grav = cvar("sv_gravity");
	if (other.gravity) grav *= other.gravity;
	playervel_z -= timetobounce * grav;

	// reflection equation
	// small correction factor for bounce velocity to be more or less consistent between jumps
	playervel = playervel - 2*playervel * up * up * self.elasticity + [0, 0, (frametime*480) - 0.5];
	
	// if maxbounce is set, cap vertical movement speed at maxbounce
	if (self.maxbounce > 0 && playervel_z > self.maxbounce)
		playervel_z = self.maxbounce;

	ctrl.movedir = playervel;
	
	dprint8(other.classname, " (", ftos(framecount), "): setting think ", ftos(timetobounce*1000), "ms ahead. Velocity to set: ", vtos(playervel), "\n");
	ctrl.nextthink = time + timetobounce;
}

/*
Tests if trigger_trampoline is sitting on top of a clip brush, by doing 16 tracelines downwards
spread across the trigger's horizontal area. If no more than 1/4 of the traces hit something,
it assumes it's on top of a clip brush and enables the No Bounds Check flag if it wasn't before.
*/
void() trigger_trampoline_checkclip = {

	float xstep = rint((self.size_x - 32)/4);
	float ystep = rint((self.size_y - 32)/4);
	vector trace_xy;
	float x, y, hits;

	for (y = 0; x < 4; x++) {
		for (y = 0; y < 4; y++) {
			trace_xy = [self.absmin_x + 16 + x*xstep, self.absmin_y + 16 + y*ystep, 0];
			traceline(trace_xy + [0, 0, self.absmin_z + self.height], trace_xy + [0, 0, self.absmin_z - 1], FALSE, self);

			if (trace_fraction < 1)
				hits++;

			if (hits > 4)
				break;
		}

		if (hits > 4)
			break;
	}

	if (hits < 4) {
		dprint3("WARNING: trigger_trampoline at ", vtos((self.absmin + self.absmax)/2), " probably over clip brush, disabling bounds check\n");
		self.spawnflags |= BOUNCE_NO_BOUNDS_CHECK;
	}
}

void() trigger_trampoline = {
	if (SUB_Inhibit ())  // new spawnflags for all entities -- iw
		return;

	InitTrigger ();
	// stretches the trigger upwards so it's at least 48u tall
	// 48 is enough to catch an entity falling 1500ups downwards at 30fps
	// taller than that risks making the trigger to fire when it's not supposed to
	self.height = self.size_z;
	if (self.size_z < 48){
		setsize(self, self.mins, [self.maxs_x, self.maxs_y, self.mins_z + 48]);
	}

	//if (mapname == "rm_heretics") {
	//	dprint("rm_heretics found. Turning on the Bounce on Touch and No Bounds Check flags for all trampolines\n");
	//	self.spawnflags |= BOUNCE_ON_TOUCH + BOUNCE_NO_BOUNDS_CHECK;
	//}

	precache_sound ("misc/bounce1.wav");
	precache_sound ("misc/bounce2.wav");
	precache_sound ("misc/bounce3.wav");
	precache_sound ("misc/bounce4.wav");
	precache_sound ("misc/bounce5.wav");
	precache_sound ("misc/bounce6.wav");
	precache_sound ("misc/cushion1.wav");
	precache_sound ("misc/cushion2.wav");
	precache_sound ("misc/cushion3.wav");
	precache_sound ("misc/cushion4.wav");
	precache_sound ("misc/cushion5.wav");
	precache_sound ("misc/cushion6.wav");
	
	if (self.noise != "")
		precache_sound(self.noise);
		
	if (self.noise2 != "")
		precache_sound(self.noise2);
	
	self.touch = trampoline_touch;
	if (!self.speed)
		self.speed = 200;
	if (!self.elasticity)
		self.elasticity = 1;
	if (!self.sounds)
		self.sounds = 0;
	if (!self.maxbounce)
		self.maxbounce = 0;

	if (!(self.spawnflags & BOUNCE_NO_BOUNDS_CHECK)) {
		self.think = trigger_trampoline_checkclip;
		self.nextthink = time + 0.3;
	}
};

