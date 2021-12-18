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

entity(void() function,float delay) ExecuteDelayed =
{
    local entity ent = spawn();
    ent.think = function;
    ent.nextthink = time + delay;

    return ent;
}

