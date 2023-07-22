//this file generated with SNES GSS tool

#define SOUND_EFFECTS_ALL	8

#define MUSIC_ALL	5

//sound effect aliases

enum {
	SFX_DOORCLOSE=0,
	SFX_DOOROPEN=1,
	SFX_COINS=2,
	SFX_FLOWER=3,
	SFX_HURT=4,
	SFX_BUBBLE=5,
	SFX_POWERUP=6,
	SFX_JUMP=7
};

//sound effect names

const char* const soundEffectsNames[SOUND_EFFECTS_ALL]={
	"DOORCLOSE",	//0
	"DOOROPEN",	//1
	"COINS",	//2
	"FLOWER",	//3
	"HURT",	//4
	"BUBBLE",	//5
	"POWERUP",	//6
	"JUMP"	//7
};

//music effect aliases

enum {
	MUS_TITLE=0,
	MUS_THEME_1=1,
	MUS_THEME_2=2,
	MUS_BOSS=3,
	MUS_THEME3=4
};

//music names

const char* const musicNames[MUSIC_ALL]={
	"TITLE",	//0
	"THEME 1",	//1
	"THEME 2",	//2
	"BOSS",	//3
	"THEME3"	//4
};

extern const unsigned char spc700_code_1[];
extern const unsigned char spc700_code_2[];
extern const unsigned char music_1_data[];
extern const unsigned char music_2_data[];
extern const unsigned char music_3_data[];
extern const unsigned char music_4_data[];
extern const unsigned char music_5_data[];

const unsigned char* const musicData[MUSIC_ALL]={
	music_1_data,
	music_2_data,
	music_3_data,
	music_4_data,
	music_5_data
};
