;this file generated with SNES GSS tool and then completly modified

kSFX .block
	DOORCLOSE	= 0
	DOOROPEN		= 1
	COINS			= 2
	FLOWER		= 3
	HURT			= 4
	BUBBLE		= 5
	POWERUP		= 6
	JUMP			= 7
.bend

kMus .block
	TITLE		= 0
	THEME_1	= 1
	THEME_2	= 2
	BOSS		= 3
	THEME3	= 4
.bend

.section ".roDataSoundCode1" superfree
spc700_code_1:	.incbin "spc700.bin" skip 0 read 32007
spc700_code_2:
.ends

.section ".roDataMusic1" superfree
music_1_data:	.incbin "music_1.bin"
.ends

.section ".roDataMusic2" superfree
music_2_data:	.incbin "music_2.bin"
.ends

.section ".roDataMusic3" superfree
music_3_data:	.incbin "music_3.bin"
.ends

.section ".roDataMusic4" superfree
music_4_data:	.incbin "music_4.bin"
.ends

.section ".roDataMusic5" superfree
music_5_data:	.incbin "music_5.bin"
.ends

