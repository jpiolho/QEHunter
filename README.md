# QE Hunter
Quake Enhanced Hunter

This is a multiplayer mod where one player is the hunter and the other players are the survivors. The Hunter is mostly invisible and can walk around without being seen.

# Download
* [QEThings MPMods](https://mpmods.qethings.xyz) - Automatic install
* [Github Release](https://github.com/jpiolho/QEHunter/releases/latest) - Manual install

# Information

## How to manually install
1. Go to your 'Saved games' quake folder, NOT THE STEAM FOLDER. You can go to it by pressing Windows+R and typing: `%userprofile%\Saved Games\Nightdive Studios\Quake`
2. If a folder called '`id1`' already exists, delete it.
3. Extract zip into the 'Saved games' folder.
4. Verify that `id1` and `mpmod` folder are now inside 'Saved games'.

## How to run the mod
**NOTE:** If you're using [QEThings MPMods](https://mpmods.qethings.xyz), follow the instructions for it instead.

1. Open console and type `game mpmod`
2. Start a multiplayer game. The mod will start automatically.

## Server things

### Server options
To set server options, set the cvar `saved2`. To add multiple modes together, sum their values. Example: Mode 1 + Mode 2 = 3 (`saved2 3`).

**Mode 1: Host mode**: You'll be placed in a host configuration, invisible and noclipping.

**Mode 2: Hide host**: The host will not show up in the scoreboard

### Mapcycler
This mod features mapcycler config support. At the start of each map the following cfg will be executed: `mapcycler_qehunter.cfg`

Whenever the game decides to changelevel, it will run the following alias `nextmap_<current map name>`.

An example mapcycler would be:
```
alias "nextmap_dm4" "changelevel dm5"
alias "nextmap_dm5" "changelevel dm6"
alias "nextmap_dm6" "changelevel dm7"
alias "nextmap_dm7" "changelevel dm8"
alias "nextmap_dm8" "changelevel e1m2"
alias "nextmap_e1m2" "changelevel dm2"
alias "nextmap_dm2" "changelevel dm4"
```

## Credits
* JPiolho: Author
* People @ Quake Enhanced Discord: Feedback, ideas and testing
