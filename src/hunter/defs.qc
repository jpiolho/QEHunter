.float hunterTeam;

float hunter_status;


float HUNTER_STATUS_ROUND_STARTING = 0;
float HUNTER_STATUS_ROUND_IN_PROGRESS = 1;


float HUNTER_FL_SEEN_STARTING_MESSAGE = 1;
float HUNTER_FL_CANT_RESPAWN = 2;

float HUNTER_TEAM_NONE = 1;
float HUNTER_TEAM_HUNTER = 5;
float HUNTER_TEAM_SURVIVOR = 12;

enum {
    HUNTER_STATE_INVISIBLE,
    HUNTER_STATE_VISIBLE
};

string HUNTER_SOUND_HUNTER_DEATH = "shalrath/death.wav";
string HUNTER_SOUND_HUNTER_PAIN = "shalrath/pain.wav";
string HUNTER_SOUND_HUNTER_LAND = "demon/dland2.wav";
string HUNTER_SOUND_HUNTER_VISIBILITY_INCREASED = "weapons/ax1.wav";
string HUNTER_SOUND_HUNTER_IDLE_1 = "wizard/widle1.wav";
string HUNTER_SOUND_HUNTER_IDLE_2 = "wizard/widle2.wav";

string HUNTER_SOUND_HIT = "misc/menu3.wav";


float HUNTER_GAME_VISIBILITY1_AFTER = 20;
float HUNTER_GAME_VISIBILITY2_AFTER = 45;
float HUNTER_GAME_VISIBILITY3_AFTER = 60;


#define invisibleTime lip