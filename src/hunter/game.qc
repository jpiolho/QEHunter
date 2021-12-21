float modelindex_eyes;
float modelindex_player;

void(float corpse) respawn;


void(entity player,float newTeam) Hunter_SetTeam =
{
    player.team = player.hunterTeam = newTeam;

    // Send the player colors
    stuffcmd(player,"color ");
    stuffcmd(player,ftos(player.team-1));
    stuffcmd(player,"\n");
}

void() Hunter_SwapTeams_Think =
{
    Hunter_SetTeam(self.owner,HUNTER_TEAM_SURVIVOR);
    Hunter_SetTeam(self.enemy,HUNTER_TEAM_HUNTER);

    ExecuteAs(respawn(FALSE),self.enemy);

    if(self.owner.deadflag != DEAD_NO) {
        ExecuteAs(respawn(FALSE),self.owner);
    }
}

void() Hunter_ReassignHunter_Think =
{
    dprint("Reassigning hunter...\n");

    local entity newHunter;
    RandomPlayerWithCondition(newHunter,newHunter.hunterTeam != HUNTER_TEAM_HUNTER && newHunter != hunter_host,10);

    dprint("\"");
    dprint(newHunter.netname);
    dprint("\" is the new hunter\n");

    Hunter_SetTeam(newHunter,HUNTER_TEAM_HUNTER);

    ExecuteAs(respawn(FALSE),newHunter);

    centerprint(newHunter,self.message);

    //"You've been changed to hunter due to the previous player leaving the game\n"
}

void(entity attacker) Hunter_Killed =
{
    dprint("GAME: Hunter has died. Cause: ");

    // Make the body visible
    self.alpha = 0.8;

    // Check if the killer is a survivor
    if(attacker && attacker.classname == "player" && attacker.hunterTeam != HUNTER_TEAM_HUNTER) {
        dprint("Killed by survivor '");
        dprint(attacker.netname);
        dprint("'\n");

        // Do announcements
        centerprint(attacker,"You killed the hunter\n");
        centerprint(self,"You've been killed by a survivor\n");

        MACRO_LoopPlayersWithConditionAndExecute(loopPlayer != attacker && loopPlayer != self,{
            centerprint(loopPlayer,"The hunter has been killed\n");
        });

        bprint(attacker.netname);
        bprint(" killed the hunter!\n");

        // Swap teams
        local entity swap = ExecuteDelayed(Hunter_SwapTeams_Think,3.0);
        swap.owner = self;
        swap.enemy = attacker;

        // Mark both players as non-respawnable
        self.cnt |= HUNTER_FL_CANT_RESPAWN;
        attacker.cnt |= HUNTER_FL_CANT_RESPAWN;
    }
    else {
        dprint("Other\n");

        MACRO_LoopPlayersWithConditionAndExecute(loopPlayer != self,{
            centerprint(loopPlayer,"The hunter has died\n");
        });

        bprint("The hunter has died!\n");

        // Get the last player to hit the hunter
        if(self.oldenemy)
        {
            // Swap teams
            local entity swap = ExecuteDelayed(Hunter_SwapTeams_Think,3.0);
            swap.owner = self;
            swap.enemy = attacker;
        }
        else {
            // The hunter died before anybody hurting them. Choose randomly
            ExecuteDelayed(Hunter_ReassignHunter_Think,3.0);
        }

        self.cnt |= HUNTER_FL_CANT_RESPAWN;
    }
}

void(entity target) Hunter_PrintSpawnMessage =
{
    if(target.hunterTeam == HUNTER_TEAM_HUNTER) {
        centerprint(target,"You are the hunter\nOther players can't see you easily\n\nHunt them all");
    } else {
        centerprint(target,"You are a survivor\nYou're being hunted\n\nTeam up and survive");
    }
}



void() Hunter_ClientDisconnect =
{
    if(self.hunterTeam == HUNTER_TEAM_HUNTER) {
        dprint("Hunter left the game\n");

        local entity reassign = ExecuteDelayed(Hunter_ReassignHunter_Think,5);
        reassign.message = "You've been changed to hunter due to the previous player leaving the game\n";
    }
}


void() Hunter_StartingMessage_Think =
{
    if(!self.enemy) {
        remove(self);
        return;
    }

    centerprint(self.enemy,"Welcome to Hunter 1 vs All\nOne player is invisible and it's hunting the other ones\n\nAny bugs are probably related to the mod\nHave fun!");

    if(--self.cnt <= 0) {
        Hunter_PrintSpawnMessage(self.enemy);
        remove(self);
    }

    self.nextthink = time + 1.0;
}

void() Hunter_SpawnStartingMessageEntity =
{
    local entity s = spawn();
    s.enemy = self;
    s.cnt = 5;
    s.think = Hunter_StartingMessage_Think;
    s.nextthink = time + 1.0;
}

void() Hunter_OnGameStart =
{
    hunter_status = HUNTER_STATUS_ROUND_STARTING;
}

void() Hunter_OnPrecache =
{
    precache_sound(HUNTER_SOUND_HUNTER_DEATH);
    precache_sound(HUNTER_SOUND_HUNTER_LAND);
    precache_sound(HUNTER_SOUND_HUNTER_PAIN);
    precache_sound(HUNTER_SOUND_HUNTER_VISIBILITY_INCREASED);
    precache_sound(HUNTER_SOUND_HUNTER_IDLE_1);
    precache_sound(HUNTER_SOUND_HUNTER_IDLE_2);
}

void() Hunter_PutClientInServer =
{
    // Hide host
    if(hunter_host && Hunter_GetServerOptions() & SERVERSETTINGS_HIDEHOST) {
		ExecuteDelayed(Hunter_HideHost_Think,0.1).owner = self;
	}

    // Handle host mode
    if(hunter_host == self)
	{
        // Set noclip
		self.movetype = MOVETYPE_NOCLIP;
		self.solid = SOLID_NOT;

        // Set flags so bots and monsters don't target
		self.flags |= FL_FLY | FL_NOTARGET | FL_GODMODE;
		self.takedamage = DAMAGE_NO;

        // Remove weapons
		self.items = 0;
		self.weapon = IT_AXE;
		self.weaponmodel = string_null;

        // Remove the player model entirely
		setmodel (self, string_null);
		self.modelindex = modelindex_player; // Still allow the player to move around

        return;
	}


    // Remove 'cant respawn' flag
    self.cnt -= self.cnt & HUNTER_FL_CANT_RESPAWN;

    // Remove the last player hit
    self.oldenemy = world;

    if(self.hunterTeam == HUNTER_TEAM_HUNTER) {
        self.modelindex = modelindex_eyes;

        self.items |= IT_INVISIBILITY;
        self.invisible_time = 1;
        self.invisible_finished = FALSE;

        self.state = HUNTER_STATE_INVISIBLE;
        self.alpha = 0.01;
        self.waitmin = time;
        self.pos1 = self.origin;

        self.max_health = self.health = 75;
	}
    else {
        self.alpha = 1;
    }

    Hunter_PrintSpawnMessage(self);
}

void(entity player) Hunter_AssignTeamToPlayer =
{
    if(hunter_status == HUNTER_STATUS_ROUND_STARTING)
    {
        local float numberHunters = 0;
        local float numberSurvivors = 0;

        // Find out how many of each exist in the game
        local entity p = world;
        while((p = LoopPlayers(p)))
        {
            if(p.hunterTeam == HUNTER_TEAM_HUNTER)
                numberHunters++;
            else if(p.hunterTeam == HUNTER_TEAM_SURVIVOR)
                numberSurvivors++;
        }


        // Assign the team
        if(numberHunters == 0)
        {
            Hunter_SetTeam(player,HUNTER_TEAM_HUNTER);
        }
        else
        {
            Hunter_SetTeam(player,HUNTER_TEAM_SURVIVOR);
        }

        // Set an impossible team so that the color is set in PlayerPreThink
        player.team = -1;
    }
}


void() Hunter_PlayerPreThink =
{
    if(self.team != self.hunterTeam)
    {
        self.team = self.hunterTeam;

        // Send the player colors
        stuffcmd(self,"color ");
        stuffcmd(self,ftos(self.team-1));
        stuffcmd(self,"\n");
    }


    if(!(self.cnt & HUNTER_FL_SEEN_STARTING_MESSAGE))
	{
        Hunter_SpawnStartingMessageEntity();

		// Mark as message sent
		self.cnt |= HUNTER_FL_SEEN_STARTING_MESSAGE;
	}

}


void() Hunter_PlayerPostThink =
{
    if(self.hunterTeam == HUNTER_TEAM_HUNTER)
    {
        // Show the player whenever they have some powerup or fire something
        if(self.effects != 0)
        {
            self.invisible_time = time + 1.5;
        }

        if(time >= self.invisible_time) {
            // Play sound if changing into invisible
            if(self.state != HUNTER_STATE_INVISIBLE)
                sound(self,CHAN_ITEM,HUNTER_SOUND_HUNTER_VISIBILITY_INCREASED,1,ATTN_NORM);

            // Play a scary idle sound
            if(random() < 0.0025) {
                switch(rint(random() * 1)) {
                    case 0: sound(self, CHAN_VOICE, HUNTER_SOUND_HUNTER_IDLE_1, 1, ATTN_NORM); break;
                    case 1: sound(self, CHAN_VOICE, HUNTER_SOUND_HUNTER_IDLE_2, 1, ATTN_NORM); break;
                }
            }

            self.modelindex = modelindex_eyes;
            self.alpha = 0.01;

            self.items |= IT_INVISIBILITY;
            self.state = HUNTER_STATE_INVISIBLE;
        }
        else {

            // Reveal the player somewhat
            self.modelindex = modelindex_player;
            self.alpha = 0.5;
            self.state = HUNTER_STATE_VISIBLE;

            self.items -= self.items & IT_INVISIBILITY;
        }
    }
}