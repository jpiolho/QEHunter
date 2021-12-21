/*
 * Executes a function with another 'self' context.
 */
#define ExecuteAs(function,executionAs) {\
    local entity __executeAsOSelf = self;\
    self = executionAs;\
    function;\
    self = __executeAsOSelf;\
}(void)__NULL__


float(entity p) IsPlayerActive =
{
    return p.netname != "";
}

entity(entity previous) LoopPlayers =
{
    local entity p = previous;
    while((p = find(p,classname,"player")))
    {
        // Only loop through active players
        if(IsPlayerActive(p))
            return p;
    }

    return world;
}



/*
 * Executes a function after a specific delay.
 * This is achieved by creating a temporary entity and setting the 'think'.
 * Use the returned entity to set any parameters you wish.
 */
entity(void() function,float delay) ExecuteDelayed =
{
    local entity ent = spawn();
    ent.think = function;
    ent.nextthink = time + delay;

    return ent;
}

/*
 * Returns a random number between min (inclusive) and max (exclusive).
 * Example - Return a number between 1 and 10: RandomRange(1,11);
 */
float(float min,float max) RandomRange =
{
    return floor(random() * (max-min) + min);
}

float(float min,float max) RandomRangeI =
{
    return RandomRange(min,max+1);
}


float() GetPlayerCount =
{
    local float c = 0;
    local entity p;

    // Count how many players exist
    while((p = LoopPlayers(p)))
        c++;

    return c;
}

/*
 * Returns a random player.
 */
entity() RandomPlayer =
{
    local entity p;

    local float c = GetPlayerCount();

    // Check if there is actually any players
    if(c == 0)
        return world;

    local float randomPlayer = RandomRange(0,c);

    // Go through all players until the randomized one is found
    c = 0;
    p = world;
    while((p = LoopPlayers(p)) && c < randomPlayer)
    {
        c++;
    }

    return p;
}

/*
Loops through all the active players that match a condition and execute a piece of code.
Use the variable loopPlayer as the player entity that's being checked for the condition.

Example usage:
// Send a message to all players in team 1
MACRO_LoopPlayersWithConditionAndExecute(loopPlayer.team == 1,{
    centerprint(loopPlayer,"You are team one");
});
*/
#define MACRO_LoopPlayersWithConditionAndExecute(condition,execute) {\
    local entity loopPlayer;\
    while((loopPlayer = find(loopPlayer,classname,"player"))) {\
        if(IsPlayerActive(loopPlayer) && (condition))\
            execute;\
    }\
}(void)__NULL__

#define RandomPlayerWithCondition(variable,condition,maxAttempts) {\
    local float __maxattempts = maxAttempts;\
    do {\
        variable = RandomPlayer();\
        if(condition) {\
            break;\
        }\
    } while(--__maxattempts > 0);\
}(void)__NULL__