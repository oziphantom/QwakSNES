; Bank 80
.virtual $800000+gSharedRamstart
.include "sharedWRAM.asm"
.endv

kVRAM .block
	titleScreen		= $0000/2
	gameScreen		= $0800/2
	font				= $1000/2
	fontDest			= $1400/2
	gameChars		= $2000/2
	Sprite			= $8000/2
.bend

kTileXCount = 16
kTileYCount = 12
kLevelSizeMax = kTileXCount*kTileYCount
kSprBase = 0
kBulletSpriteOffset = 1
kEntsSpriteOffset = 2
kBulletCollisionbox = 1
kBounds .block
	screenMinX = 0
	;screenMinY = 0
	;screenMaxX = ( kTileXCount * 16 )
	screenMaxY = ( kTileYCount * 16 )
.bend

kTiles .block
	back = 0

	wall = 1
	wall1 = 2
	wall2 = 3
	wall3 = 4
	wall4 = 5

	spike = 6
	flower = 7
	fruit = 8

	key1 = 9
	key2 = 10
	key3 = 11
	key4 = 12

	shield = 13
	spring = 14
	potion = 15
	egg = 16

	exit = 17
	player = 18

	pipe = 19
	diss = 20
	dissNoColide = 33

	underHangStart = 34
	underHang = 35
	shadowOpenCorner = 36
	sideShadow = 37
	middlesideShadow = 38
	topLeftCorner = 39
	intermissionOldWall = 37	; used to look up the tile for the intermission
.bend
kKeyToWallDelta = kTiles.key1 - kTiles.wall1
kDoorClosed = 10
kDoorOpen = 14

kDefault_OBSEL  = %01100010 ; 8x8 and 16x16 0 gap and sprites at 8K
kBossBearBankOR = %00001000 ; move the upper half 1 4K bank up
kBossOctoBankOR = %00010000 ; move the upper half 2 4K bank up

kShieldTimer = 10*50			; 10 seconds on PAL


.as				; Assume A8
.xs				; Assume X8
.autsiz			; Auto size detect
.databank $00	; databank is 00
.dpage $0000	; dpage is 0000

RESET
	clc
	xce
	lda #$01
	sta $420D	; go fast, because why not?
	jml RESETHi
RESETHi
	REP #$30		; AXY 16
	ldx #$1FFF	; set Stack to top of Shared RAM
	txs
	phk
	plb			; set the data bank to also be fast
.databank $80
	lda #0000
	tcd				; set DP to 0
	lda #$008F		; FORCE BLANK, SET OBSEL TO 0
	sta $802100
ClearWRAM
	lda #$8008		; A -> B, FIXED SOURCE, WRITE BYTE | WRAM
	sta $804300
	lda #<>DMAZero	; 64Tass | get low word
	sta $804302
	lda #`DMAZero	; 64Tass | get bank
	sta $804304
	stz $802181
	stz $802182		; START AT 7E:0000
	stz $804305		; DO 64K
	lda #$0001
	sta $80420B		; FIRE DMA
	sta $80420B		; FIRE IT AGAIN, FOR NEXT 64k
InitSNESAndMirror	; this is defualt init sequence
	REP #$20			; a16
	lda #$008F		; FORCE BLANK, SET OBSEL TO 0
	sta $802100
	sta mINIDISP
	;stz mOBSEL
	stz $802105 ;6
	;stz mBGMODE
	;stz mMOSIAC
	stz $802107 ;8
	;stz mBG1SC
	;stz mBG2SC
	stz $802109 ;A
	;stz mBG3SC
	;stz mBG4SC
	stz $80210B ;C
	;stz mBG12NBA
	;stz mBG23NBA
	stz $80210D ;E
	stz $80210D ;E
	;stz mBG1HOFS
	;stz mBG1VOFS
	stz $80210F ;10
	stz $80210F ;10
	;stz mBG2HOFS
	;stz mBG2VOFS
	stz $802111 ;12
	stz $802111 ;12
	;stz mBG3HOFS
	;stz mBG3VOFS
	stz $802113 ;14
	stz $802113 ;14
	;stz mBG4HOFS
	;stz mBG4VOFS
	stz $802119 ;1A to get Mode7
	stz $80211B ;1C these are write twice
	stz $80211B ;1C regs
	stz $80211D ;1E
	stz $80211D ;1E
	stz $80211F ;20
	stz $80211F ;20
	; add mirrors here if you are doing mode7
	stz $802123 ;24
	;stz mW12SEL
	;stz mW34SEL
	stz $802125 ;26
	;stz mWOBJSEL
	stz $802126 ;27 YES IT DOUBLES OH WELL
	stz $802128 ;29
	;stz mWH0
	;stz mWH1
	;stz mWH2
	;stz mWH3
	stz $80212A ;2B
	;stz mWBGLOG
	;stz mOBJLOG
	stz $80212C ;2D
	stz $80212E ;2F
	;stz mTM
	;stz mTS
	;stz mTMW
	;stz mTSW
	lda #$00E0
	sta $802132
	sta mCOLDATA
	;stz mSETINI
	;ONTO THE CPU I/O REGS
	lda #$FF00
	sta $804201
	;stz mNMITIMEN
	stz $804202 ;3
	stz $804204 ;5
	stz $804206 ;7
	stz $804208 ;9
	stz $80420A ;B
	stz $80420C ;D
	; CLEAR VRAM
	REP #$20			; A16
	lda #$1809		; A -> B, FIXED SOURCE, WRITE WORD | VRAM
	sta $804300
	lda #<>DMAZero ; THIS GET THE LOW WORD, YOU WILL NEED TO CHANGE IF NOT USING 64TASS
	sta $804302
	lda #`DMAZero	; THIS GETS THE BANK, YOU WILL NEED TO CHANGE IF NOT USING 64TASS
	sta $804304		; AND THE UPPER BYTE WILL BE 0
	stz $804305		; DO 64K
	lda #$80			; INC ON HI WRITE
	sta $802115
	stz $802116		; START AT 00
	lda #$01
	sta $80420B		; FIRE DMA
	; CLEAR CG-RAM
	lda #$2208		; A -> B, FIXED SOURCE, WRITE BYTE | CG-RAM
	sta $804300
	lda #$200		; 512 BYTES
	sta $804305
	SEP #$20			; A8
	stz $802121		; START AT 0
	lda #$01
	sta $80420B		; FIRE DMA
	stz NMIReadyNF
	#AXY8
	lda #kHideScreen.hide	; make sure the screen is in the hidden mode, it should be, but doesn't hurt ;)
	sta HideScreen
	.cerror kHideScreen.hide < 128, "need to find an actual negative value for disableUpdateSpritesXYToOAMNF"
	sta disableUpdateSpritesXYToOAMNF

	jsr clearSpritesMirror_xx	;sets all sprites to offscreen, small

	jsr dmaPalletes_XX			; we have fixed palletes so upload them
	jsr dmaFixedChars_xx			; also the fixed chars which don't change

	; draw the title screen
	; since I have enough VRAM to spare I just draw this once 
	; and then set the BG1 to point to it when I want to
	jsr clearScreenMirrorToEmptyChar
	; draw each string ( exepet for Game Over )
	ldx #len(TitleScreenData.AllStrings)*2-2 ; -2 because they are words now
	stx ZPTemp
-	ldx ZPTemp
	jsr plotStringAAtIndexX
	dec ZPTemp
	dec ZPTemp
	bpl -
	; put the Screen mirror into VRAM 
	jsr dmaScreenMirrorToTitleScreen_xx
	; init the SPC and start the title screen music
	#AXY16
	lda #<>spc700_code_1
	ldx #`spc700_code_1
	jsl SPC_Init
	lda #1
	jsl SPC_Stereo
	lda #<>music_1
	ldx #`music_1
	jsl SPC_Play_Song
	#A8
	; set up mode and tile pointer
	lda #1			; mode 1
	sta $802105
	lda #%00010001
	sta $80212C		; make 1 + sprites on Main Screen

	lda #%10000001
	sta $804200		; enable VBlank NMI and enable auto Joypad reading

	; set the main FSM to point to the title screen FSM
	#A16
	lda #<>titleScreenLoop
	sta GameStatePointer

	; this is the Main Game loop high level
	; it will wait for the NMI
	; dispatch the current high level FSM mode
	; update sprites in the mirror if required
MainLoop
	#AXY8
MainLoopWait
	lda NMIReadyNF
	bpl MainLoopWait	; Read Flag
	stz NMIReadyNF		; Clear Flag
	ldx #0				; sadly no jsr(XXXX) so dummy x
	jsr (GameStatePointer,k,x) ; why ,k well if you don't have it you get something like
										; "error: address in different program bank address '($001b,x)'"
										; ,k is a 64tass modificatgion not a 65816 addressing mode.
										; See section 3.9 of the manual for details basically ,k says make this 
										; "program bank relative" aka "trust me"
	#AXY8
	bit disableUpdateSpritesXYToOAMNF
	bmi +								; this could be MainLoop but that might cause you pain later if you make mods to this code
		jsr updateAllSpriteXYsToOAMMirror_88
+	bra MainLoop

.section sDP
NMIReadyNF .byte ?	; I need the flag and I want it in the DP
.send ; sDP

DMAZero .word $0000	; DMA needs a memory address for writing fixed values

kHideScreen .block
	hide = $80			; force blank, screen brightness 0
	show = $0f			; display on, screen brightness 15
.bend

; ----- @NMI@ -----

NMI
	jml NMIFast				; Move To 8X:XXXX for speed
NMIFast
	phb						; Save Data Bank
	phk
	plb						; Set Data Bank to Match Program Bank
	#A8						; A8
	bit $804210				; Ack NMI
	bit@W NMIReadyNF,b	; Check if this is safe
	bpl _ready
		plb					; No, restore Data Bank
		rti					; Exit
_ready						; Safe
	#AXY16					; A16 XY16
	pha
	phx
	phy						; Save A,X,Y
	phd						; Save the DP register
	lda #0000				; or where ever you want your NMI DP
	tcd						; set DP to known value
	; do update code here
	#AXY8
	lda HideScreen
	sta $2100							; enable screen, or not as case may be
	bmi _Notvisible
		jsr dmaOAM_xx					; this will take up enough time to ensure auto read works
		jsr scanJoystick_88			; joystick because Commodore 64 port
		lda ScreenUpdateRequiredN0	; only DMA screen if something has been updated
		beq +
			jsr dmaScreenMirror_xx
			stz ScreenUpdateRequiredN0
	+	lda #128+(2*16)+5				; sprite pallete, 2nd one, 7 entry index
		sta $802121						; which is the player body colour
		ldx PlayerData.flashColour
		lda PlayerColourLUT.lo,x
		sta $802122						; write a single pallete entry
		lda PlayerColourLUT.hi,x
		sta $802122
_Notvisible
	#A8					; A8
	lda #$FF				; Doing this is slightly faster than DEC, but 2 more bytes
	sta NMIReadyNF		; set NMI Done Flag
	#AXY16				; A16 XY16
	pld					; restore DP page
	ply
	plx
	pla					; Restore A,X,Y
	plb					; Restore Data Bank
justRTI
	rti					; Exit

; ----- @Game loop@ -----

; this runs the level logic
.as
.xs
GAMELOOP
	#AXY8
	jsr updateTickdowns_88		; count down the timers
	lda PlayerData.state			; dispatch the player state
	_ASSERT_A_LT_6					; make sure we don't get a value too high that puts is into the nulabor code wise
	asl a								; the states is set so you could precalc this but inc is handy and we are not tight
	tax								; for code
	jmp (PlayerCodeLUT,x)		; dispatch
PlayerCodeLUT .word <>(playerAppear,playerNormal,playerNormal,playerNormal,playerExit,playerDead)

.as
.xs
; this will unpack the level data, dma the screen, sprites and init the player to spawn position
; screen should be off when called
playerAppear
	#AXY8
	jsr clearSpritesMirror_xx		; remove all sprites
	jsr convertLevelToTileMap_88	; unpack the current level
	jsr addShadowsToMap_88			; decorate it
	jsr plotTileMap_88				; draw it to screen mirror
	jsr plotStatusArea				; also draw the status area (actually only needs to be done once but meh)
	jsr dmaScreenMirror_xx			; send it to VRAM
	jsr setAnimateDoorToOpen_88	; we want doors to open eventually
	; this takes care of all DMA operations
	stz PlayerData.deadNZ			; we are alive
	stz PlayerData.flashColour		; not flashing
	jsr setPlayerToSpawnPoint_88	; move player to starting position
	jsr unpackEntityBytes			; get the entities for this level
	jsr setEntitySprites				; setup their sprite data
	
	lda #fBGBaseSize(kVRAM.gameScreen,kBaseSize_32x32)
	sta $802107							; set the BG1 to the Game Screen
	lda #fBGCharAddress(kVRAM.gameChars,0,0,0) 
	sta $80210b							; set the chars to the in game set
	
	; we are ready to run the game loop as soon as we exit this basically
	lda #1
	sta NMIReadyNF
	;	lda #kPlayerState.normal ; == 1
	.cerror kPlayerState.normal != 1, "need to add lda back"
	sta PlayerData.state						; move FSM to the next state
	jsr changePlayerAnimForCurrentDir	; make sure the player's animation is correct
	stz GameData.exitOpenNZ					; the door is closed 
	lda #kHideScreen.show					; show the screen next NMI
	sta HideScreen
	.cerror kHideScreen.show > 128, "need to find something else positive for disableUpdateSpritesXYToOAMNF"
	sta disableUpdateSpritesXYToOAMNF	; we want to update the sprites now as well
	rts

.as
.xs
playerNormal
	lda #0 ; remove me when un commenting code below
	jsr BuildEntCollisionTable						; build the collision sets
	jsr collidePlayerAgainstRest					; did the player hit any entitiies
	stx CollidedEntity								; save the index of the one we hit, if any
	lda PlayerData.hitBubbleNum					; save current bubble we are standing on
	sta ZPTemp2
	lda #0
	sta PlayerData.hitBubbleNum					; clear current bubble
	rol a													; pull is carry set, which is if we collided or not
	sta ZPTemp											; cache it so we can restore it. php doesn't really work for this case
	beq _noSpriteCollision
		ldx CollidedEntity							; what did we hit
		lda EntityData.type,x
		jsr isTypeBossBounceDetect					; check if this was a boss bounce (which is 2nd boss ent collision)
		bcs _bossBounce
			jsr isTypeBoss								; no bouncing on a boss, check the against a boss
			bcs _checkBossDeath
				cpx EntityData.pipeBubbleStart	; was this a bubble?
				bcc _normalEnt
					; so it was a bubble
					lda PlayerData.OnGroundNZ		; if on ground or falling
					ora PlayerData.isFallingNZ		; don't collide if I'm jumping up
					beq _skipDeath
						ldx CollidedEntity
						lda mplexBuffer.ypos+kEntsSpriteOffset,x
						cmp mplexBuffer.ypos
						bcc _skipDeath					; if Bubble Y < player Y pos i.e above me skip
							stx PlayerData.hitBubbleNum
							cmp ZPTemp2
							beq _skipDeath				; already on this bubble so skip
								jsr enterOnGround		; we just landed on a bubble
					_skipDeath
							lda #0						; cancel collision state
							bra _noSpriteCollision
	_bossBounce
		lda PlayerData.hasShieldNZ					; boos bounce can only be done with a shield
		beq _normalEnt
			ldx CollidedEntity
			jsr hurtBoss								; hurt them
			inc PlayerData.forceJumpNZ				; bounce
			gra _skipDeathCheck
			;
	_checkBossDeath
		lda EntityData.entState,x					; if the boss is dead
		cmp #kBoss.dead								; ignore the collision
		beq _skipDeathCheck							; this is because bosses have a death animation
_normalEnt
		lda ZPTemp										; this is cache of did we collide
_noSpriteCollision
		ora PlayerData.deadNZ						; are we dead for some other reason
		beq _skipDeathCheck							; no, skip
			lda PlayerData.hasShieldNZ				; wait do I have a shield?
			bne _skipDeathCheck						; yup, skip
				; lda PasswordInfiLives				; password system is removed but
				; bne +									; left if you wish to restore it or add cheat codes
					dec GameData.lives
					jsr pltLives
		+		lda #kPlayerState.dead				; set player dead
				sta PlayerData.state					; set to the dead FSM state
				sta PlayerData.minorState
				rts
				;
_skipDeathCheck
		stz PlayerData.deadNZ						; not dead
		jsr joyToPlayerDelta_88						; move player based upon
		jsr checkSpriteToCharCollision_88		; collide player against world with deltas
		; level skip
;		lda PasswordLevelSkip						; password system removed but left in case you
;		beq _noKey										; want to bring it back
;			jsr $FF9F ; SCAN KEY
;			jsr $ffe4
;			cmp #90 ; Z key, we can't detect C=/CX key with gettin
;			bne _noKey
;			lda #kPlayerState.exit
;			sta PlayerData.state
;			sta PlayerData.minorState
;			rts
;_noKey
		lda checkSpriteToCharData.xDeltaCheck	; are we still moving on the X after collision
		beq _addY
		;make sure x reg is 0, and call addXWithMSBAndClip
			ldx #0
			jsr addXWithMSBAndClip_88				; offset player X
_addY
		lda mplexBuffer.ypos
		clc
		adc checkSpriteToCharData.yDeltaCheck	; offset Y
		sta mplexBuffer.ypos							; this is just done because Y can wrap
		jsr updatePlayerAnim_88						; update animation for new state
		lda PlayerData.hasShieldNZ					; if I have a shield update the flash
		beq _noShield
			lda PlayerData.shieldTimer.lo
			bne +
				dec PlayerData.shieldTimer.hi
	+		dec PlayerData.shieldTimer.lo			; 16 bit dec, this will bn much easier in 16bit version
			lda PlayerData.shieldTimer.lo
			ora PlayerData.shieldTimer.hi			; how to tell a 16bit value is zero in 8bit mode easily
			bne +
					stz PlayerData.hasShieldNZ		; it has expired
					stz PlayerData.flashColour		; reset flash colour to be sure
					bra _noShield
					;
	+		lda TickDowns.shieldFlashTimer		; need to toggle the flash?
			bne _noShield
				lda PlayerData.flashColour
				eor #1
				sta PlayerData.flashColour			; toggle 0->1 1->0
				lda TickDowns.shieldFlashTimerSpeedUp
				bne +
					lda #35								; every 35 frames we make the flash faster
					sta TickDowns.shieldFlashTimerSpeedUp
					dec PlayerData.baseFlashTimeDelta
			+	lda PlayerData.baseFlashTimeDelta
				sta TickDowns.shieldFlashTimer	; reset the timer
_noShield
		gra EndOfGameLoop
		;

.as
.xs
playerExit
	lda PlayerData.minorState
	cmp #kPlayerState.exit					; if this is not the first time 
	bne _waitForAnimation					; then skip the init
		lda #kPlayerAnimsIndex.exit		; we have to set up the exit animation
		jsr setPlayerAnimeTo_88
		;lda #kPlayerStateExit.waitForAnimation
		.cerror kPlayerStateExit.waitForAnimation != 0, "need to change stz"
		stz PlayerData.minorState			; when entering this state we set minor to same, so 0 to mark it done
		lda PlayerData.exitAtIndex
		jsr setPlayerToIndexA				; snap the player to the exit tile
		jsr removePickups_88					; clear any flashing
_exit	gra EndOfGameLoop
_waitForAnimation
	jsr updatePlayerAnim_88					; returns sec on animation end
	bcc _exit
		#A16
		lda #<>INTERLOOP							; move on to the interlude
		sta GameStatePointer
		#A8
		.cerror kPlayerState.appear != 0, "need to change stz"
		stz PlayerData.state					; return back to appear state
		jsr deactivateAllEntities
		jsr disableAllEntSprites_88		; death is level reset so clear all ents
		rts

.as
.xs
incLevelGraphicSet
_ASSERT_jsr
_ASSERT_axy8
	lda LevelData.levelGraphicsSet		; this has 4 values 0,1,2,3
	clc
	adc #1										; so add 1
	and #3										; and mask it
	sta LevelData.levelGraphicsSet
	rts											; only called once so could be inlined if wanted

.as
.xs
playerDead
	lda PlayerData.minorState
	cmp #kPlayerState.dead					; are we entering this state for the first time?
	bne _waitForAnimation
		lda #kSFX.hurt
		jsr playSFX
		lda #kPlayerAnimsIndex.dead		; we have to set up the exit animation
		jsr setPlayerAnimeTo_88
		;lda #kPlayerStateDeath.animate
		.cerror kPlayerStateDeath.animate != 0, "need to change stz"
		stz PlayerData.minorState			; mark that we have entered this before
		jsr removePickups_88					; basically removes flashing is the point
_exit	gra EndOfGameLoop
_waitForAnimation
	dec mplexBuffer.ypos						; move player up the screen
	jsr updatePlayerAnim_88					; update the flap animation
	bcc _exit
		lda GameData.lives					; all used up?
		beq _gameOver
			.cerror kPlayerState.appear != 0, "remove stz"
			;lda #kPlayerState.appear
			stz PlayerData.state
			stz PlayerData.deadNZ			; clear and reset level
			bra EndOfGameLoop
			;
_gameOver
	stz PlayerData.state						; go to game over
	#A16
	lda #<>gameOverLoop
	sta GameStatePointer
	#A8
	rts

.as
.xs
EndOfGameLoop
_ASSERT_axy8
	lda joyFireEvent					; if	  1 1 1 1 0 0 0 0
	eor PlayerData.bulletActive	; eor	  0 0 1 1 0 0 1 1
	and joyFireEvent					; and   1 0 1 0 1 0 1 0
	beq _noBulletStart				; gives 1 0 0 0 0 0 0 0
		jsr startBullet
_noBulletStart
	jsr updateBullet
	jsr updateEntities
	jsr updateBubbles
	jsr animateDoor_88
	rts

; ----- @Titlescreen loop@ -----

.as
.xs
titleScreenLoop
_ASSERT_axy8
	lda PlayerData.state
	asl a
	tax
	jmp (TitleScreenLoopFuncLUT,x)
TitleScreenLoopFuncLUT .word <>(TSSetup,TSWaitForFire,TSStartGame)

TSSetup
_ASSERT_axy8
	jsr deactivateAllEntities			; so we don't get any stray sprite due to race conditions
	jsr disableAllEntSprites_88		; this will clear OAM mirror as well
;	stz PasswordEntryIndex
	stz LevelData.levelGraphicsSet	; reset back to apples
	; set up the defaults here, in case a password modifies them
	jsr clearPlayerStuct_88				; clear the playerf
	lda #5
	sta GameData.lives					; give default lives
	stz GameData.currLevel				; reset to level 1. Change to lda # sta to make a level select for testing
	stz GameData.flowers					; no flowers

	lda #fBGBaseSize(kVRAM.titleScreen,kBaseSize_32x32)
	sta $802107								; set TS screen
	lda #fBGCharAddress(kVRAM.gameChars,0,0,0)
	sta $80210b								; set TS chars/same as game but this will happen first
	lda #kDefault_OBSEL
	sta $802101								; make sure we are in sprite upper bank 0 to get QWAK sprites
	#A16
	ldx #(4*4)-2							; 4 sprites at 4 bytes each
-	lda TitleScreenData.SpriteStruct.sprites,x
	sta OAMMirror,x
	dex
	dex										; writing words so skip 2
	bpl -
	#A8
	lda #TitleScreenData.SpriteStruct.kUpper
	sta OAMMirrorHigh
	lda #kMus.TITLE
	jsr playMusic
	inc PlayerData.state						; move to the wait for fire FSM state
	lda #$FF
	sta disableUpdateSpritesXYToOAMNF	; we do not have the player or Entities and so do not want the auto update
	lda #kHideScreen.show
	sta HideScreen
	rts

TSWaitForFire
_ASSERT_axy8
	jsr updateTickdowns_88
	; in reluanch64 you can just fold this block to skip it
.comment ;{{{
	; we don't have an audio or if we do it will be MUSIC + SFX always
	; this also has code to flash the QWAK sprites when cheat codes are enabled
	; one letter per cheat. This code is a mix of Commander X16 code 
	; and Commodore 64 code and is left in case you wish to crib from it
	; or I get music working on SNES to where parts will be pulled out from it
	lda TickDowns.playerAnim
	bne _checkJoy
		ldx ZPTemp2
		lda GameData.musicMode
		clc
		rol a
		rol a
		rol a ; get upper 2 bits wrapped arround to the lower 2 bits
		tay
		lda TitleScreenData.menuOffsetsEnd,y
		sta ZPTemp
		stz kVERA.CTRL
		lda #`kVRAM.titleScreen|kVERA.inc_2 ; skip char data
		sta kVERA.ADDR_Hi
CRAMLinePos = getTitleScreenCharPos(0,22)+1 ; get the 11 line
		lda TitleScreenData.menuOffsetsStart,y
		tay
		clc
		adc #<CRAMLinePos
		sta kVERA.ADDR_Lo
		lda #>CRAMLinePos
		adc #0
		sta kVERA.ADDR_Mid
	-	lda TitleScreenData.spriteCol,x
		sta kVERA.DATA_0
		pha
		lda PasswordInfiLives ; if cheats are enabled the text QWAK sprites flashed
		beq +
			pla
				sta mplexBuffer.sprc
			pha
	+	lda PasswordRedBullets
		beq +
			pla
				sta mplexBuffer.sprc+1
			pha
	+	lda PasswordHaveSpring
		beq +
			pla
				sta mplexBuffer.sprc+2
			pha
	+	lda PasswordLevelSkip
		beq +
			pla
				sta mplexBuffer.sprc+3
			pha
	+	pla
			txa
			clc
			adc #1
			and #3
			tax
			iny
			iny
			cpy ZPTemp
			bne -
			stx ZPTemp2
			lda #4
			sta TickDowns.playerAnim
_checkJoy
	lda TickDowns.doorAnim
	bne _noScroll
		lda #8
		sta TickDowns.doorAnim
		lda joyRight
		beq _notLeft
			lda GameData.musicMode
			sec
			sbc #64
		_saveNoMode
			and #128+64
			sta GameData.musicMode
			lda #<CRAMLinePos
			sta kVERA.ADDR_Lo
			lda #>CRAMLinePos
			sta kVERA.ADDR_Mid
			lda #`kVRAM.titleScreen|kVERA.inc_2 ; skip char data
			sta kVERA.ADDR_Hi
			lda #1
			ldy #38
		-	sta kVERA.DATA_0
			dey
			bpl -
			bit GameData.musicMode
			bpl _startMusic
				lda #0
				.byte $2c
		_startMusic
			lda #5
			jsr SID
			bra _noScroll
	_notLeft
		lda joyLeft
		beq _noScroll
			lda GameData.musicMode
			clc
			adc #64
			gra _saveNoMode
_noScroll
.endc ;}}}
	lda joyFire							; is fire pressed
	bne _exit							; no
		lda oldJoyFire					; was it pressed last frame
		beq _exit						; no, exit then
			inc PlayerData.state		; yes, fire was released and we need to start the game
			lda #kHideScreen.hide	; hide the screen. for DMA transfers and swaps
			sta HideScreen
_exit
	rts
; no password system or keyboard, left in case you wish to crib the password system logic
; again you can fold it in Relaunch64. the rts above wasn't there before
.comment ;{{{
	jsr $FF9F ; SCAN KEY
	jsr $FFE4 ; GETIN
	beq _noKey
		cmp #32
		beq _clear
			jsr convertASCIIToQwakChar
			ldy PasswordEntryIndex
			sta PasswordRAMCache,y
			tax
			cpy #12
			beq _noKey
		PasswordBaseScreenPos = getTitleScreenCharPos(TitleScreenData.PasswordBlank[1],TitleScreenData.PasswordBlank[2])
		tya
		asl a ; convert to 2 wide for screen
		clc
		adc #<PasswordBaseScreenPos
		sei
			stz kVERA.CTRL
			sta kVERA.ADDR_Lo
			lda #>PasswordBaseScreenPos
			adc #0
			sta kVERA.ADDR_Mid
			lda #`PasswordBaseScreenPos
			sta kVERA.ADDR_Hi
			stx kVERA.DATA_0
		cli
		inc PasswordEntryIndex
		lda PasswordEntryIndex
		cmp #12
		beq _checkPassword
_noKey
	cli
	rts
.endc ; }}}
	
; this has the password entry code, in Commander X16 form
; left for cribing if wanted
.comment ;{{{
_clear
	ldx #16
	jsr plotStringAAtIndexX
	stz PasswordEntryIndex
	stz ValidPassword
	gra _noKey
_checkPassword
	lda PasswordRAMCache,x
	pha
		jsr convertLetterToNumber
		sta ActivePassword,x
	pla
	jsr isValidLetter
	bcc _fail
		dex
		bpl _checkPassword
			; pass
			jsr extractPassword
			jsr validateExtractedPassword
			bcs _fail
				jsr unloadPasswordTemp
				lda #VIC.Colours.light_green
				_plotColourExit
				sei
					stz kVERA.CTRL
					ldx #<PasswordBaseScreenPos+1
					stx kVERA.ADDR_Lo
					ldx #>PasswordBaseScreenPos
					stx kVERA.ADDR_Mid
					ldx #`PasswordBaseScreenPos | kVERA.inc_2
					stx kVERA.ADDR_Hi
					ldx #11
				-
					sta kVERA.DATA_0
					dex
					bpl  -
				cli
				bra _noKey
_fail
	ldy #0
	jsr checkPasswordForCheat
	bcs _lives
		ldy #12
		jsr checkPasswordForCheat
		bcs _red
			ldy #24
			jsr checkPasswordForCheat
			bcs _spring
				ldy #36
				jsr checkPasswordForCheat
				bcs _levelSkip
_setTextRed
	lda #VIC.Colours.red
	bra _plotColourExit
_lives
	lda #1
	sta PasswordInfiLives
	bra _setTextRed
_red
	lda #1
	sta PasswordRedBullets
	bra _setTextRed
_spring
	lda #1
	sta PasswordHaveSpring
	bra _setTextRed
_levelSkip
	lda #1
	sta PasswordLevelSkip
	bra _setTextRed
checkPasswordForCheat
	ldx #0
-	lda PasswordRAMCache,x
	cmp PASSWORD_LIVES,y
	bne _fail
		inx
		iny
		cpx #12
		bne -
		;sec cmp above will set this already
		rts
_fail
	clc
	rts
.endc ;}}}


TSStartGame
_ASSERT_axy8
	lda LevelData.levelGraphicsSet	; get the current set of 4
	jsr dmaLevelChars_xx					; update the background/fruit characters etc
	#A16
	lda #<>GAMELOOP
	sta GameStatePointer					; set main FSM to game loop
	#A8
	jsr disableAllEntSprites_88		; clears OAM Mirror as well
	jsr plotStatusArea
	lda #kPlayerState.appear			; set the player state to appear
	sta PlayerData.state
	lda #kMus.THEME_1
	jsr playMusic
	rts

; ----- @Intermission loop@ -----

.as
.xs
INTERLOOP
_ASSERT_axy8
	jsr updateTickdowns_88
	lda PlayerData.state
	asl a
	tax
	jmp (InterFuncLUT,x)
InterFuncLUT .word <>(interSetUp,interMovePlayer,interEnterDoor)

.as
.xs
interSetUp
_ASSERT_axy8
	jsr PlotTransitionScreenAndMakeNextChars	; also set player index,exit index
	jsr setPlayerToSpawnPoint_88					; to the first spawn point as set in above function
	lda #kIntermission.firstExit
	sta LevelData.exitIndex							; set the door we want to animate
	lda #$FF
	sta LevelData.exitIndex+1						; set the end exit index to dummy value for logic tracking
	inc a													; a = 0
	jsr changePlayerDir								; make sure player is going right
	lda #1
	sta PlayerData.movingLRNZ
	sta PlayerData.OnGroundNZ						; we are moving and on the ground for anim purposes
	sta checkSpriteToCharData.xDeltaCheck		; move right
	stz CheckSpriteToCharData.xDeltaCheck.hi
	sta GameData.exitOpenNZ							; we want to close the door
	jsr setAnimateDoorToClose_88					; set the door to close
	lda #kSFX.DOORCLOSE
	jsr playSFX
	lda GameData.currLevel							; inc and wrap level number
	clc
	adc #1
	cmp #31												; 32 levels in 16K where we mad, probably
	bne +
		lda #0
+	sta GameData.currLevel
	jsr deactivateAllEntities						; don't want any stray sprites on screen
	jsr removePickups_88								; no flashing either
	inc PlayerData.state								; move to next walk state
;	jsr loadPasswordTemp								; this will make and show a password for the user
;	jsr makePassword									; disabled in this version but for cribbing
;		#appendVeraAddress getGameScreenCharPos(10,4) | kVERA.inc_1
;		ldx #11
;	-	lda ActivePassword,x
;		jsr convertToPasswordLetter
;		sta kVERA.DATA_0
;		stz kVERA.DATA_0 ; CRAM is 0
;		dex
;		bpl -
	rts

.as
.xs
interMovePlayer
_ASSERT_axy8
	ldx #0
	jsr addXWithMSBAndClip_88						; move player
	jsr updatePlayerAnim_88							; animate player
	jsr animateDoor_88								; animate the door
	lda mplexBuffer.xpos
	cmp #256-16											; are we just before the door?
	bcc +
		inc PlayerData.state							; move to enter door state
		lda #kPlayerAnimsIndex.exit				; start exit animation
		jsr setPlayerAnimeTo_88
		rts
		;
+	cmp #(11*16)										; are we in the middle?
	bne +
		jsr setAnimateDoorToOpen_88				; start opening the next door
		lda #kIntermission.secondExit
		sta LevelData.exitIndex						; set the door we want to animate
		lda #kSFX.DOOROPEN
		jsr playSFX
+	rts

.as
.xs
interEnterDoor
_ASSERT_axy8
	jsr updatePlayerAnim_88							; has the animation completed?
	bcc _exit
		lda GameData.currLevel						; we alternate level music
		ldx #size(BossLevels)-1						; so this checks if we are on a boss
	-	cmp BossLevels,x								; level and adjust the tune as needed
		beq _bossLevel
			dex
			bpl -
			and #1
			clc
			adc #1
			.byte $2c ; BIT XXXXX
	_bossLevel
		lda #kMus.BOSS
		jsr playMusic
	lda #kPlayerState.appear						; set player to appear
	sta PlayerData.state
	#A16
	lda #<>GAMELOOP
	sta GameStatePointer								; set the main FSM to Gameloop
	#A8
	lda #kHideScreen.hide							; hide the screen for transition and DMA
	sta HideScreen
_exit
	rts


; ----- @Game Over loop@ -----

gameOverLoop
_ASSERT_axy8
	lda PlayerData.state
	asl a
	tax
	jmp (GameOverFuncLUT,x)
GameOverFuncLUT .word <>(GOSetup,GOWaitForFire)

GoSetup
_ASSERT_axy8
	; print string
	ldx #len(TitleScreenData.AllStrings)*2	; this doesn't have Game Over in it, which is added after
	jsr plotStringAAtIndexXGameScreen		; so it's len is the index for Game Over
	inc PlayerData.state							; move to wait for firfe state
	; remove sprites
	jsr deactivateAllEntities					; we remove all the entites as well so you stand alone, and they don't move
	jsr disableAllEntSprites_88
	; check to see if this is the new high score
	ldx #0
-	lda GameData.score,x			; score is stored in most significant digit -> lowest significant digit
	cmp GameData.high,x
	beq _next						; if == next digit
	bcs _higher						; if >= new high score take it
		bra _clearScore			; thus < and just clear it no new high
_next
	inx
	cpx #size(sGameData.score)
	bne -
_clearScore
	ldx #size(sGameData.score)-2
	#A16
	lda #0
-	sta GameData.score,x
	dex
	dex
	bpl -
	#A8
	jsr dmaScreenMirror_xx		; update the actual screen. this is risky as I don't know I'm in Blank
	;rts								; explicity and I rely on the NMI being short and the DMA only being 2K
	lda #kMus.THEME_3				; on the SNES this eats a lot of time and I need the above to happen in vblank while this is better out of vblank
	jmp playMusic
	;
_higher
	ldx #size(sGameData.score)-2	; save the current score into the high score
	#A16
-	lda GameData.score,x
	sta GameData.high,x
	dex
	dex
	bpl -
	#A8
	jsr pltHighScore					; update the high score on the screen
	gra _clearScore

GOWaitForFire
_ASSERT_axy8
	;wait for fire
	lda joyFire									; if !fire && oldFire
	bne _exit									; aka fire released
		lda oldJoyFire
		beq _exit
			; got to Title Screen State
			stz PlayerData.state				; first minor FSM state
			#A16
			lda #<>titleScreenLoop
			sta GameStatePointer				; move main FSM to titlescreen
			#A8
_exit
	rts

; ----- @Misc functions@ -----

; these are the inital timer load values
kTimers .block
	dissBlocksValue = $8
	floatTimer = $50
	DoorAnimeRate = 10
	spawnBubble = 30
.bend

.as
.xs
updateTickdowns_88
_ASSERT_jsr
_ASSERT_axy8
	ldx #TICK_DOWN_END - TICK_DOWN_START-1
_l	lda TickDowns,x		; if !0 
	beq _next
		dec TickDowns,x	; timer--
_next
	dex
	bpl _l
	rts

.as
.xs
scanJoystick_88
; so this is a SNES and its a Pad, but historic reasons joystick.
_ASSERT_jsr
_ASSERT_axy8
	; copy the current state to the old state
	ldx #4
-	lda joyLeft,x
	sta oldJoyLeft,x
	stz joyLeft,x
	dex
	bpl -
	; read in the new state
	; this uses an odd method of slide the bit out and branching
	; its somewhat fast but also compresses really well
	; most snes games keep the bit flags in one word
	; this works alright on a NES where RAM is precious
	; on the C64 RAM is RAM so any trade off in code size vs data size
	; is good either way
	; the SNES.. we ample ROM and ample RAM so up to the style
	; for single input checks this is tighter but for button combinations
	; its more expensive, so it depends on what your game does
	; also SNES pad is active low
	; SNES auto read inverts it to make it active high
	ldx #1
	lda $804219			;JOY1H
	lsr a					;right
	bcs _joyRight
		lsr a				; left
		bcs _joyLeft
_checkUD
	lsr a					; down
	bcs _joyDown
		lsr a				; up
		bcs _joyUp
_checkFire
	lsr a					; start
	lsr a					; select
	lsr a					; Y
	bcs _joyY
_checkB
	lsr a					; B
	bcc _joyEnd
		stx joyUp
_joyEnd
	lda oldJoyUp		; old up			0011
	eor joyUp			; eor new up	0101
	and joyUp			; and up			0101
	sta joyUpStart		;					0100

	lda joyUp			; up				0011
	eor OldJoyUp		; eor old up	0101
	and OldJoyUp		; and old up	0101
	sta joyUpStop		;					0100

	lda oldJoyFire
	eor joyFire
	and joyFire
	sta joyFireEvent
	rts

_joyUp
	stx joyUp
	gcs _checkFire

_joyY
	stx joyFire
	gcs _checkB

_joyDown
	stx joyDown
	lsr a				; skip up bit
	bra _checkFire

_joyLeft
	stx joyLeft
	gcs _checkUD

_joyRight
	stx joyRight
	lsr a				; skip left bit
	bra _checkUD

.as
.xs
addXWithMSBAndClip_88
_ASSERT_jsr
_ASSERT_axy8
; we do wrap on the screen so we need to clip for 0-256
; so I do it in 16bit mode, now if the upper byte is $ff then we are 
; negative and went under, which is a branch minus
; then we need to check if we are over 256-16 as the sprite is 16 wide
; if we go under we clip to 0, if we go over we clip to 256-16
	stz DidClipX										; not clipped yet
	lda mplexBuffer.xpos,x							; read the X
	#A16
	and #$00ff											; make sure
	clc
	adc CheckSpriteToCharData.xDeltaCheck
	bmi _wentUnder
		cmp #$100-16
		bcc _justStore
			; went over
			inc DidClipX
			lda #$100-16
			bra _justStore
_wentUnder
	inc DidClipX
	lda #0
_justStore
	#A8
	sta mplexBuffer.xpos,x
	rts


.as
.xs
ClipY
_ASSERT_jsr
_ASSERT_axy8
; now Y the screen is only 224 high, while you could just use 256 and "let it happen" it will give a large delay
; but we also have a hud, the game screen is only 192 high with 32 pixels of HUD. So when you go off the top you should 
; be moved closer to the bottom of the hud and when you fall off below the hud you should "warp" off the top
	cmp #208			; 192 + sprite height
	bcs +
		rts			; 0 - 192 = safe 192-208 = shared 16 off screen
+	cmp #240			; if 208 < y < 240 then we have fallen off the bottom
	bcc _bottomOfScreen
		; top of screen
		lda #193		; move to just below the HUD
		rts
_bottomOfScreen
	lda #-16			; warp to being 16 pixels off the "top" 
	rts

.as
.xs
giveScore
_ASSERT_jsr
_ASSERT_axy8
	asl a
	asl a
	asl a							; x8 while scores are 6 bytes long x6 is more trouble than wasting 2 bytes per score
	ora #5						; move to the last digit
	tay							; stash in Y for indexing - LUT would be quicker and smaller looking at it now
	ldx #5						; for 6 digits starting at LSD
	clc							; clear initial C
_scLoop
	lda GameData.score,x
	adc FruitScore,y
	sta GameData.score,x		; score[x++] += points[y++]
	cmp #10						; digit overflow
	bcc _ok
		;sec
		sbc #10					; restore to 0-9
		sta GameData.score,x
		sec						; add 1 more next time
_ok
	dey
	dex
	bpl _scLoop
	jmp pltScore

;index for scores
kScoreIndex .block
	fruit = 0
	flower = 1
	key = 2
	boss = 3
.bend

FruitScore	.byte 0,0,0,1,0,0,15,15
FlowerScore .byte 0,0,0,5,0,0,15,15
KeyScore		.byte 0,0,0,2,5,0,15,15
BossScore	.byte 0,1,0,0,0,0,15,15

.as
.xs
PlotTransitionScreenAndMakeNextChars
_ASSERT_jsr
_ASSERT_axy8
		jsr clearMapInScreenMirror				; clear just the map, leaving the HUD "as is"
		; we need to copy in the current wall char elsewhere
		lda #0
		xba
		lda LevelData.levelGraphicsSet		; this is the "current levels" set at this point
		#AXY16											; DMA 16bit to avoid the pain ;)
		asl a
		tax
		lda WallCharLUT,x							; set the DMA source address based upon the set we want
		sta $804302
		#A8
		lda #`BackShadowChars
		sta $804304
		 
		ldx #4*8*4									; we want to do 4 chars
		stx $804305
		ldx #%00000001 | $1800					; A->B, Inc, Write WORD, $2118
		stx $804300
		ldx #kVRAM.gameChars+(124*4*8/2)		; write them to char num 124-127
		stx $802116									; 4 bytes per line, for 8 lines per char
		lda #$80										; but value is a word address so div 2
		sta $802115									; inc VRAM port address
		lda #1
		sta $80420B									; fire
		#XY8
		; now we need to draw the first floor half
		lda #kIntermission.firstExit			; move to the start position
		sta ActiveTileIndex
		sta LevelData.playerIndex				; we start at the first door
		lda #kDoorOpen
		jsr pltSingleTileNoLookup				; first door is open
		lda #kIntermission.secondExit
		sta ActiveTileIndex
		sta LevelData.exitIndex					; and leave on the second one
		lda #kDoorClosed
		jsr pltSingleTileNoLookup				; second door is closed
		ldx #(kTileXCount/2)-1					; draw half a screens worth of the 'old' tile which was chached
_firstLoop
		phx											; preserve X
			inc ActiveTileIndex					; move to the next tile
			lda #kTiles.intermissionOldWall	; cached wall "block" num
			jsr pltSingleTileNoLookup			; plot the value raw without doing a level -> screen tile lookup
		plx											; restore X
		dex
		bpl _firstLoop								; until done

		jsr incLevelGraphicSet					; move to the next levels set
		jsr dmaLevelChars_xx						; install the chars to VRAM

		ldx #(kTileXCount/2)-1					; draw the second half of the screen
_secondLoop
		phx
			inc ActiveTileIndex
			lda #kTiles.wall
			jsr pltSingleTile
		plx
		dex
		bpl _secondLoop
		rts

kEmptyTileNum = 47
ClearEmptyTile .byte kEmptyTileNum	; for a fixed DMA

.as
.xs
clearScreenMirrorToEmptyChar
_ASSERT_jsr
_ASSERT_axy8
	php
		#A16				; DMA so 16bit values again
		lda #32*32*2	; whole screen
		sta $804305
		jmp clearScreenMirrorCommon_16x

.as
.xs
clearMapInScreenMirror
_ASSERT_jsr
_ASSERT_axy8
	php
		#A16				; DMA so 16 bit values again
		lda #kTileXCount*kTileYCount*4*2 ; just the map
		sta $804305
		; fall through
clearScreenMirrorCommon_16x
_ASSERT_a16
		lda #$8008	  ; A -> B, FIXED SOURCE, WRITE BYTE | WRAM
		sta $804300
		lda #<>ClearEmptyTile
		sta $804302
		lda #`ClearEmptyTile
		sta $804304
		lda #<>ScreenMirror
		sta $802181
		lda #>`ScreenMirror
		sta $802182
		lda #$0001
		sta $80420B	 ; FIRE DMA
	plp
	rts

; this points to the point of the complete floor tile in the BackShadowChar data
WallCharLUT .block
	_offset = 16*4*8				; we are interested in 16th,17th,18th and 19th chars
	_values = BackShadowChars + range(4)*(size(BackShadowChars)/4) + _offset
	.word <>(_values)
.bend


; these string functions have two entry points as they needed different CRAM values for when you draw them.
; on the SNES I can't be bothered and the GAME OVER text has a black background and not a brown one :P
; left for historic puposes or if you wish to correct this oversite. 
.as
.xs
plotStringAAtIndexXGameScreen
_ASSERT_jsr
_ASSERT_axy8
	stz ZPTemp2
	bra psaaixCommon
.as
.xs
plotStringAAtIndexX
_ASSERT_jsr
_ASSERT_axy8
	stz ZPTemp2
psaaixCommon
	; to do this I use the WRAM port to the screen mirror, this is to contrast 
	; to other functions where I use indrect long.
	#A16
	ldy #`ScreenMirror
	sty $802183 								; this is most probably a zero but to be "safe" do it this way
	lda TitleScreenData.stringPos,x
	sta $802181
	ldy TitleScreenData.string,x
	lda StringTableLUT,y						; load up the strings data src pointer
	sta Pointer1
	#A8
	ldy #0
-	lda (Pointer1),y							; read char
	cmp #$ff										; is it the terminator
	beq _done
		sta $2180								; write to the WRAM port, which auto incs
		lda ZPTemp2								; this holds the artributes we want
		sta $2180								; write it too
		iny										; next char
		bra -
_done
	rts

; ----- @Hud@ -----

kSBC .block ; kStatusBorderChars
	M	= 205
	TL	= 203+3
	T	= 204+3
	TR	= 206+3
	L	= 205+3
	R	= 207+3
	BL	= 250
	B	= 251
	BR	= 252
	QWAKT = 208+3
	QWAKB = 214+3
	Score = 220+3
	High = 226+3
	QwakP = 232
	X = 204
	Flower = 236
	Digits = 240
.bend

kStatusAttributes = %00100000 ; PAL 0 no flips but higher priority
fGetMemoryForScreenChar .function base,x,y
.endf base + ( y*32*2 ) + ( x*2 )

.as
.xs
plotStatusArea
_ASSERT_jsr
_ASSERT_axy8
; we need to draw the bottom 4 rows, its 245 bytes vs 32*2*4 = 256 so 11 bytes smaller
; but also it doesn't need a tool ;)
; for this is use indrect long rather than WRAM port as an example of the mode and its uses
; port would be smaller and fast though.
	_statusStart = fGetMemoryForScreenChar(ScreenMirror,0,24)
	#A16
	lda #<>_statusStart
	sta ZPLong.loword
	#A8
	lda #`_statusStart				; set the ZPLong to the start
	sta ZPLong.bank					; of the hud in screen mirror
	lda #kStatusAttributes			; set up the high byte
	xba
	; draw top row
	ldy #0
	lda #kSBC.TL						; this is a top corner piece, 30 tops peieces, then another corner
	jsr plotStatusCharToZPLong
	ldx #29 ; draw 30
-	lda #kSBC.T
	jsr plotStatusCharToZPLong
	dex
	bpl -
	lda #kSBC.TR
	jsr plotStatusCharToZPLong
	; draw second row
	lda #kSBC.L
	jsr plotStatusCharToZPLong
		; draw the SCORE text
	ldx #kStatusRanges.Score
	jsr plotStatusRangeY
		; skip score digits
	tya
	clc
	adc #12 ; 6 chars
	tay
		; draw empty char
	jsr plotEmptyStatusCharToZPLong
		; draw top of QWAK
	ldx #kStatusRanges.QWAKT
	jsr plotStatusRangeY
		; draw empty char
	jsr plotEmptyStatusCharToZPLong
		; draw top of QWAK
	lda #kSBC.QwakP
	jsr plotStatusCharToZPLong
	lda #kSBC.QwakP+1
	jsr plotStatusCharToZPLong
		; draw 3 banks
	jsr plot3EmptyStatusCharToZPLong
		; draw top of Flower
	lda #kSBC.Flower
	jsr plotStatusCharToZPLong
	lda #kSBC.Flower+1
	jsr plotStatusCharToZPLong
		; draw 3 blanks
	jsr plot3EmptyStatusCharToZPLong
		; draw right edge
	lda #kSBC.R
	jsr plotStatusCharToZPLong
	; draw third row
	lda #kSBC.L
	jsr plotStatusCharToZPLong
	jsr plotEmptyStatusCharToZPLong
		; draw HIGH text
	ldx #kStatusRanges.High
	jsr plotStatusRangeY
	lda #kSBC.High
	jsr plotStatusCharToZPLong
	jsr plotEmptyStatusCharToZPLong
		; skip high score digits
	tya
	clc
	adc #12
	tay
	jsr plotEmptyStatusCharToZPLong
		; draw bottom half of qwak logo
	ldx #kStatusRanges.QWAKB
	jsr plotStatusRangeY
	jsr plotEmptyStatusCharToZPLong
		; draw bottom half of qwak
	lda #kSBC.QwakP+2
	jsr plotStatusCharToZPLong
	lda #kSBC.QwakP+3
	jsr plotStatusCharToZPLong
	lda #kSBC.X
	jsr plotStatusCharToZPLong
	jsr plot2EmptyStatusCharToZPLong ; this is the digit but not worth skipping
		; plot lower half of flower
	lda #kSBC.Flower+2
	jsr plotStatusCharToZPLong
	lda #kSBC.Flower+3
	jsr plotStatusCharToZPLong
	lda #kSBC.X
	jsr plotStatusCharToZPLong
	jsr plot2EmptyStatusCharToZPLong ; this is the digit but not worth skipping
	lda #kSBC.R
	jsr plotStatusCharToZPLong
	; draw forth row
	lda #kSBC.BL
	jsr plotStatusCharToZPLong
	ldx #29 ; draw 30
-	lda #kSBC.B
	jsr plotStatusCharToZPLong
	dex
	bpl -
	lda #kSBC.BR
	jsr plotStatusCharToZPLong
	jsr pltScore
	jsr pltHighScore
	jsr pltLives
	jmp pltFlowers
	rts

kStatusRanges .block
	Score = 0
	QWAKT = 1
	High = 2
	QWAKB = 3
.bend

StatusRangePairs  := ((kSBC.Score, kSBC.Score+6),)
StatusRangePairs ..= ((kSBC.QWAKT, kSBC.QWAKT+6),)
StatusRangePairs ..= ((kSBC.High,  kSBC.High+3),)	; the H needs manual repeating
StatusRangePairs ..= ((kSBC.QWAKB, kSBC.QWAKB+6),)

StatusRangePairsLUT .block
	start .byte StatusRangePairs[:,0]
	end .byte StatusRangePairs[:,1]
.bend

plotStatusRangeY
_ASSERT_jsr
_ASSERT_axy8
; this take a index into the table and draw the char until the last char spec'd in the table
	lda StatusRangePairsLUT.end,x
	sta ZPTemp
	lda StatusRangePairsLUT.start,x
	tax
-	txa
	jsr plotStatusCharToZPLong
	inx
	cpx ZPTemp
	bne -
	rts

plot3EmptyStatusCharToZPLong
_ASSERT_jsr
_ASSERT_axy8
	jsr plotEmptyStatusCharToZPLong
plot2EmptyStatusCharToZPLong
	jsr plotEmptyStatusCharToZPLong
plotEmptyStatusCharToZPLong
	lda #kSBC.M
plotStatusCharToZPLong
	#A16
	sta [ZPLong],y
	iny
	iny
	#A8
	rts

pltScore
_ASSERT_jsr
_ASSERT_axy8
_statusScore = fGetMemoryForScreenChar(ScreenMirror,7,25)	; location in screen mirror for the score
	#A16
	lda #<>_statusScore
	sta ZPLong.loword
	#A8
	lda #`_statusScore
	sta ZPLong.bank				; set ZP long
	lda #kStatusAttributes			; set up the high byte
	xba
	ldy #0
	ldx #0
-	lda GameData.score,x			; get the score digits
	ora #kSBC.Digits				; convert from 0-9 to the 0-9chars (the needs them to be aligned on a 16 boundary)
	jsr plotStatusCharToZPLong	; draw digit
	inx
	cpx #6							; do all 6
	bne -
	rts

pltHighScore
_ASSERT_jsr
_ASSERT_axy8
_statusHScore = fGetMemoryForScreenChar(ScreenMirror,7,26)	; location in screen mirror for the score
	#A16
	lda #<>_statusHScore
	sta ZPLong.loword
	#A8
	lda #`_statusHScore
	sta ZPLong.bank
	lda #kStatusAttributes		; set up the high byte
	xba
	ldx #0
	ldy #0
_l	lda GameData.high,x			; see above
	ora #kSBC.Digits
	jsr plotStatusCharToZPLong
	inx
	cpx #6
	bne _l
	rts

pltLives
_ASSERT_jsr
_ASSERT_axy8
_statusLives = fGetMemoryForScreenChar(ScreenMirror,24,26)
	#A16
	lda #<>_statusLives
	sta ZPLong.loword
	#A8
	lda #`_statusLives
	sta ZPLong.bank
	lda #kStatusAttributes		; set up the high byte
	xba
	lda GameData.lives		; get the lives
	ora #kSBC.Digits
	cmp #kSBC.Digits+10		; clip it to max show 9
	bcc _safe
		lda #kSBC.Digits+9
_safe
	ldy #0
	jmp plotStatusCharToZPLong
	;rts

pltFlowers
_ASSERT_jsr
_ASSERT_axy8
_statusFlowers = fGetMemoryForScreenChar(ScreenMirror,29,26)
	#A16
	lda #<>_statusFlowers
	sta ZPLong.loword
	#A8
	lda #kStatusAttributes		; set up the high byte
	xba
	lda #`_statusFlowers
	sta ZPLong.bank
	lda GameData.flowers
	ora #kSBC.Digits				; flowers can only be 1-8 anyway
	ldy #0
	jmp plotStatusCharToZPLong
	;rts

; ----- @Sprite Engine@ -----

dmaOAM_xx					; copy all of OAM mirror -> OAM Ram in PPU
_ASSERT_JSR
	php						; save the current register sizes
		#XY16
		#A8
		stz $802102			; OAM is zero
		stz $802103			; A is 8bits ldx #0000 stx ABS is slower
		ldx #$0400			; A -> B, INC, Write BYTE | OAM
		stx $804310
		ldx #<>OAMMirror	; THIS GET THE LOW WORD, YOU WILL NEED TO CHANGE IF NOT USING 64TASS
		stx $804312
		ldx #$207E			; We want bank 7e and we are trasfereing 512+32 bytes
		stx $804314
		lda #$02
		sta $804316
		sta $80420B			; DMA channel 1 saves a load
	plp
	rts

kSpriteEmptyVal = 224
SpriteEmptyVal .byte kSpriteEmptyVal
SpriteUpperEmpty .byte $55

.as
.xs
disableAllEntSprites_88
_ASSERT_jsr
_ASSERT_axy8
; this sets all sprites to off screen
	#A16
	lda #kSpriteEmptyVal<<8|kSpriteEmptyVal
	ldx #mplex.kMaxSpr-2
-	sta mplexBuffer.ypos,x
	sta mplexBuffer.xpos,x
	dex
	dex
	bne -
	#A8
	; fall through
clearSpritesMirror_xx
_ASSERT_JSR
	php											; save register size
		#XY16
		#A8
		; Do Main 256 words
		ldx #$8018								; A -> B, FIXED SOURCE, WRITE BYTE | WRAM
		stx $804310
		ldx #<>SpriteEmptyVal				; THIS GET THE LOW WORD, YOU WILL NEED TO CHANGE IF NOT USING 64TASS
		stx $804312
		ldx #`SpriteEmptyVal					; THIS GETS THE BANK, YOU WILL NEED TO CHANGE IF NOT USING 64TASS
		stx $804314								; AND THE UPPER BYTE WILL BE 0
		ldx #<>OAMMirror
		stx $802181
		stz $802183								; START AT OAM MIRROR
		lda #2
		sta $804316								; DO 512 BYTES
		sta $80420B								; FIRE DMA
		; Do upper 16 words
		;	ldx #$8018							; A -> B, FIXED SOURCE, WRITE BYTE | WRAM
		;	stx $804310
		ldx #<>SpriteUpperEmpty				; THIS GET THE LOW WORD, YOU WILL NEED TO CHANGE IF NOT USING 64TASS
		stx $804312
		ldx #(32<<8)|`SpriteUpperEmpty	; THIS GETS THE BANK, YOU WILL NEED TO CHANGE IF NOT USING 64TASS
		stx $804314								; AND THE UPPER BYTE WILL BE 32
		stz $804316								; DO 32 BYTES
		;	ldx #<>OAMMirrorHigh
		;	stx $802181							; IF THIS IS DIRECTLY AFTER LO, WRAM ALREADY POINTS TO IT
		;	stz $802183							; START AT HIGH
		;	lda #$02
		sta $80420B								; FIRE DMA
	plp											; restore register size
	rts

.as
.xs
updateAllSpriteXYsToOAMMirror_88
_ASSERT_jsr
_ASSERT_axy8
	jsr clearSpritesMirror_xx
	; handle the player which has special cases
	jsr setPlayerSpritePtrFromFrameNumber_88
	stz ZPTemp
	ldx PlayerData.currAnim
	ldy #0
	lda PlayerFrameData.animXOffset,x
	sta Pointer1.lo
	bpl +											; do we need to sign extend ?
		dey										; yes - 255
+	sty Pointer1.hi
	lda mplexBuffer.xpos						; get any X offset for this anim
	#a16											; 9 bit maths sucks, and as we have 16bit trust me USE IT
	and #$ff										; make sure its the 8bit value we expect
	clc
	adc Pointer1								; offset the Xpos
	#a8
	sta OAMMirror								; store the offset X
	sta OAMMirror+4							; set the lower sprite in case
	xba
	beq +											; have we overflown ?
		lda #%00000101							; set the XMSB bit then
		sta ZPTemp
+	lda mplexBuffer.ypos
	dec a											; adjust for sprites being 1 below given y on SNES
	sta OAMMirror+1
	clc
	adc #16										; prep y + 16 in case
	ldx PlayerData.currAnim
	ldy PlayerFrameData.sizes,x			; do we have a dual sprite?
	ldx #%01010000								; 2 sprites small
	cpy #kSpriteType.s16x32
	beq +											; yes store the +16 y
		ldx #kSpriteEmptyVal					; no set 2nd sprite offscreen
		stx OAMMirror+4
		ldx #%01010100							; 1 sprite small
		cpy #kSpriteType.s32x32
		bne +
			ldx #%1010110						; 1 sprite large
+	sta OAMMirror+5
	txa
	ora ZPTemp									; set the X-MSB if needed
	sta OAMMirrorHigh
	; next add the bullet, if needed
	lda PlayerData.bulletActive
	beq _noBullet
		; either way the bullet is a 16x16 sprite
		lda mplexBuffer.xpos+kBulletSpriteOffset
		sta OAMMirror+8
		lda mplexBuffer.ypos+kBulletSpriteOffset
		sta OAMMirror+9
		lda OAMMirrorHigh
		and #%11001111
		sta OAMMirrorHigh	; clear the X MSB for bullet, so you can see it
		bra _bulletTile
		;
_noBullet
	lda #kSpriteEmptyVal
	sta OAMMirror+8		; make sure the bullet is offscreen
	sta OAMMirror+9
_bulletTile
	ldx bulletFrame		; we set the frame, either way doesn't matter
	#A16
	lda PlayerBulletAnimData,x
	sta OAMMirror+10 ;11
	#A8
		; now add the entities
	ldx #kEntity.maxEntities-1
	stx ZPTemp
_EntLoop
	ldx ZPTemp
	lda EntityData.active,x						; if allive
	beq _notActive
		ldy EntityData.type,x					; get the type
		lda EntityAnimData.frameSize,y		; dispatch for the ent type size
		asl a
		tax
		jsr (ENTSpriteDispatchLUT,x)
_notActive
	dec ZPTemp
	bpl _EntLoop
	rts

ENTSpriteDispatchLUT	.word <>(Ent16_16,Ent16_32,Ent32_32)

EntSpriteConvertToOAMIndex
_ASSERT_axy8
	lda ZPTemp					; get the current ent number
	tax							; cache it
	clc
	adc #kEntsSpriteOffset	; offset by the start of ent sprites
	asl a
	asl a							; each ent is allocated upto 2 sprites, 4 bytes per sprite
	asl a							; x8 to convert ent number to OAM byte offset
	tay							; y is now the OAM index
	rts

Ent16_16
_ASSERT_axy8
	jsr EntSpriteConvertToOAMIndex
	lda mplexBuffer.xpos+kEntsSpriteOffset,x
	sta OAMMirror,y			; set X
	lda mplexBuffer.ypos+kEntsSpriteOffset,x
	dec a							; adjust for SNES drawing sprites 1 lower than set value
	sta OAMMirror+1,y			; set Y
	lda #kSpriteEmptyVal		; set 2nd sprite off screen
	sta OAMMirror+4,y
	sta OAMMirror+5,y
	lda EntityData.palleteOffset,x
	sta ZPTemp2					; while X is still ent index, cache pallete offset
	lda EntityData.animBase,x
	clc
	adc EntityData.animFrame,x
	tax							; x is now the EntityFrameData index
	lda EntityFrameData.lo,x
	sta OAMMirror+2,y			; set Sprite number
	lda EntityFrameData.hi,x
	clc
	adc ZPTemp2					; the cached palleteOffset
	sta OAMMirror+3,y			; set Attributes
	; update the high flags
	jsr entSpriteUpdateUpperFlagsGetIndexes
	lda OAMMirrorHigh,y
	and EntUpperANDMask,x
	ora Ent16_16_ORVal,x
	sta OAMMirrorHigh,y
	rts

Ent16_32
_ASSERT_axy8
	jsr EntSpriteConvertToOAMIndex
	lda mplexBuffer.xpos+kEntsSpriteOffset,x
	sta OAMMirror,y
	sta OAMMirror+4,y			; set both X's
	lda mplexBuffer.ypos+kEntsSpriteOffset,x
	dec a
	sta OAMMirror+1,y			; set top Y
	clc
	adc #16						; offset to bellow
	sta OAMMirror+5,y			; set bottom Y
	lda EntityData.palleteOffset,x
	sta ZPTemp2
	lda EntityData.animBase,x
	clc
	adc EntityData.animFrame,x
	tax							; is now the EntityFrameData index
	lda EntityFrameData.lo,x
	sta OAMMirror+2,y			; set first sprite
	clc
	adc #32						; offset to the tile bellow
	sta OAMMirror+6,y			; set second sprite
	php							; save the C from the ADC
		lda EntityFrameData.hi,x
		clc
		adc ZPTemp2				; offset, by the potential pallete offset
		sta OAMMirror+3,y
	plp							; restore the C from the next sprite tile adc
	adc #0						; add the C 
	sta OAMMirror+7,y			; store the bottom sprite attributes and tile MSB
	; update the high flags
	jsr entSpriteUpdateUpperFlagsGetIndexes
	lda OAMMirrorHigh,y
	and EntUpperANDMask,x
	ora Ent16_32_ORVal,x
	sta OAMMirrorHigh,y
	rts

Ent32_32
_ASSERT_axy8
	jsr EntSpriteConvertToOAMIndex				; this is identical to 16_16 except different flags at the end
	lda mplexBuffer.xpos+kEntsSpriteOffset,x	; I've not pulled this out into a function to make it easier to understand
	sta OAMMirror,y									; the 16x16 function.
	lda mplexBuffer.ypos+kEntsSpriteOffset,x
	dec a
	sta OAMMirror+1,y
	lda #kSpriteEmptyVal
	sta OAMMirror+4,y
	sta OAMMirror+5,y
	lda EntityData.palleteOffset,x
	sta ZPTemp2
	lda EntityData.animBase,x
	clc
	adc EntityData.animFrame,x
	tax													; is now the EntityFrameData index
	lda EntityFrameData.lo,x
	sta OAMMirror+2,y
	lda EntityFrameData.hi,x
	clc
	adc ZPTemp2
	sta OAMMirror+3,y
	; update the high flags
	jsr entSpriteUpdateUpperFlagsGetIndexes
	lda OAMMirrorHigh,y
	and EntUpperANDMask,x
	ora Ent32_32_ORVal,x
	sta OAMMirrorHigh,y
	rts

entSpriteUpdateUpperFlagsGetIndexes
	ldx ZPTemp											; this holds the entity number
	lda mplexBuffer.xmsb+kEntsSpriteOffset,x	; do we have MSB set?
	php													; save Zero status
		txa
		lsr a												; ents have two sprites and the upper holds 4 sprites
		inc a												; so upper OAM mirrror byte is ent num / 2 + 1 to skip
		tay												; to skip the plyaer + bullet sprite set
		txa
		and #1											; x is now if sprite is even or odd number
		tax												; i.e which half of the upper byte mirror it uses
	plp													; restore "if 0"
	beq _noMSB
		txa
		clc
		adc #2 ; offset into MSB masks			; offset the index by 2 to access the MSB set versions
		tax
_noMSB
	rts


						;		normal				 | XMSB
EntUpperANDMask	.byte %11110000,%00001111,%11110000,%00001111
Ent16_16_ORVal		.byte %00000100,%01000000,%00000110,%01100000
Ent16_32_ORVal		.byte %00000000,%00000000,%00000101,%01010000
Ent32_32_ORVal		.byte %00000110,%01100000,%00000111,%01110000


; ----- @DMA functions@ -----

dmaPalletes_XX
_ASSERT_JSR
	php
		#A8									; DMA the Charset pallete which is 16 colours to slot 0
		#XY16
		ldx #<>CharPallete
		stx $804302
		lda #`CharPallete
		sta $804304
		ldx #32
		stx $804305
		ldx #%00000010 | $2200			; A->B, Inc, Write 2 Bytes, $2122
		stx $804300
		stz $802121							; start of Pallete
		lda #1
		sta $80420B
		ldx #<>SpritePallete				; Sprite palletes which is 48 colours to slot 8-10
		stx $804302
		lda #`SpritePallete
		sta $804304
		ldx #32*3							; copy 3 palletes worth
		stx $804305
		lda #128								; start of Sprite Pallete
		sta $802121
		lda #1
		sta $80420b
	plp
	rts

dmaLevelChars_xx
_ASSERT_JSR
	php
		#AXY16								; this copies the per level chars
		and #$ff								; to be sure
		asl a
		tax
		lda LevelCharsLUT,x
		sta $804302
		#A8
		lda #`BackShadowChars
		sta $804304
		ldx #size(BackShadowChars)/4	; we have 4 sets
		stx $804305
		ldx #%00000001 | $1800			; A->B, Inc, Write WORD, $2118
		stx $804300
		ldx #kVRAM.gameChars
		stx $802116
		lda #$80
		sta $802115							; inc VRAM port address
		lda #1
		sta $80420B
	plp
	rts

dmaFixedChars_xx
_ASSERT_JSR
	php
		#A8									; this dma's the fixed chars for the game
		#XY16									; the locations and splits are "historic reasons"
		ldx #<>FixedSectionChars
		stx $804302
		lda #`FixedSectionChars
		sta $804304
		ldx #size(FixedSectionChars)
		stx $804305
		ldx #%00000001 | $1800			; A->B, Inc, Write WORD, $2118
		stx $804300
		ldx #kVRAM.gameChars+(52*16)
		stx $802116
		lda #$80
		sta $802115							; inc VRAM port address
		lda #1
		sta $80420B
		; the font
		ldx #<>Font4BPP
		stx $804302
		lda #`Font4BPP
		sta $804304
		ldx #size(Font4BPP)
		stx $804305
		ldx #kVRAM.gameChars+(128*16)
		stx $802116
		lda #1
		sta $80420B
		; the fixed upper chars
		ldx #<>TopFixedChars
		stx $804302
		lda #`TopFixedChars
		sta $804304
		ldx #size(TopFixedChars)
		stx $804305
		ldx #kVRAM.gameChars+(192*16)
		stx $802116
		lda #1
		sta $80420B
		; lets just do the sprites while we are here
		ldx #<>SpritesChars
		stx $804302
		lda #`SpritesChars
		sta $84304
		ldx #size(SpritesChars)
		stx $804305
		ldx #kVRAM.Sprite
		stx $802116
		lda #1
		sta $80420B
	plp
	rts

dmaScreenMirror_xx
_ASSERT_JSR
	php
		#XY16							; this put the screen mirror to the main game screen VRAM location
		ldx #<>ScreenMirror		; this and the next function could be split to pull out the size 
		stx $804302					; but I couldn't be bothered... 
		#A8
		lda #`ScreenMirror
		sta $804304
		ldx #2048					; screen in 2K
		stx $804305
		ldx #%00000001 | $1800	; A->B, Inc, Write WORD, $2118
		stx $804300
		ldx #kVRAM.gameScreen
		stx $802116
		lda #$80
		sta $802115					; inc VRAM port address
		lda #1
		sta $80420B
	plp
	rts

dmaScreenMirrorToTitleScreen_xx
_ASSERT_JSR
	php
		#XY16							; same as above just its TS screen for the destination
		ldx #<>ScreenMirror
		stx $804302
		#A8
		lda #`ScreenMirror
		sta $804304
		ldx #2048					; screen in 2K
		stx $804305
		ldx #%00000001 | $1800	; A->B, Inc, Write WORD, $2118
		stx $804300
		ldx #kVRAM.titleScreen
		stx $802116
		lda #$80
		sta $802115					; inc VRAM port address
		lda #1
		sta $80420B
	plp
	rts

; this builds a table of the start indexs in the BackShadowChars binary blob that
; holds each "set", which there are 4 so each set size is total size/4
LevelCharsLUT
	- = BackShadowChars + range(4)*(size(BackShadowChars)/4)
	.word <>(-)

; ----- @Map routines@ -----
.section sLoWRAM
ScreenMirror .fill 2048		; this is used to hold the screen before DMA
.send ; sLoWRAM
.section sDP
ScreenUpdateRequiredN0 .byte ?
.send ; sDP

.as
.xs
plotTileMap_88
_ASSERT_jsr
_ASSERT_axy8
	#A16
	lda #<>tileMapTemp
	sta Pointer1					; pointer 1 holds pointer to the active level data
	lda #<>ScreenMirror
	sta ZPLong.loword
	#A8
	lda #`ScreenMirror
	sta ZPLong.bank				; ZPLong holds the "screen" pointer

	lda #kDoorClosed				; we are plotting the map so take this
	sta LevelData.exitFrame		; time to ensure door is closed

	; to keep the index's free and so I can use all any 'ZPTemps' in sub functions 
	; wihtout fear, I store the counters on the stack
	lda #kTileYCount				; num rows
	pha								; save row counter
_pltY	
		ldy #00						; num cols
		phy							; save the column counter
_pltX		lda (Pointer1),y		; tile num
			tax
			lda toolToTileLUT,x	; convert map to actual tile
			jsr renderTile_88		; plot it
			#A16Clear
			lda ZPLong.loword
			adc #4
			sta ZPLong.loword		; advance screen pointer 2 tiles to the right
			#A8
		ply							; restore column counter
		iny							; inc it
		phy							; save it again ready for the next loop
			cpy #kTileXCount		; have we done the row
			bne _pltX				; no, next
		pla							; counter will be on stack so remove
		#A16Clear
		lda Pointer1.lo			; advance the map data pointer to the next row
		adc #kTileXCount
		sta Pointer1.lo
		#A8
	pla								; restore the rows counter
	sec
	sbc #1							; count down
	beq _exit						; done ?
	pha								; save it back on the stack
		#A16Clear
		lda ZPLong.loword			; we have to offset the screen position to the next "row"
		adc #128-64					; each row is 32 chars, which is words so 64 bytes
		sta ZPLong.loword			; and we have 2 rows which is 128 bytes, we are already 1 row over
		#A8							; so 128-64 to get to the start of the next tile row
		gra _pltY
_exit
	rts

.as
.xs
addShadowsToMap_88
_ASSERT_jsr
_ASSERT_axy8
	stz TempX						; tile counter that is not trashed
-	ldy TempX						; get tile map index
	jsr tileIsSafeToChange_88	; is this a background tile?
	bcc +
		jsr calcBCDEforTileY_88	; calc shadow and update the tile
+	inc TempX						; next tile
	lda TempX
	cmp #kLevelSizeMax
	bne -
	rts

.as
.xs
tileIsWall_88
; if tileMapTemp[y] is a "wall" tile then c will clear, set otherwise
_ASSERT_jsr
_ASSERT_axy8
	lda tileMapTemp,y				; get current tile
	beq _no
		cmp #kTiles.wall4+1		; <= Wall4
		bcc _yes
			cmp #kTiles.diss		; == dissolvable char
			bne _no
			clc						; clear carry
_yes
	rts								; carry is clear
_no
	sec
	rts								; carry is set

.as
.xs
tileIsSafeToChange_88
; if tileMapTemp[y] is not something like a fruit, wall, spike, door etc C is set
; why inverse, that is how the cmp falls. As this is not 16K limited anymore you could set it right.
_ASSERT_jsr
_ASSERT_axy8
	lda tileMapTemp,y
	beq _yes									; 0 is safe
		cmp #kTiles.underHangStart
		bcs _yes
			rts ; carry is clear
_yes
	sec
	rts

; Don't try and understand this, not worth your life, it calcs the saul drop shadow, just move on.
;  BCD
;  EA
;  H
; A is tile we are testing
;  BCDE H
;  1110   = under hang
;  1100   = under hang right end
;  0110   = under hanr left  end
;  0001 0 = left wall top end
;  1001   = left wall
;  1000   = 35
;  11X1   = top left
;  0XX1 1 = bottom left
.as
.xs
calcBCDEforTileY_88
_ASSERT_jsr
_ASSERT_axy8
	sty ZPTemp
	sty ZPTemp2
	tya
	and #15
	bne _canDoLeft
		lda #$80					; can't do left on Negative
		bra +
_canDoLeft
	lda #0
+	sta ZPTemp4
	lda ZPTemp
	and #15
	cmp #15
	bne _canDoRight
		lda #$40					; can't do right on Overflow
		sta ZPTemp4
_canDoRight
END_LEFT_RIGHT_CHECK
	lda #1+2+4					; first 3 are empty ( it is inverted later)
	sta ZPTemp3
	ldy ZPTemp
	cpy #kTileXCount
	bcc _doneFirstRow		; if it is the first row than ALL of above is not solid
		stz ZPTemp3
		tya
		;sec ;from bcc above
		sbc #kTileXCount+1	; so get -1x,-1y
		sta ZPTemp2
		tay
		bit ZPTemp4				; test to see if we can do right
		bmi _noB					; no then skip B
			jsr tileIsWall_88
			rol ZPTemp3
			bra _testC
	_noB
		sec						; if there is no B then make it clear
		rol ZPTemp3
	_testC
		iny
		jsr tileIsWall_88
		rol ZPTemp3
		iny
		bit ZPTemp4
		bvs _noRight
			jsr tileIsWall_88
			rol ZPTemp3
			bra _doneFirstRow
	_noRight
		sec						; make it as 1 so it gets 0 later
		rol ZPTemp3
_doneFirstRow
	bit ZPTemp4
	bmi _noE						; check negative flag
		ldy ZPTemp
		dey
		jsr tileIsWall_88
		rol ZPTemp3
		bra DoIndexCheck
_noE
	sec							; make it 1 so it gets 0 later
	rol ZPTemp3
DoIndexCheck
	lda ZPTemp3
	eor #$0F
	tay
BCDEYVALUECHECK
	lda BCDELUT,y				; now we have the 5bit value of the case
	bmi _checkH					; 5th bit is stored in bit7
	_writeMap
		ldy ZPTemp
		sta tileMapTemp,y		; lower 4bits are the tile number
		rts
		;
_checkH
	lda ZPTemp
	clc
	adc #kTileXCount
	tay
	jsr tileIsWall_88
	bcs _HNotWall
		lda #kTiles.back
_HNotWall
	lda #kTiles.sideShadow
	bra _writeMap
	;

.as
.xs
clearTile
; this will set a tile to empty and calc and required shadow
_ASSERT_jsr
_ASSERT_axy8
	ldy ActiveTileIndex
	lda #kTiles.back
	sta tileMapTemp,y
	jsr calcBCDEforTileY_88 ; this sets it to be what it should be shadow wise
	ldy ActiveTileIndex
	lda tileMapTemp,y
pltSingleTile
; plots map tile in A to ActiveTileIndex
_ASSERT_jsr
_ASSERT_axy8
	tax
	lda toolToTileLUT,x
pltSingleTileNoLookup
; plots the raw screen tile in A to ActiveTileIndex
_ASSERT_jsr
_ASSERT_axy8
	pha
		lda ActiveTileIndex
		jsr convertIndexToScreenAndCRAM
	pla
	jsr renderTile_88
	rts

.as
.xs
; a = tile num, Pointer2 = Screen, Pointer 3 = CRAM
renderTile_88
_ASSERT_jsr
_ASSERT_axy8
		#A16
		and #$ff
		asl a					; 16bit multiply
		asl a					; tile num x 4		
		; clc					; must be empty		
		adc #<>fileTiles	; offset by fileTiles		
		sta Pointer4		; add the start of the map -> chars LUT table		
		lda #0
		#A8
		lda (Pointer4)		; read 1st char
		#A16
		sta [ZPLong]		; word Dest Char 1
		#A8
		ldy #1
		lda (Pointer4),y	; read 2nd char
		ldy #2
		#A16
		sta [ZPLong],y		; word Dest Char 2
		#A8
		lda (Pointer4),y	; read 3rd char
		ldy #64
		#A16
		sta [ZPLong],y		; word Dest Char 3
		#A8
		ldy #3
		lda (Pointer4),y	; read 4th char
		ldy #66
		#A16
		sta [ZPLong],y		; word Dest Char 4
		#A8
		; y can't be 0 at this point so we can use it to enable the screen update flag
		sty ScreenUpdateRequiredN0
		rts

.as
.xs
convertIndexToScreenAndCRAM
;CRAM is a hold over from the C64 that stores the Colour info in another area
_ASSERT_jsr
_ASSERT_axy8
	; screen is 32 wide and 2 per char so we want to time y * 64
	; 2 lines per tile so y*128
	sta TempX
	#a16			
	and #$00F0	; get y Part which is already x16
	asl a			; x32
	asl a			; x64
	asl a			; x128
	;clc			; upper bit had to be zero and still be 0
	adc #<>ScreenMirror
	sta ZPLong.loWord
	lda TempX			; this over reads but doesn't matter
	and #$000F			; x = x * 2 and 2 bytes per char so *4
	asl a
	asl a
	;clc					; again asl will have set c to 0 100%
	adc ZPLong.loWord
	sta ZPLong.loWord
	#a8
	lda #`ScreenMirror
	sta ZPLong.bank
	rts

.as
.xs
; returns Y into ZPTemp
convertIndexToEntSpriteXY
_ASSERT_jsr
_ASSERT_axy8
	sta ZPTemp3											; save full in temp3
	and #$f0												; mask of Y tile num
	sta mplexBuffer.ypos+kEntsSpriteOffset,x	; this is already x16 so save Y
	sta ZPTemp											; return it in ZPTemp
	lda ZPTemp3											; load the original
	and #$0f												; mask of the X tile num
	asl a
	asl a
	asl a
	asl a													; x16
	sta mplexBuffer.xpos+kEntsSpriteOffset,x	; store x
	stz mplexBuffer.xmsb+kEntsSpriteOffset,x	; to be sure sure
	rts

.as
.xs
convertLevelToTileMap_88
_ASSERT_JSR
		stz Bank80.LevelData.numKeysLeft			; we don't have any keys yet
		stz LevelData.totalKeys
		stz EntityData.numPipes						; or pipes
		stz EntityData.lastPipeUsed
		#A16
		lda #$FFFF
		sta LevelData.exitIndex						; and I don't know where the exits are
		lda #<>tileMapTemp
		sta Pointer1									; this the location of the converted map data
		lda GameData.currLevel
		asl a												; don't care what the upper half is
		tax												; this will only take 8 bits worth
		lda LevelTable,x
		sta Pointer2									; this is the location of the raw level data
; read level pointers
		ldy #0
		sty ActiveTileIndex							; start at the top left
		;lda (Pointer2),y
		;clc
		;adc Pointer2
		;sta LevelKeyListPtrLo						; skip these pointers as no longer used
		iny
		;lda (Pointer2),y
		;adc Pointer2+1
		;sta LevelKeyListPtrHi
		iny
		lda (Pointer2),y								; we now have the pointer to the entity data for this map
		clc
		adc Pointer2									; which is relative to the start of this "level spec"
		sta EntityDataPointer
		lda Pointer2
		clc
		adc #4											; skip over pointers 
		sta Pointer2
		#A8
		lda #12											; level data has 12 rows
		pha												; save the counter on the stack
_row	ldy #0											; for the _row
_loop	; read in 16 bytes							; for the byte in the row
		lda (Pointer2),y								; read source map tile
		cmp # kTiles.player							; player pos?
		beq _playerPos
			cmp # kTiles.exit							; exit position
			beq _exitPos
				cmp # kTiles.key1						; a key?
				beq _key
					cmp # kTiles.key2
					beq _key
						cmp # kTiles.key3
						beq _key
							cmp # kTiles.key4
							beq _key
								cmp # kTiles.pipe		; a pipe?
								beq _pipe
									cmp # kTiles.diss	; a diss?
									beq _dissBlock
															; no covert and then push out
_cont
		sta (Pointer1),y								; write the value
		inc ActiveTileIndex							; next tile
		iny
		cpy #16											; done a whole row?
		bne _loop
		#A16Clear
		lda Pointer2									; pMapDataSrc += 16
		adc #16
		sta Pointer2
		;clc												; can't overflow the bank
		lda Pointer1									; pTempMap += 16
		adc #16
		sta Pointer1
		#A8
		pla												; pull the Rows counter
		dec a
		pha												; save it again
		bne _row											; no done, new row
		pla												; pull counter of stack
		rts
		;
_playerPos
		lda ActiveTileIndex
		sta LevelData.playerIndex					; record this tile as the tile player starts on
		lda #kTiles.back								; but draw an empty tile on the map
		bra _cont
		;
_key	inc LevelData.numKeysLeft
		inc LevelData.totalKeys						; increase total amount of keys
		bra _cont
		;
_dissBlock
		lda #kTiles.diss								; convert this to a diss full block
		bra _cont
		;
_exitPos
		lda ActiveTileIndex
		ldx LevelData.exitIndex						; is this the first or second exit for this map
		cpx #$FF
		bne _2nd
			sta LevelData.exitIndex					; first
			bra +
			;
_2nd	sta LevelData.exitIndex+1					; second
+		lda #kTiles.exit								; draw a door at this tile
		bra _cont
		;
_pipe
		ldx EntityData.numPipes						; current next pipe
		lda ActiveTileIndex
		sec
		sbc #16											; bubbles spawn at the tile above the pipe
		sta EntityData.pipeIndex,x
		inx
		stx EntityData.numPipes						; count this pipe
		lda #kTiles.pipe								; draw a pipe
		bra _cont
		;

.as
.xs
countTempMapTile_88
; how many of A is in the live map?
; returned in A
_ASSERT_jsr
_ASSERT_axy8
	ldx # kLevelSizeMax-1	; for all tiles
	ldy #0
_loop
	cmp tileMapTemp,x			; is this it?
	bne _skip
		iny						; count it
_skip
	dex
	cpx #$ff						; until done
	bne _loop
	tya
	rts

.as
.xs
removeAllTilesOf_88
_ASSERT_jsr
_ASSERT_axy8
	sta ZPTemp5							; cache tile I want to remove
	ldx #0
	stx ActiveTileIndex				; start at top left
_loop
	lda tileMapTemp,x					; if tile[ActiveTileIndex] == tileToRemove
	cmp ZPTemp5
	bne _next
		jsr clearTile					; clear it to "back"
		jsr CheckForShadowPlots		; check to see if it needs to be shadowed
_next
	inc ActiveTileIndex
	ldx ActiveTileIndex
	cpx # kLevelSizeMax
	bne _loop
	rts

BCDELUT	.byte $00							; 0000
		.byte kTiles.sideShadow				; 0001
		.byte $00								; 0010
		.byte kTiles.sideShadow				; 0011
		.byte kTiles.underHangStart		; 0100
		.byte kTiles.topLeftCorner			; 0101
		.byte kTiles.underHangStart		; 0110
		.byte kTiles.sideShadow				; 0111
		.byte kTiles.shadowOpenCorner		; 1000
		.byte kTiles.middlesideShadow		; 1001
		.byte kTiles.shadowOpenCorner		; 1010
		.byte kTiles.sideShadow				; 1011
		.byte kTiles.underHang				; 1100
		.byte kTiles.topLeftCorner			; 1101
		.byte kTiles.underHang				; 1110
		.byte kTiles.topLeftCorner			; 1111

		; back
		; wall,wall1,wall2,wall3,wall4
		; spike,flower,fruit
		; key1,key2,key3,key4
		; shield,spring,potion,egg
		; exit,something,something,
		; diss + 13
toolToTileLUT
	.byte 0
	.byte 1,1,1,1,1
	.byte 2,3,4
	.byte 5,5,5,5
	.byte 6,7,8,9
	.byte 10,15,16
	.byte 17,18,19,20,21,22,23,24,25,26,27,28,29,30 ; diss cont
	.byte 31,32,33,34,35,36

; tile logic number, doesn't convert to the 4 tiles displayed on the screen 1:1
; so I just made a LUT
fileTiles

linerTile4 .macro				; this makes .byte a,a+1,a+2,a+3
	.byte \1*4+range(4)
.endm
#linerTile4 0 ; back
#linerTile4 4 ; wall
#linerTile4 14 ; spike
#linerTile4 17 ; flower
#linerTile4 12 ; fruit
#linerTile4 15 ; key
#linerTile4 18 ; shield
#linerTile4 19 ; spring
#linerTile4 20 ; potion
#linerTile4 21 ; egg
#linerTile4 16 ; exit
.byte 193,194,195,196 ; exit open frame 1
.byte 197,198,199,200 ; exit open frame 2
.byte 197,201,199,202 ; exit open frame 3
.byte 197,201,199,203 ; exit open frame 4
#linerTile4 16 ; ???
#linerTile4 13 ; bubble launcher
#linerTile4 5 ; Diss start
.byte 20,21,24,25
.byte 20,21,26,27
.byte 20,21,28,29
.byte 20,21,30,31
.byte 20,21,32,33
.byte 20,21,14,15
.byte 34,35,14,15
.byte 36,37,14,15
.byte 38,39,14,15
.byte 40,41,14,15
.byte 42,43,14,15
.byte 44,45,14,15
.byte 12,13,14,15 ; DISS End
.byte 4,5,2,3 ; underhang start
.byte 7,5,2,3 ; underhang
.byte 8,1,2,3 ; shadow open corner
.byte 9,1,11,3 ; side shadow
.byte 10,1,11,3 ; middlesideShadow
.byte 6,5,11,3 ; topLeftCorner
.byte 124,125,126,127 ; old wall for intermission

; ----- @Player Routines@ -----

kPlayerState .block
	appear = 0
	normal = 1
	flap = 2
	jump = 3
	exit = 4
	dead = 5
.bend

kPlayerAnimsIndex .block
	standRight = 0
	standLeft = 1
	standWalkRight = 2
	standWalkLeft = 3
	jumpRight = 4
	jumpLeft = 5
	flapRight = 6
	flapLeft = 7
	dead = 8
	exit = 9
.bend

kJumpIndexs .block
	normal = 0
	floaty = 2
.bend

kPlayerParams .block
	jumpStartDelta = 255-1
	jumpDeltaAccum = 19
	jumpDeltaAccumFloat = 4
	maxFallSpeed = 4
.bend

kPlayerStateExit .block
	waitForAnimation = 0
.bend

kPlayerStateDeath .block
	animate = 0
.bend

kIntermission .block
	firstExit = kTileXCount*5
	secondExit = (kTileXCount*6)-1
.bend

joyToPlayerDelta_88
_ASSERT_jsr
_ASSERT_axy8
	#A16
	stz checkSpriteToCharData.xDeltaCheck
	stz checkSpriteToCharData.yDeltaCheck				; clear movement deltas
	#A8
	stz PlayerData.movingLRNZ								; assmue we are not moving
	lda joyLeft
	ora joyRight
	beq _noLR													; any X input
		lda joyLeft												; was it left?
		bne _left
			lda PlayerData.slowMoveNZ						; right, are we in slow move?
			beq +
				lda #1
				.byte $2c										; bit XXXX this is a trick to skip 2 bytes, so lda skip next lda
	+		lda #2
			sta checkSpriteToCharData.xDeltaCheck		; set delta to check
			lda joyRight
			and oldJoyLeft
			beq _fullSpeedRight								; we were already going right
				lda PlayerData.OnGroundNZ					; slow for opposite only happens in the air
				bne _clearSpeedRight
					lda #1
					.byte $2c									; bit XXXX skip 2 bytes
		_clearSpeedRight
			lda #0
			sta PlayerData.slowMoveNZ						; store speed state
_fullSpeedRight
	lda #1
	sta PlayerData.movingLRNZ								; we are moving
	dec a ; a = 0
	jsr changePlayerDir										; set player to right
	gra _endLR
	;
_left
	lda PlayerData.slowMoveNZ
	beq +
		lda #-1
		.byte $2c ; bit
+	lda #-2
	sta checkSpriteToCharData.xDeltaCheck				; set x delta to -1/-2 depending on speed
	lda #$ff
	sta checkSpriteToCharData.xDeltaCheck.hi			; sign extend
	lda joyLeft
	and oldJoyRight
	beq _fullSpeedLeft										; we were already going left
		lda PlayerData.OnGroundNZ
		bne _clearSpeedLeft
			lda #1
			.byte $2c											; bit XXXX skip 2 bytes
_clearSpeedLeft
		lda #0
		sta PlayerData.slowMoveNZ							; set speed
_fullSpeedLeft
	lda #1
	sta PlayerData.movingLRNZ								; we are moving
	jsr changePlayerDir										; make sure we are facing left
	bra _endLR
	;
_noLR
	lda #$80
	sta PlayerData.startedJumpLR							; we are not jumping LR
	stz PlayerData.slowMoveNZ								; clear slow move
_endLR
	lda PlayerData.movingLRNZ								; are we moving LR?
	bne +
		lda PlayerData.facingRight
		jsr changePlayerDir									; make sure the facing is updated
+	lda PlayerData.OnGroundNZ
	and joyUpStart
	ora PlayerData.forceJumpNZ
	bne StartJump												; if (onGround && JoyUpStart) || forceJump then jump
		lda PlayerData.OnGroundNZ
		bne OnGround
			lda PlayerData.yDeltaAccum.hi					;if inAir then update Y speed
			bpl falling
				stz PlayerData.isFallingNZ					; if ySpeedDelta -ve then we are going up
				lda PlayerData.hasJumpedNZ					; if this is 1
				and joyUpStop									; and the player has let go
				bne AbortJump									; abort jump and start falling
				; we are in air then
normalJumpUpdate
	ldx #kJumpIndexs.normal									; nope just jumping not special
customJumpUpdate
	jsr incPlayerYDeltaAndReturn							; update the jump parabola
	lda PlayerData.yDeltaAccum.hi
	sta checkSpriteToCharData.yDeltaCheck				; take the upper 8 bits as the Y delta
	rts

falling
_ASSERT_axy8
	lda #1
	sta PlayerData.isFallingNZ								; make sure we mark we are falling
	lda PlayerData.canFloatNZ								; if I can't float
;	ora PasswordHaveSpring
	beq normalJumpUpdate										; handle it as normal
		bra handleFall											; else start fall

OnGround
_ASSERT_axy8
	lda #kPlayerState.normal
	sta PlayerData.state										; back to normal
	lda PlayerData.hitBubbleNum							; unless I landed on a bubble
	beq _skip
		lda #-1													; in which case move me up 1 with it, probably should be a constant
		.byte $2c												; skip XXXX
_skip
	lda #1														; check into the ground to make sure I'm still standing on some
	sta checkSpriteToCharData.yDeltaCheck
	jmp changePlayerAnimForCurrentDir					; update any facing direction as needed
;	rts

AbortJump
_ASSERT_axy8
	lda #$80
	sta PlayerData.yDeltaAccum.lo
	lda #$FF
	sta PlayerData.yDeltaAccum.hi							; set to hash fall speed -1.5
	rts

StartJump
_ASSERT_axy8
	lda #1
	sta PlayerData.hasJumpedNZ								; we are jumping
	lda #kPlayerState.jump
	sta PlayerData.state										; enter the jump state
	stz PlayerData.isFallingNZ								; not falling
	stz PlayerData.OnGroundNZ								; not on the ground
	stz PlayerData.yDeltaAccum.lo							; set the Y jump accleration
	stz PlayerData.forceJumpNZ
	lda #kTimers.floatTimer									; reset the float timer
	sta PlayerData.floatTimer
	lda #kPlayerParams.jumpStartDelta					; set the upper half of jump accleration
	sta PlayerData.yDeltaAccum.hi
	sta checkSpriteToCharData.yDeltaCheck				; which is also how much we are moving this frame
	jsr changePlayerAnimForCurrentDir					; update the animation
	lda #kSFX.jump
	jmp playSFX
	rts
	
handleFall
_ASSERT_axy8
	lda PlayerData.state
	cmp #kPlayerState.jump
	bne _didntJustStartFalling								; are we still "jumping"
		lda joyUp												; if we just start falling, and joy is up and we have spring float
		beq _didntJustStartFalling							; if we don't have the spring we don't to this function.
			lda #kPlayerState.flap
			sta PlayerData.state								; enter flap state
			bra _dontStopFloat
			;
_didntJustStartFalling
	lda PlayerData.state
	cmp #kPlayerState.flap
	bne _checkUpStart											; if we are falling, and not already flapping check up
		lda joyUpStop
		beq _dontStopFloat									; did we just release up?
			lda #kPlayerState.jump
			sta PlayerData.state								; we are now just "jumping" and handle as normal
			jmp normalJumpUpdate
_dontStopFloat
	lda PlayerData.floatTimer								; can we still "float"
	bpl +
		jmp normalJumpUpdate									; nope, go back to normal to fall
+	dec PlayerData.floatTimer
	ldx #kJumpIndexs.floaty
	jmp customJumpUpdate										; do a floaty jump then
	;
_checkUpStart
	lda joyUpStart
	bne +
		jmp normalJumpUpdate									; no up don't enter float so carry on as normal
+	lda #kPlayerState.flap
	sta PlayerData.state
	ldx #kJumpIndexs.floaty
	jmp customJumpUpdate										; enter float state and do floaty jump

enterOnGround
_ASSERT_jsr
_ASSERT_axy8
	lda #kPlayerState.normal ; == 1
	sta PlayerData.state
	.cerror kPlayerState.normal != 1, "need to add lda #1"
	sta PlayerData.OnGroundNZ								; we are now in normal mode and on the ground
	sta PlayerData.yDeltaAccum.lo							; tiny bit down
	stz PlayerData.hasJumpedNZ								; not jumping, or falling, or moving slow
	stz PlayerData.isFallingNZ
	stz PlayerData.yDeltaAccum.hi
	stz PlayerData.slowMoveNZ
	lda PlayerData.facingRight								; set the right direction and update animation to standing
	; fall through
changePlayerDir
_ASSERT_axy8
	sta PlayerData.facingRight
changePlayerAnimForCurrentDir
_ASSERT_axy8
	lda PlayerData.state
	cmp #kPlayerState.flap									; if flap then flap animation
	bne _notFlap
		lda #kPlayerAnimsIndex.flapRight
		bra _still
		;
_notFlap
	lda PlayerData.OnGroundNZ								; else if not on ground, jump animation
	bne _onGround
		lda #kPlayerAnimsIndex.jumpRight
		bra _still
		;
_onGround
	lda PlayerData.movingLRNZ								; else if moving, walk animation
	beq _notMoving
		lda #kPlayerAnimsIndex.standWalkRight
		bra _still
_notMoving
	lda #kPlayerAnimsIndex.standRight					; else stand animation
_still
	clc
	adc PlayerData.facingRight								; convert to left if needed
	gra setPlayerAnimeTo_88
	;rts ;above is now a jmp


incPlayerYDeltaAndReturn
_ASSERT_jsr
_ASSERT_axy8
	#A16
	lda PlayerData.yDeltaAccum								; yDelta += JumpSpeed[normal/float]
	clc
	adc PlayerJumpLUT,x
	sta PlayerData.yDeltaAccum
	#A8
	lda PlayerData.yDeltaAccum.hi
	bmi +															; if negative then we are fine
		cmp # kPlayerParams.maxFallSpeed					; has the hi reached max fall velocity
		bcc +														; nope
			lda # kPlayerParams.maxFallSpeed				; yes clip it, however lo remains untouched 
+	sta PlayerData.yDeltaAccum.hi							; so fall can be a bit random
	rts

.as
.xs
setPlayerAnimeTo_88
_ASSERT_jsr
_ASSERT_axy8
	cmp PlayerData.currAnim									; if already in this state don't change
	beq _dontchange											; this way I can just always do a "change anim"
		sta PlayerData.currAnim								; and it won't muck the animation up
		tax
		lda PlayerFrameData.animFrameRate,x				; read the frames speed
		sta TickDowns.playerAnim							; set the anim timer to new speed
		stz PlayerData.frameOffset							; reset to frame zero as new anim may have less frames then current
_dontchange
	rts

.as
.xs
setPlayerSpritePtrFromFrameNumber_88
_ASSERT_jsr
_ASSERT_axy8
	ldx PlayerData.currAnim
	lda PlayerFrameData.animFrameIndexs,x					; get the curent base index for this animation
	clc
	adc PlayerData.frameOffset									; offset by current frame
	tay
	lda PlayerFrameData.animFrameChar,y						; store the char number
	sta OAMMirror+2
	clc																; on the off chance this is 16x32 set the lower sprite as well
	adc #32															; its faster than checking, the X/Y setting will move
	sta OAMMirror+6												; it offscreen if not needed
	lda PlayerFrameData.animFrameAttri,y
	sta OAMMirror+3
	adc #0															; add carry if we cross boundary
	sta OAMMirror+7
	rts


.as
.xs
updatePlayerAnim_88
_ASSERT_jsr
_ASSERT_axy8
; returns carry clear if anim did not loop
; carry is set if it did
	ldx PlayerData.currAnim
	lda PlayerFrameData.animTypes,x
	cmp #kSpriteAnimationType.none							; is this a hold frame?
	beq _skip
		lda TickDowns.playerAnim								; time for next frame?
		beq _itTime
			clc
_skip
	rts

_itTime
	lda PlayerData.frameOffset
	clc
	adc #1
	cmp PlayerFrameData.animFrameCount,x					; add and reset to 0 if over
	bcc _store
		lda #0
_store
	sta PlayerData.frameOffset
	php																; if we overflowed c will be set, else clear
		lda PlayerFrameData.animFrameRate,x
		sta TickDowns.playerAnim								; reset timer
		jsr setPlayerSpritePtrFromFrameNumber_88			; update the sprite
	plp																; restore carry state
	rts

.as
.xs
setPlayerToSpawnPoint_88
_ASSERT_jsr
_ASSERT_axy8
	lda LevelData.playerIndex									; get the spwan map index
setPlayerToIndexA
	pha																; save A for Y extration
		asl a
		asl a
		asl a
		asl a															; mul X by 16 which also clears out the Y
		sta mplexBuffer.xpos										; save the X
		stz mplexBuffer.xmsb										; no MSB from a fixed tile
	pla																; restore index value
	and #$F0															; mask off Y value which is already x16
	sta mplexBuffer.ypos											; save the Y
	; make sure the bullet is off the screen
	lda #kSpriteEmptyVal
	sta mplexBuffer.ypos+kBulletSpriteOffset
	sta mplexBuffer.xpos+kBulletSpriteOffset
	rts

.as
.xs
clearPlayerStuct_88
_ASSERT_jsr
_ASSERT_axy8
	ldx #size(sPlayerData)-1
-	stz PlayerData,x												; just set it all to 0
	dex
	bpl -
	rts

.as
.xs
removePickups_88
_ASSERT_jsr
_ASSERT_axy8
	stz PlayerData.canFloatNZ
	stz PlayerData.bulletActive
	stz PlayerData.numBulletEgg
	jmp clearShieldState											; shield has timmers and other state with it
	;

.as
.xs
awardLife_88
_ASSERT_jsr
_ASSERT_axy8
;	lda PasswordInfiLives
;	beq +
;		rts
+	inc GameData.lives
	jmp pltLives


; ----- @Player Animation Data@ -----

kSpriteType .block
	s16x16 = 0
	s16x32 = 1
	s32x32 = 2
.bend

kSpriteAnimationType .block
	none = 0
	loop = 1
.bend

kPlayerSprFlags = kSpri_2 | kSPal_2

; this is all the raw word data for each sprite that makes up the animations
RightFrames = ( fSprDef(0,0,kPlayerSprFlags), )
LeftFrames = ( fSprDef(0,0,kPlayerSprFlags|kSFlipX), )
WalkRightFrames = ( fSprDef(0,1,kPlayerSprFlags), fSprDef(1,1,kPlayerSprFlags),fSprDef(2,1,kPlayerSprFlags),fSprDef(3,1,kPlayerSprFlags))
WalkLeftFrames = ( fSprDef(0,1,kPlayerSprFlags|kSFlipX), fSprDef(1,1,kPlayerSprFlags|kSFlipX),fSprDef(2,1,kPlayerSprFlags|kSFlipX),fSprDef(3,1,kPlayerSprFlags|kSFlipX))
JumpRightFrames = ( fSprDef(0,2,kPlayerSprFlags), fSprDef(1,2,kPlayerSprFlags) )
JumpLeftFrames = ( fSprDef(0,2,kPlayerSprFlags|kSFlipX), fSprDef(1,2,kPlayerSprFlags|kSFlipX) )
FlapRightFrames = ( fSprDef(4,0,kPlayerSprFlags), fSprDef(6,0,kPlayerSprFlags) )
FlapLeftFrames = ( fSprDef(4,0,kPlayerSprFlags|kSFlipX), fSprDef(6,0,kPlayerSprFlags|kSFlipX) )
DeadFramesUpper = ( fSprDef(2,2,kPlayerSprFlags), fSprDef(3,2,kPlayerSprFlags),fSprDef(4,2,kPlayerSprFlags),fSprDef(5,2,kPlayerSprFlags))
ExitFrames = ( fSprDef(0,3,kPlayerSprFlags), fSprDef(1,3,kPlayerSprFlags),fSprDef(0,3,kPlayerSprFlags|kSFlipX), fSprDef(1,3,kPlayerSprFlags|kSFlipX) )

; each animation then has data such as the frame size, mode, rate etc 
; sizes, animation style, frames, anim X offset, animation frame rate
PlayerFrameSpec :=  [(kSpriteType.s16x16, kSpriteAnimationType.none, RightFrames,		0,		255)]
PlayerFrameSpec ..= [(kSpriteType.s16x16, kSpriteAnimationType.none, LeftFrames,			0,		255)]
PlayerFrameSpec ..= [(kSpriteType.s16x16, kSpriteAnimationType.loop, WalkRightFrames,	0,		8)]
PlayerFrameSpec ..= [(kSpriteType.s16x16, kSpriteAnimationType.loop, WalkLeftFrames,	0,		8)]
PlayerFrameSpec ..= [(kSpriteType.s16x16, kSpriteAnimationType.loop, JumpRightFrames,	0,		8)]
PlayerFrameSpec ..= [(kSpriteType.s16x16, kSpriteAnimationType.loop, JumpLeftFrames,	0,		8)]
PlayerFrameSpec ..= [(kSpriteType.s32x32, kSpriteAnimationType.loop, FlapRightFrames,	0,		8)]
PlayerFrameSpec ..= [(kSpriteType.s32x32, kSpriteAnimationType.loop, FlapLeftFrames,	-16,	8)]
PlayerFrameSpec ..= [(kSpriteType.s16x32, kSpriteAnimationType.loop, DeadFramesUpper,	0,		8)]
PlayerFrameSpec ..= [(kSpriteType.s16x16, kSpriteAnimationType.loop, ExitFrames,			0,		8)]

; now we extract all the info and do an Array of Structs to Struct of Arraies conversion
PlayerFrameData .block
	sizes					.byte PlayerFrameSpec[:,0]		; the size for each animation
	animTypes			.byte PlayerFrameSpec[:,1]		; if its static or looping
	animXOffset			.char PlayerFrameSpec[:,3]		; any player to sprite X offset needed
	_animDataIndex := []										; we need to get all the sprite def words but also
	_frameWords := []											; keep a track of the starting point into the list of all
	_frameCount := []											; off them for each animation, and how long each anim is
	.for frames in PlayerFrameSpec[:,2]
		_animDataIndex ..= [len(_frameWords)]			; record the current lenght of all the frames we have
		_frameWords ..= frames								; append this animations frames to the list
		_frameCount ..= [len(frames)]						; append the number of frames
	.next
	animFrameIndexs	.byte (_animDataIndex)			; write all the start indexs for the frames
	animFrameChar		.byte <(_frameWords)				; the low of the char number
	animFrameAttri		.byte >(_frameWords)				; the high + attributes
	animFrameCount		.byte (_frameCount)				; number of frames
	animFrameRate		.byte (PlayerFrameSpec[:,4])	; and the rate
.bend

; simple lut to handle normal jumping and floating acceleration rates
PlayerJumpLUT .word kPlayerParams.jumpDeltaAccum, kPlayerParams.jumpDeltaAccumFloat

; for the flash affect, we have a whole two colours, yellow and blue
PlayerColourLUT .block
	_colours = (fRGBToSNES(214,222,123),fRGBToSNES(132,123,222))
	lo .byte <(_colours)
	hi .byte >(_colours)
.bend

; ----- @Bullet Routines@ -----

startBullet
_ASSERT_jsr
_ASSERT_axy8
	lda #1
	sta PlayerData.bulletActive					; we have a bullet there is only 1
	lda #kSFX.bubble
	jsr playSFX
	stz PlayerData.bulletUD							; it goes up with to start
	stz PlayerData.bulletBurstNZ					; its not dead either
	lda PlayerData.facingRight
	sta PlayerData.bulletLR							; make it move forward
	lda #200
	sta TickDowns.bulletLifeTimer					; it lives for 4 seconds (PAL)
	lda mplexBuffer.xpos
	sta mplexBuffer.xpos+kBulletSpriteOffset	; same X as the player
	lda mplexBuffer.ypos
	sec
	sbc #3
	sta mplexBuffer.ypos+kBulletSpriteOffset	; 3 above the player
	lda mplexBuffer.xmsb
	sta mplexBuffer.xmsb+kBulletSpriteOffset	; copy players MSB (not really needed on SNES)
	lda PlayerData.numBulletEgg					; is this a bubble or an egg bullet
	;ora PasswordRedBullets
	beq _normal
		lda #kSprites.bulletRed
		bra _store
_normal
	lda #kSprites.bulletSprite
_store
	sta bulletFrame
	rts

updateBullet
_ASSERT_jsr
_ASSERT_axy8
	lda PlayerData.bulletActive
	beq bulletExit
		lda TickDowns.bulletLifeTimer			; has it expired?
		bne bulletNotDead
		;
removeBullet
_ASSERT_jsr
_ASSERT_axy8
	stz PlayerData.bulletActive				; no longer alive
	lda PlayerData.numBulletEgg				; if I have an egg dec it
	beq +												; this leads to an exploit, if you fire collect then you loose the egg
		;lda PasswordRedBullets
		;bne +
			dec PlayerData.numBulletEgg
+	lda #kSpriteEmptyVal							; set bullet off screen
	sta mplexBuffer.ypos+kBulletSpriteOffset
bulletExit
	rts

burstBullet
_ASSERT_jsr
_ASSERT_axy8
	lda #kSprites.bulletSplat
	sta bulletFrame								; we splat
	lda #16
	sta TickDowns.bulletLifeTimer				; hold it for 16 frames
	lda #1
	sta PlayerData.bulletBurstNZ				; mark it as burst
	lda #kSFX.bubble
	jmp playSFX
	rts

bulletNotDead
_ASSERT_jsr
_ASSERT_axy8
	lda PlayerData.bulletBurstNZ
	bne bulletExit										; if not burst
		lda PlayerData.numBulletEgg
		;ora PasswordRedBullets
		bne _bulletFull								; are we full?
			lda bulletFrame
			cmp #kSprites.bulletSprite+(2*2)		; have we reached the full size, word index
			beq _bulletFull
				lda TickDowns.bulletLifeTimer		; is it time to update the frame?
				and #$07									; every 8 frames
				bne _bulletFull
					inc bulletFrame					; next frame
					inc bulletFrame					; next frame word index
_bulletFull
	lda #kBulletCollisionbox
	sta CollideSpriteBoxIndex						; set collision size to the bullets
	; lda #kBulletSpriteOffset ; same as kBulletCollisionbox
	sta CollideSpriteToCheck
	#A16
	lda #<>UpdateBulletEndYColl
	sta Pointer1										; set post collision callback
	#A8
	lda #0
	sta CollisionResult
	tay ; ldy #0
	lda PlayerData.bulletUD							; which Y direction are we moving?
	beq +
		jmp entDown
+	jmp entUp

UpdateBulletEndYColl
_ASSERT_jsr
_ASSERT_axy8
	lda CollisionResult
	beq _updateY										; did the egg hit something
		lda PlayerData.bulletUD						; yes
		eor #1
		sta PlayerData.bulletUD						; change direction
	bpl _checkX
_updateY
	lda mplexBuffer.ypos+kBulletSpriteOffset
	clc
	adc checkSpriteToCharData.yDeltaCheck		; update the Y
	sta mplexBuffer.ypos+kBulletSpriteOffset
_checkX
	#A16
	lda #<>UpdateBulletEndXColl						; set the x collision callback
	sta Pointer1
	#A8
	lda #$00
	sta CollisionResult								; clear the result
	tay ;ldy #0
	lda PlayerData.bulletLR							; which way are we moving?
	bne +
		jmp entRight
+	jmp entLeft

; do some more collision checking here
UpdateBulletEndXColl
_ASSERT_jsr
_ASSERT_axy8
	lda CollisionResult								; did we hit something?
	beq _updateX
		lda PlayerData.bulletLR						; go the other way
		eor #1
		sta PlayerData.bulletLR
		bpl _checkEnts
_updateX
	ldx #kBulletSpriteOffset
	jsr addXWithMSBAndClip_88						; move on the X
	lda DidClipX										; did we hit an edge?
	beq _checkEnts
		lda PlayerData.bulletLR						; bounce the other way
		eor #1
		sta PlayerData.bulletLR
_checkEnts
	jsr collideBulletAgainstRest					; did we hit an enmey
	bcc _exit2											; didn't hit one
		lda EntityData.type,x						; yes, is it a boss?
		jsr isTypeBoss
		bcs _boss
			lda #kEntity.removedFromBullet		; we make an entity removed by bullet
			ldy PlayerData.numBulletEgg			; so we can put it back latter
			beq +
				lda #kEntity.deadFromRedBullet	; if it was red we don't restore them
		+	sta EntityData.entState,x
			lda #255										; disable Ent
			sta mplexBuffer.ypos+kEntsSpriteOffset,x
			sta EntityData.movTimer,x
			inc a											; 0
			sta EntityData.active,x
			inc a											; 1
			sta EntityData.speed,x
			jmp burstBullet
	_exit2
		rts
_boss
	lda PlayerData.numBulletEgg
;	ora PasswordRedBullets
	beq _exit2											; only accept eggs for the boss
		lda EntityData.type,x
		jsr isTypeBossBounceDetect					; look for the actual bear not the dummies 
		bcs _found
			dex											; doesn't affect C
			bra _boss
_found
	jsr hurtBoss
	jmp burstBullet

PlayerBulletFrames = (fSprDef(6,6,kPlayerSprFlags), fSprDef(7,6,kPlayerSprFlags), fSprDef(6,7,kPlayerSprFlags), fSprDef(7,7,kPlayerSprFlags), fSprDef(6,14,kPlayerSprFlags))
PlayerBulletAnimData .block
	.word <>(PlayerBulletFrames)
;	lo .byte <(PlayerBulletFrames)
;	hi .byte >(PlayerBulletFrames)
.bend

; ----- @Entity system@ -----

mConvertXToEntSpriteX .macro ; skip past player + bullet
	inx
	inx
.endm

mRestoreEntSpriteX .macro ; go back past player + bullet
	dex
	dex
.endm

kBoss .block
	hitPoints = 7
	hitPointsOctopuss = 9
	deathAnimTime = 25
	normal = 0
	dead = 1
.bend

kFishLimits .block
	startTwo = 250-21-(8*6) ; 165
	maxY = 255-8-50
.bend

kSpiderValues .block
	yFallDelta = 2
	rightStartWiggle = 255-32-14 ; 32 pixels but compenstating for the sprite width
	rightStartFall = 255-16-14 ; 16 pixels
	leftStartWiggle = 32+14
	leftStartFall = 16+14
	pauseEndFallFrames = 32
	riseDelayTime = 3
.bend

.as
.xs
unpackEntityBytes
_ASSERT_jsr
_ASSERT_axy8
	; asume we don't have any bosses and reset the sprites back to normal
	lda #kDefault_OBSEL
	sta $802101
	ldy #0
	ldx #kEntity.maxEntities-1				; clear all entities
-	stz EntityData.animBase,x
	stz EntityData.animFrame,x
	stz EntityData.entState,x
	stz EntityData.palleteOffset,x
	dex
	bpl -
	lda (EntityDataPointer),y				; read the number of entities
	sta ZPTemp2									; number of entities
	sta EntityData.number
	beq _e										; check for if we have none, handy while testing layouts etc
		iny										; next byte
		ldx #0
		sta EntNum
	_l
		lda (EntityDataPointer),y			; read entity tile index for starting pos
		jsr convertIndexToEntSpriteXY
		iny			; next byte
		lda (EntityDataPointer),y			; read TTTTXDDDD T = type X = don't care D = starting direction
		lsr a
		lsr a
		lsr a
		lsr a										; extract the type
		sta EntityData.type,x				; store it
		cmp #kEntity.Bear						; do we have a bear boss?
		bne +
			gra _BossBear						; handle the custom case
	+	cmp #kEntity.Octopuss				; same with the octopuss
		bne +
			jmp _BossOctopuss
	+	lda ZPTemp								; convertIndexToEntSpriteXY returns the Y in ZPTemp
		sta EntityData.originalY,x
		stz EntityData.entState,x			; clear the state, and speed all ents are spawned slow
		stz EntityData.speed,x
		lda (EntityDataPointer),y			; extract the D from the byte
		and #3
		sta EntityData.direction,x
		lda #1
		sta EntityData.active,x				; it's alive
	_nextEnt
		iny										; next byte
		inx
		dec ZPTemp2								; have we done all ents?
		lda ZPTemp2
		bne _l
_e
	ldx EntityData.number					; now we can start any bubbles if we need them
	stx EntityData.pipeBubbleStart
	lda EntityData.numPipes					; do we need them?
	beq _noPipes
		.cerror kEntity.maxNumBubblesPerMaker != 2, "need to change code so it handles new mul"
		asl a										; times two
		clc										; probably not needed as num pipes must be below 128
		adc EntityData.number
		sta EntityData.number				; add the bubble ents
	_setupBubbleLoop
		lda #kEntity.bubble
		sta EntityData.type,x				; we have a bubble
		stz EntityData.entState,x			; zero state
		stz EntityData.direction,x			; up
		stz EntityData.active,x				; not active
		stz EntityData.palleteOffset,x	; stock colour
		inx
		cpx EntityData.number				; done all of them?
		bne _setupBubbleLoop
_noPipes
	rts
	;
_BossBear
	lda #kEntity.bear										; bosses are actually 4 entites
	sta EntityData.type,x
	lda #kEntity.bearBody								; the body
	sta EntityData.type+1,x
	lda #kBoss.hitPoints
	sta EntityData.active,x								; abuse active as a hit points counter
	lda #kDefault_OBSEL|kBossBearBankOR				; enable the bear boss sprite bank
_sharedBoss
	sta $802101												; set the sprite bank
	lda #kEntity.bossDummy
	sta EntityData.type+2,x								; 3 and 4 are dumnmy ents
	sta EntityData.type+3,x								; which just show a sprite
	lda EntityData.number
	clc
	adc #3													; insert 3 more ents for the rest of the boss
	sta EntityData.number
	lda #1
	sta EntityData.active+1,x
	sta EntityData.active+2,x
	sta EntityData.active+3,x							; set all 4 active
	txa
	sta EntityData.entState+1,x						; set the state of the extras to point to the "first"
	sta EntityData.entState+2,x
	sta EntityData.entState+3,x
	lda mplexBuffer.xmsb+kEntsSpriteOffset,x		; copy the MSB from the first to the others 
	sta mplexBuffer.xmsb+kEntsSpriteOffset+1,x	; which technically doesn't work but mostly works
	sta mplexBuffer.xmsb+kEntsSpriteOffset+2,x	; but this is the SNES so it will be all 0 anyway
	sta mplexBuffer.xmsb+kEntsSpriteOffset+3,x
	lda mplexBuffer.ypos+kEntsSpriteOffset,x		; the boss is moved up 9 pixels so the sits on the top of blocks
	sec
	sbc #9
	sta mplexBuffer.ypos+kEntsSpriteOffset,x
	sta mplexBuffer.ypos+kEntsSpriteOffset+1,x
	clc
	adc #21													; and the bottom sprites are 21 lower (c64 sprits are 24x21)
	sta mplexBuffer.ypos+kEntsSpriteOffset+2,x
	sta mplexBuffer.ypos+kEntsSpriteOffset+3,x
	lda mplexBuffer.xpos+kEntsSpriteOffset,x		; we move the sprites -8 from spawn position
	sec
	sbc #8
	sta mplexBuffer.xpos+kEntsSpriteOffset,x
	sta mplexBuffer.xpos+kEntsSpriteOffset+2,x	; right sprites are 24 over from that
	clc
	adc #24
	sta mplexBuffer.xpos+kEntsSpriteOffset+1,x
	sta mplexBuffer.xpos+kEntsSpriteOffset+3,x
	stz EntityData.entState,x							; the main state is 0
	stz EntityData.speed,x								; slow speed
	lda (EntityDataPointer),y							; get the type and starting direction
	and #3
	sta EntityData.direction,x
	lda #25
	sta EntityData.movTimer,x							; set the move rate, so the boss pauses for a bit before starting
	sta EntityData.movTimer+1,x
	inx
	inx
	inx														; x is now + 3 so when nextEnt is called it will be +4
	jmp _nextEnt
	;

_BossOctopuss
	lda #kEntity.octopuss
	sta EntityData.type,x								; we are octopuss
	lda #kEntity.octopussBody
	sta EntityData.type+1,x								; and the body
	lda #kBoss.hitPointsOctopuss
	sta EntityData.active,x								; and use active for the number of hit points
	lda #kDefault_OBSEL|kBossOctoBankOR				; enable the bear boss sprite bank
	jmp _sharedBoss

.as
.xs
setEntitySprites
_ASSERT_jsr
_ASSERT_axy8
	ldx EntityData.number								; do we have any
	beq _exit
	_active
		stx CurrentEntity
		lda EntityData.type,x							; what type is it
		cmp #kEntity.bear
		beq _bossBear										; handle boss sprites
			cmp #kEntity.bearBody
			beq _nextEnt									; body is done by main
				cmp #kEntity.octopuss					; handle octoposs 
				beq _bossOctopuss
					cmp #kEntity.octopussBody			; again body is done my main
					beq _nextEnt
		tay
		jsr setEntSpriteForDirection					; set the sprite
	_nextEnt
		dex
		bpl _active
_exit
	lda EntityData.numPipes								; do we have any pipes
	beq _exit2
		ldx EntityData.pipeBubbleStart
		lda #$ff
_loop
	sta mplexBuffer.ypos+kEntsSpriteOffset,x		; set all the bubbles off screen
	inx
	cpx #kEntity.maxEntities
	bne _loop
_exit2
	rts
	;
_bossBear
	#A16
	lda #BearEntAnimData[1]<<8 | BearEntAnimData[0]		; set to frame for head right
	sta EntityData.animBase,x
	lda #BearBodyAnimData[1]<<8 | BearBodyAnimData[0]	; set to frame for body right
	sta EntityData.animBase+2,x
	#A8
	bra _nextEnt

_bossOctopuss
	#A16
	lda #OctopussEntAnimData[1]<<8 |	OctopussEntAnimData[0]		; set to frame for head right
	sta EntityData.animBase,x
	lda #OctopussBodyAnimData[1]<<8 | OctopussBodyAnimData[0]	; set to frame for body right
	sta EntityData.animBase+2,x
	#A8
	bra _nextEnt

.as
.xs
deactivateAllEntities
_ASSERT_jsr
_ASSERT_axy8
	ldx #kEntity.maxEntities-1
-	stz EntityData.active,x
	dex
	bpl -
	rts

.as
.xs
; build hte collision data for each ent first
BuildEntCollisionTable
_ASSERT_jsr
_ASSERT_axy8
	ldx # kEntity.maxEntities-1	; for all possible ents
-
	lda EntityData.active,x			; if it active
	beq +
		jsr MakeMinMaxXYForX			; calc the collision box
+
	dex
	bpl -
	rts

.as
.xs
addYDeltaEnt
_ASSERT_jsr
_ASSERT_axy8
	ldx CurrentEntity
	lda mplexBuffer.ypos+kEntsSpriteOffset,x
	clc
	adc checkSpriteToCharData.yDeltaCheck
	sta mplexBuffer.ypos+kEntsSpriteOffset,x
	rts

.as
.xs
updateEntities
_ASSERT_jsr
_ASSERT_axy8
	ldx #kEntity.maxEntities-1
innerEntitiesLoop
	lda EntityData.active,x												; is it active
	bne EntitiesActive
		lda EntityData.entState,x										; if the state is positive then its dead dead
		bpl updateEntitiesLoop
			cmp #kEntity.deadFromRedBullet							; is this dead dead?
			beq updateEntitiesLoop
				dec EntityData.movTimer,x								; count down the respawn timer
				lda EntityData.movTimer,x
				bne updateEntitiesLoop
					lda EntityData.originalY,x							; put the enemy back in the visible screen
					sta mplexBuffer.yPos+kEntsSpriteOffset,x
					stz EntityData.entState,x							; clear the state
					lda #1
					sta EntityData.active,x								; make it active again
updateEntitiesLoop
	dex
	bpl innerEntitiesLoop
	rts

	.as
.xs
EntitiesActive
	stx CurrentEntity
	lda EntityData.type,x
	asl a
	tax
	jmp (EntUpdateFuncLUT,x)
	; this table needs to be in kEntity order
EntUpdateFuncLUT .word <>(entNormalMovement,springEntFunc,EntNormalMovement,entBat,entGhostFunc,entSpiderFunc,entFishFunc,circlerFunc,entBoss,entBoss,nextEnt,nextEnt,entBubble,nextEnt)

.as
.xs
entNormalMovement								; this if for things that just move and don't stop till dead
_ASSERT_jsr
_ASSERT_axy8
	ldx CurrentEntity
	jsr updateEntAnimAndSetSprite			; updatge the animation
	lda EntityAnimData.collisionBox,y	; y is the ent type
	sta CollideSpriteBoxIndex
	.mConvertXToEntSpriteX					; convert to global x/y pos
	stx CollideSpriteToCheck
	#A16
	lda #<>handleEntCollisionResult		; set the post collision callback
	sta Pointer1
	#A8
	ldx CurrentEntity
	lda EntityData.speed,x					; cache the ent move speed in to y
	tay
	lda EntityData.direction,x				; dispatch based upon direction
	asl a
	tax
	stz CollisionResult
	jmp (ENTDirectionCheckFuncLUT,x)
ENTDirectionCheckFuncLUT .word <>(entRight,entUp,entLeft,entDown)

; this is ent direction per row and then slow,fast delta values
entPositiveTBL		.byte  2, 4
entPositiveTBLUD	.byte  1, 2
entNegativeTBL		.char -2,-4
entNegativeTBLUD	.char -1,-2

entRight
_ASSERT_axy8
	lda entPositiveTBL,y
	sta checkSpriteToCharData.xDeltaCheck
	stz checkSpriteToCharData.xDeltaCheck.hi
	lda #0
	sta checkSpriteToCharData.yDeltaCheck	; set X +ve Y 0
	sta checkSpriteToCharData.yDeltaCheck.hi
entRightNoDelta
_ASSERT_axy8
	jsr newCollision								; check it against the world
	lda CollideCharTRC							; get the Top right character
	jsr checkSolidTile							; is that solid?
	rol CollisionResult							; store the C flag into the result
	lda CollideCharBRC							; get the Bottom right character
	jsr checkSolidTile							; is that solid?
	rol CollisionResult							; store the C flag into the result so we have both
	jmp (Pointer1)									; call the callback

entUp
_ASSERT_axy8
	stz checkSpriteToCharData.xDeltaCheck
	stz checkSpriteToCharData.xDeltaCheck.hi
	lda entNegativeTBLUD,y
	sta checkSpriteToCharData.yDeltaCheck	; set X 0 Y -ve
	lda #$ff
	sta checkSpriteToCharData.yDeltaCheck.hi
entUpNoDelta
_ASSERT_axy8
	jsr newCollision
	lda CollideCharTLC							; check Top Left Char
	jsr checkSolidTile
	rol CollisionResult
	lda CollideCharTRC							; check Top Right Char
	jsr checkSolidTile
	rol CollisionResult
	jmp (Pointer1)

entLeft
_ASSERT_axy8
	lda entNegativeTBL,y
	sta checkSpriteToCharData.xDeltaCheck
	lda #$ff
	sta checkSpriteToCharData.xDeltaCheck.hi
	lda #0
	sta checkSpriteToCharData.yDeltaCheck	; set X -ve Y 0
	sta checkSpriteToCharData.yDeltaCheck.hi
entLeftNoDelta
_ASSERT_axy8
	jsr newCollision
	lda CollideCharTLC							; check Top Left Char
	jsr checkSolidTile
	rol CollisionResult
	lda CollideCharBLC							; check Bottom Left Char
	jsr checkSolidTile
	rol CollisionResult
	jmp (Pointer1)

entDown
_ASSERT_axy8
	stz checkSpriteToCharData.xDeltaCheck
	stz checkSpriteToCharData.xDeltaCheck.hi
	lda entPositiveTBLUD,y
	sta checkSpriteToCharData.yDeltaCheck	; set X - Y +ve
	stz checkSpriteToCharData.yDeltaCheck.hi
entDownNoDelta
_ASSERT_axy8
	jsr newCollision
	lda CollideCharBLC							; check Bottom Left Char
	jsr checkSolidTile
	rol CollisionResult
	lda CollideCharBRC							; check Bottom Right Char
	jsr checkSolidTile
	rol CollisionResult
	jmp (Pointer1)

entFishFunc
_ASSERT_axy8
	ldx CurrentEntity
	dec EntityData.movTimer,x
	lda EntityData.movTimer,x					; time to update ?
	bmi _next
		and #1										; if an even frame skip
		bne _exit
			lda EntityData.entState,x			; if we were moved to have to move faster
			beq _exit
				bra _keepGoing						; move again, aka double the speed
_exit
	jmp NextEnt
	;
_next
	lda #4
	sta EntityData.movTimer,x
_moveFish
	lda EntityData.entState,x					; in ent state
	clc
	adc #1
	cmp #kSinJumpMax								; move to next in table and clamp highest
	bne _storeDirect
		lda #kSinJumpMax-1
_storeDirect
	sta EntityData.entState,x
_keepGoing
	tay
	lda mplexBuffer.ypos+kEntsSpriteOffset,x
	clc
	adc SinJumpTable,y							; add Y up to to the limit
	cmp #kFishLimits.maxY
	bcc _store
		stz EntityData.entState,x				; reset the state
		lda #32
		sta EntityData.movTimer,x				; pause for a bit while you flip
		lda #kFishLimits.maxY
_store
	sta mplexBuffer.ypos+kEntsSpriteOffset,x
	lda EntityData.entState,x					; set the anim frame from table index / 4
	lsr a
	lsr a												; div 4
	cmp #8
	bcc _safe
		lda #7
_safe
	clc
	adc #FishRawAnimData[0]						; use the left frame
	sta EntityData.animBase,x
	stz EntityData.animFrame,x
	jmp nextEnt

entSpiderFunc
_ASSERT_axy8
	ldx CurrentEntity
	lda EntityData.entState,x
	asl a
	tax
	jmp (SpiderEntFuncLUT,x)
SpiderEntFuncLUT .word <> (spiderLookPlayer,spiderFall,spiderRise)

spiderLookPlayer
_ASSERT_axy8
	ldx #0
	stx ZPTemp2
	lda mplexBuffer.xpos
	sta ZPTemp											; store the player X
	ldx CurrentEntity
	.mConvertXToEntSpriteX
	lda mplexBuffer.xpos,x
	sbc ZPTemp
	sta ZPTemp											; my X - playerX
	bcs _left
		cmp #kSpiderValues.rightStartWiggle		; player is to my right but are they in wiggle distance
		bcc +
			lda #1										; yes set animation to wiggle
			sta ZPTemp2
			lda ZPTemp
			cmp #kSpiderValues.rightStartFall	; is it it fall distance
			bcc +
				lda #1
				ldx CurrentEntity
				sta EntityData.entState,x			; set to falling state
	+	lda #kSprites.spiderRight					; no
	_storeSprite
		ldx CurrentEntity
		sta EntityData.animBase,x					; store the animation
		lda ZPTemp2
		beq _noAnim										; are we going to wiggle?
			jsr updateEntAnimAndSetSprite
	_noAnim
		jmp nextEnt
		;
_left
	cmp #kSpiderValues.leftStartWiggle			; left side, are we on the left side
	bcs +
		lda #1
		sta ZPTemp2										; we want wriggle animation
		lda ZPTemp
		cmp #kSpiderValues.leftStartFall			; in fall distance
		bcs +
			lda #1
			ldx CurrentEntity							; go the fall difference
			sta EntityData.entState,x
+	lda #kSprites.spiderLeft						; set to left animation
	bra _storeSprite
	;

spiderFall
_ASSERT_axy8
	ldx CurrentEntity
	jsr updateEntAnimAndSetSprite					; update the animation as we are wiggling
	lda EntityAnimData.collisionBox+kEntity.spider
	sta CollideSpriteBoxIndex						; set the collision as we fall till we hit something
	ldx CurrentEntity
	.mConvertXToEntSpriteX
	stx CollideSpriteToCheck
	stz checkSpriteToCharData.xDeltaCheck
	stz checkSpriteToCharData.xDeltaCheck.hi
	lda #kSpiderValues.yFallDelta
	sta checkSpriteToCharData.yDeltaCheck		; check below me
	jsr newCollision
	lda CollideCharBLC								; is the bottom left char solid
	jsr checkSolidTile								; spiders are tile aligned so if you hit the left you hit the right
	bcc _noColide
	_collide
		lda #2
		ldx CurrentEntity
		sta EntityData.entState,x					; set to the rise state
		lda #kSpiderValues.pauseEndFallFrames
		sta EntityData.movTimer,x					; make it stop for a bit first
		jmp nextEnt
		;
_noColide
	ldx CurrentEntity
	lda mplexBuffer.ypos+kEntsSpriteOffset,x
	cmp #kBounds.screenMaxY-16						; make sure we don't go off the bottom of the screen
	bcs _collide
		jsr addYDeltaEnt
		jmp nextEnt

spiderRise
_ASSERT_axy8
	ldx CurrentEntity
	dec EntityData.movTimer,x
	bpl +
		lda #kSpiderValues.riseDelayTime				; set to the slower rise time
		sta EntityData.movTimer,x
		lda mplexBuffer.ypos+kEntsSpriteOffset,x
		sec
		sbc #1
		sta mplexBuffer.ypos+kEntsSpriteOffset,x	; move up slowly
		cmp EntityData.originalY,x						; until we hit the spawn height
		bne +
			stz EntityData.entState,x					; return to wait state
+	jmp nextEnt

circlerFunc
_ASSERT_axy8
	ldx CurrentEntity
	dec EntityData.movTimer,x							; time to move?
	bmi _cirActive
		jmp nextEnt
_cirActive
	lda #4
	sta EntityData.movTimer,x							; set timer
	lda EntityData.entState,x							; state in this case is circle table index
	ldy CurrentEntity
	tax
	lda CircleJumpTableStart,x
	sta checkSpriteToCharData.xDeltaCheck			; set the x Delta
	bpl +
		lda #$ff
		sta checkSpriteToCharData.xDeltaCheck.hi
		bra ++
+	stz checkSpriteToCharData.xDeltaCheck.hi
+	; add X with MSB offset
	lda mplexBuffer.xpos+kEntsSpriteOffset,y
	clc
	adc checkSpriteToCharData.xDeltaCheck
	sta ZPTemp												; get the new X position
	; xdelta +ve if this is +ve but original was -ve we have gone over
	lda checkSpriteToCharData.xDeltaCheck
	bmi _subbedX
		lda mplexBuffer.xpos+kEntsSpriteOffset,y
		bpl _loadX
			; so last pos in negative >80
			lda ZPTemp
			bmi _storeX
			; new pos is positive 0-80
				lda #1			; enable MSB
				sta mplexBuffer.xmsb+kEntsSpriteOffset,y ; was >80 now <80 gone over 256
				bra _storeX
_subbedX
	; xdelta -ve if this is -ve but original was +ve we have gone over
	lda mplexBuffer.xpos+kEntsSpriteOffset,y
	bmi _loadX
		; last post is positive >80
		lda ZPTemp
		bpl _storeX
			lda #0												; was <80 now > 80 gone under 0
			sta mplexBuffer.xmsb+kEntsSpriteOffset,y	; clear msb
_loadX
_storeX
	lda ZPTemp
	sta mplexBuffer.xpos+kEntsSpriteOffset,y			; set final X position
	; now to do it for the Y
	lda mplexBuffer.ypos+kEntsSpriteOffset,y
	clc
	adc CircleJumpTableStart+(CircleJumpTableCount/4)+1,x	; this is basically COS Theta = SIN Theta+90
	sta mplexBuffer.ypos+kEntsSpriteOffset,y					; the table is longer with repeats to avoid needing to wrap
	ldx CurrentEntity
	lda EntityData.entState,x
	clc
	adc #1
	cmp # CircleJumpTableCount
	bne _cirStore
		lda #0
_cirStore
	sta EntityData.entState,x										; cicle index += 1 and wrap at length
	jsr updateEntAnimAndSetSprite
	jmp nextEnt

springEntFunc
	ldx CurrentEntity
	dec EntityData.movTimer,x										; time to move?
	bmi _move
		jmp nextEnt
		;
_move
	lda #3
	sta EntityData.movTimer,x
	; update Y component
	lda EntityData.entState,x
	sta ZPTemp
	tay
	lda SinJumpTable,y
	sta checkSpriteToCharData.yDeltaCheck						; first we check down on the jump
	stz checkSpriteToCharData.xDeltaCheck
	stz checkSpriteToCharData.xDeltaCheck.hi
	stz CollisionResult
	lda #2																; this might change per frame
	sta CollideSpriteBoxIndex										; it hasn't but that is something you might want to improve
	.mConvertXToEntSpriteX											; current entity
	stx CollideSpriteToCheck
	#A16
	lda #<>springEntYCollideEnd									; set post collision callback
	sta Pointer1
	#A8
	lda ZPTemp
	cmp #kSinJumpFall													; this is the index where the table goes from -ve to +ve
	bcs _falling
		; rising
		lda #kSinJumpFall												; start falling index in case of contact
		sta ZPTemp2
		jmp entUpNoDelta
		;
_falling
	stz ZPTemp2															; hit ground, start jumping
	jmp entDownNoDelta
	;
springEntYCollideEnd
_ASSERT_axy8
	lda CollisionResult
	bne _hit
		jsr collideEntAgainstRest
		bcs _hit
			ldx CurrentEntity											; didn't hit so carry on
			lda mplexBuffer.ypos+kEntsSpriteOffset,x
			;clc
			adc checkSpriteToCharData.yDeltaCheck
			sta mplexBuffer.ypos+kEntsSpriteOffset,x
			lda EntityData.entState,x								; move to next state in the arc
			clc
			adc #1
			cmp #kSinJumpMax											; clamp to max fall speed
			bcc _store
				lda #kSinJumpMax-1
_store
_ASSERT_A_lt_34
	sta EntityData.entState,x
	gra springEntHandleX
	;
_hit
	ldx CurrentEntity
	lda ZPTemp2															; this was set to the target jump index pre coll function
	_ASSERT2_A_lt_34
	sta EntityData.entState,x
springEntHandleX
	stz checkSpriteToCharData.yDeltaCheck						; now Y has been delt with, do the X
	stz CollisionResult
	#A16
	lda #<>springEntXCollideEnd									; set the post collision callback
	sta Pointer1
	#A8
	lda EntityData.direction,x
	sta ZPTemp															; preserve the direction
	clc
	adc #4																; the table is -4 and + 4 values, but indexing is unsinged
	tay																	; so offset by 4 to make it 0 based
	lda SpringDirectionToDeltaLUT,y
	sta checkSpriteToCharData.xDeltaCheck
	bmi _left
		stz checkSpriteToCharData.xDeltaCheck.hi
		jmp entRightNoDelta
		;
_left
	lda #$ff
	sta checkSpriteToCharData.xDeltaCheck.hi
	jmp entLeftNoDelta
	;
springEntXCollideEnd
	ldx CurrentEntity
	lda ZPTemp
	bmi springEntXLeft												; is the preserved direction negative
		lda CollisionResult
		beq _noCollideRight
		_hit
			lda #-1
			ldx CurrentEntity
			sta EntityData.direction,x								; go the other way slowly at first
			bra springEndAnimate
			;
	_noCollideRight
		jsr collideEntAgainstRest									; did we hit any ents?
		bcs _hit
			ldx CurrentEntity
			.mConvertXToEntSpriteX
			jsr addXWithMSBAndClip_88								; didn't hit so move x
			.mRestoreEntSpriteX
			lda DidClipX												; if we clip then we need to go the other way
			beq _noclip
				lda #-1
				bmi _store
		_noclip
			lda EntityData.direction,x								; accelerate right, this gives the spring a sense of interia
			clc
			adc #1
			and #3
		_store
			sta EntityData.direction,x
			gra springEndAnimate
			;
springEntXLeft
	lda CollisionResult
	beq _noCollideLeft
	_hit
		lda #1
		ldx CurrentEntity
		sta EntityData.direction,x									; hit wall, so start moving right slowly
		gra springEndAnimate
		;
_noCollideLeft
	jsr collideEntAgainstRest										; did we hit an ent?
	bcs _hit
		ldx CurrentEntity												; no move on the X
		.mConvertXToEntSpriteX
		jsr addXWithMSBAndClip_88
		.mRestoreEntSpriteX
		lda DidClipX													; did we hit a wall?
		beq _noclip2
			lda #1
			bra _store2													; start going right slowly then
			;
_noClip2
	lda EntityData.direction,x
	sec
	sbc #1
	cmp #256-5															; accelerate left
	bne _store2
		inc a  ;256-4
_store2
	sta EntityData.direction,x
springEndAnimate
	ldx CurrentEntity
	ldy EntityData.entState,x
	lda SpringFrameFrameTable,y
	sta EntityData.animBase,x										; explicty set the frame
	stz EntityData.animFrame,x										; with no offset
	jmp nextEnt
	;

entGhostFunc
_ASSERT_axy8
	ldx CurrentEntity
	#A16
	lda #<>entGhostXResults											; set post collsion callback
	sta Pointer1
	#A8
	.mConvertXToEntSpriteX
	stx CollideSpriteToCheck
	ldx CurrentEntity
	lda EntityData.speed,x
	tay																	; read the speed and prep it for the call
	lda EntityData.direction,x										; read the direction and clamp it if needed
	cmp #4
	bcc +
		lda #0
		sta EntityData.direction,x
	; 0 00= UpRight
	; 1 01= UpLeft
+	and #1
	beq ghostLeft
; ghostRight
		jmp entRight
ghostLeft
	jmp entLeft
	;

entGhostXResults
_ASSERT_axy8
	ldx CurrentEntity
	lda CollisionResult
	beq _addXDelta
	_toggleX
		ldx CurrentEntity
		lda EntityData.ignoreColl,x						; this end moves diagionally, which presents issues forf
		bne _ignoreCollision									; choosing the next move direction, as you can hit a corner
			ora #1												; and need to go both right and down at once
			sta EntityData.ignoreColl,x					; I use ignoreColl to hold collision state to make a final decision
	_toggleXForce
		ldx CurrentEntity
		lda EntityData.direction,x
		eor #1
		sta EntityData.direction,x							; toggle the x oomponent
		jsr setEntSpriteForDirection
		gra entGhostCheckY
		;
_addXDelta
	jsr collideEntAgainstRest								; do we hit an ent?
	bcs _togglex
		ldx CurrentEntity
		lda EntityData.ignoreColl,x
		and #$fe ; clear bit 0
		sta EntityData.ignoreColl,x						; we don't worry about flipping on the x anymore as its an ent
_ignoreCollision
	.mConvertXToEntSpriteX
	jsr addXWithMSBAndClip_88								; update the x
	lda DidClipX												; if we clip, got to flip it
		bne _toggleXForce
entGhostCheckY
	#A16
	lda #<>entGhostYResults									; set the Y post collision pointer
	sta Pointer1
	#A8
	ldx CurrentEntity
	lda EntityData.speed,x
	tay															; cache the speed
	lda EntityData.direction,x								; and dispatch based upon speed
	and #2
; 2 10= DownRight
; 3 11= DownLeft
	bne _down
	; up
	gra entUp
_down
	gra entDown
	;
entGhostYResults
_ASSERT_axy8
	ldx CurrentEntity
	lda CollisionResult
	beq _entGhostCheckSprites
	_toggleY
		ldx CurrentEntity
		lda EntityData.ignoreColl,x
		bne _ignoreCollision								; if we already changed
			ora #2
			sta EntityData.ignoreColl,x				; set to make sure we don't again
			lda EntityData.direction,x					; toggle the y
			eor #2
			sta EntityData.direction,x
	_entHitAndGoNext
		gra nextEnt
_entGhostCheckSprites
	jsr collideEntAgainstRest							; did we hit another ent?
	bcs _toggleY											; force toggle
		ldx CurrentEntity
		lda EntityData.ignoreColl,x					; no, clear the lock flag then
		and #%11111101
		sta EntityData.ignoreColl,x
_ignoreCollision
	jsr addYDeltaEnt
	jsr updateEntAnimAndSetSprite
	gra nextEnt

entBat
_ASSERT_axy8
	ldx CurrentEntity											; we check to see if we can fall down
	lda EntityAnimData.collisionBox+kEntity.bat		; this might change per frame
	sta CollideSpriteBoxIndex
	.mConvertXToEntSpriteX									; current entity
	stx CollideSpriteToCheck
	#A16
	lda #<>entBatYResults									; set post collision callback
	sta Pointer1
	#A8
	ldy #1														; fall fast
	gra entDown
	;
entBatYResults
	ldx CurrentEntity
	lda CollisionResult
	bne _dontFall
		jsr addYDeltaEnt										; yes update Y
_dontFall
	jmp entNormalMovement									; jump to normal left right update


handleEntCollisionResult
_ASSERT_axy8
	ldx CurrentEntity
	lda CollisionResult										; did we hit something
	beq _addDeltas												; no add deltas and away we go
		bra _skipIgnore										; yes well react to it
	;
_entHitAndGoNext
	ldx CurrentEntity
	lda EntityData.ignoreColl,x							; does this have ignore flags
	bne _ignoreCollision
		lda #4
		sta EntityData.ignoreColl,x						; set ignore collision, this is so they don't stick together
_skipIgnore
	jsr setNextEntDir
	gra nextEnt
	;
_addDeltas
	jsr collideEntAgainstRest
	bcs _entHitAndGoNext
		ldx CurrentEntity
		lda EntityData.ignoreColl,x
		beq _ignoreCollision
			sec													; hasn't collided so clear flag
			sbc #1
			sta EntityData.ignoreColl,x					; countdown ignore
_ignoreCollision
	jsr addYDeltaEnt											; will set X to current Ent
	.mConvertXToEntSpriteX
	jsr addXWithMSBAndClip_88
	lda DidClipX
	beq _skipFlipDueToX
		lda mplexBuffer.xpos,x								; x was increased above
		sec
		sbc checkSpriteToCharData.xDeltaCheck			; undo the move
		sta mplexBuffer.xpos,x
		jsr setNextEntDir
_skipFlipDueToX
nextEnt
	ldx CurrentEntity
	jmp updateEntitiesLoop

entBubble
_ASSERT_axy8
	ldx CurrentEntity
	lda mplexBuffer.ypos+kEntsSpriteOffset,x			; bubbles move up
	sec
	sbc #1
	cmp #240														; have we reached off the top of the screen
	bne _safe
		stz EntityData.active,x
		lda #kSpriteEmptyVal									; disable sprite
_safe
	sta mplexBuffer.ypos+kEntsSpriteOffset,x
	jsr updateEntAnimAndSetSprite
	gra nextEnt
	;

setNextEntDir
_ASSERT_axy8
	jsr getEntTableIndex
	lda NextDirectionLUT,y									; look up the direction based upon current direction
	sta EntityData.direction,x
	ora ZPTemp													; add the ent type offset to it
	tay
	gra setEntFrameForDir									; update the animation
	;

setEntSpriteForDirection
_ASSERT_jsr
_ASSERT_axy8
	jsr getEntTableIndex
	; fall through
setEntFrameForDir
_ASSERT_axy8
	lda BaseAnimeFrameForDir,y
	sta EntityData.animBase,x
	rts

getEntTableIndex
_ASSERT_jsr
_ASSERT_axy8
	ldx CurrentEntity
	lda EntityData.type,x				; newDirection = table[ent*4+direction]
	asl a
	asl a
	sta ZPTemp
	ora EntityData.direction,x
	tay
	rts

updateEntAnimAndSetSprite
_ASSERT_jsr
_ASSERT_axy8
	lda EntityData.type,x						; get the type for latter
	tay
	inc EntityData.animTimer,x					; inc frame timer
	lda EntityData.animTimer,x
	cmp EntityAnimData.frameRate,y
	bne _notAnimUpdate							; nope rts
		stz EntityData.animTimer,x				; clear timer
		inc EntityData.animFrame,x				; inc and loop frame if needed
		lda EntityData.animFrame,x
		cmp EntityAnimData.frameCount,y
		bne _notAnimUpdate
			stz EntityData.animFrame,x
_notAnimUpdate
	rts


updateBubbles
_ASSERT_jsr
_ASSERT_axy8
	ldx EntityData.numPipes								; does this level have any bubble spawners?
	beq _exit
		lda TickDowns.bubbleTimer
		bne _exit
			ldx EntityData.pipeBubbleStart			; run through the ents looking for a free slot to use
_findFreeEnt
	lda EntityData.active,x
	beq _foundOne
		inx
		cpx EntityData.number
		bne _findFreeEnt
			bra _exit										; no free slots
_foundOne
	stx ZPTemp2												; bubble ent number
	lda #1
	sta EntityData.active,x								; mark it active
	ldy EntityData.lastPipeUsed
	lda EntityData.pipeIndex,y
	jsr convertIndexToEntSpriteXY						; spawn at the next pipe
	lda mplexBuffer.xpos+kEntsSpriteOffset,x		; bubbles are 24 wide so -4 from spawn pos to centre it
	sec
	sbc #4
	sta mplexBuffer.xpos+kEntsSpriteOffset,x
	bcs +
		lda #3
		sta mplexBuffer.xmsb+kEntsSpriteOffset,x	; handle MSB which is important for the fist slot only
+	lda #kTimers.spawnBubble
	sta TickDowns.bubbleTimer							; reset the timer
	lda EntityData.lastPipeUsed
	clc
	adc #1
	cmp EntityData.numPipes								; move to the next pipe
	bne _store
		lda #0												; wrap as needed
_store
	sta EntityData.lastPipeUsed
_exit
	rts

entBoss
_ASSERT_axy8
	ldx CurrentEntity
	lda EntityData.entState,x
	asl a
	tax
	jmp (BossLUT,x)
BossLut .word <>(BossNormal,BossDeath)

BossNormal
_ASSERT_axy8
	ldx CurrentEntity
	lda EntityData.movTimer+1,x											; Ent + 1 timer is used as a flash timer
	beq _notFlash
		dec EntityData.movTimer+1,x
		bne _notFlash
			#A16
			stz EntityData.palleteOffset,x								; clear palette shift on all 4 sub ents
			stz EntityData.palleteOffset+2,x
			#A8
_notFlash
	jsr AnimateUpperHalfBoss												; make it look left or right for player tracking
	dec EntityData.movTimer,x												; time to move?
	beq _doneMove
		lda EntityData.movTimer,x											; the boses move and pause and move the pause
		cmp #16																	; bears are 50/50 while the octopus is 66/33
		bcs _noMove
			jsr AnimateLowerHalfBoss
			lda EntityData.direction,x
			bne _left
				dec mplexBuffer.xpos+kEntsSpriteOffset,x
				dec mplexBuffer.xpos+kEntsSpriteOffset+1,x
				dec mplexBuffer.xpos+kEntsSpriteOffset+2,x
				dec mplexBuffer.xpos+kEntsSpriteOffset+3,x		; move all 4 sub ents left
				lda mplexBuffer.xpos+kEntsSpriteOffset,x
				; cmp #kBounds.screenMinX this is now 0
				.cerror kBounds.screenMinX != 0, "put cmp back"
				bne _noMove
				_toggleDir
					lda EntityData.direction,x
					eor #2														; switch from 0 & 2
					sta EntityData.direction,x
					bra _noMove
	_left
		inc mplexBuffer.xpos+kEntsSpriteOffset,x
		inc mplexBuffer.xpos+kEntsSpriteOffset+1,x					; move all 4 sub ents right
		inc mplexBuffer.xpos+kEntsSpriteOffset+2,x
		inc mplexBuffer.xpos+kEntsSpriteOffset+3,x
		lda mplexBuffer.xpos+kEntsSpriteOffset+1,x					; get the Top Right sprite
		cmp #$ff-24  
		beq _toggleDir
			bra _noMove
_doneMove
	ldy EntityData.type,x
	lda BossMoveTimerLut - kEntity.bear,y							; octopuss is the next ent after the bear so '- bear'
	sta EntityData.movTimer,x											; make y effectily 0 or 1
_noMove
	jmp nextEnt

BossMoveTimerLut .byte 32,24

BossDeath
_ASSERT_jsr
_ASSERT_axy8
	ldx CurrentEntity
	dec mplexBuffer.ypos+kEntsSpriteOffset,x
	dec mplexBuffer.ypos+kEntsSpriteOffset+1,x					; left sprites to the left
	inc mplexBuffer.ypos+kEntsSpriteOffset+2,x					; right sprites to the right
	inc mplexBuffer.ypos+kEntsSpriteOffset+3,x
	dec mplexBuffer.xpos+kEntsSpriteOffset,x						; upper sprites up
	dec mplexBuffer.xpos+kEntsSpriteOffset+2,x
	inc mplexBuffer.xpos+kEntsSpriteOffset+1,x					; bottom sprites down
	inc mplexBuffer.xpos+kEntsSpriteOffset+3,x
	dec EntityData.movTimer,x											; time up?
	bne _exit
		#A16
		stz EntityData.active,x											; disable all 4 sprites
		stz EntityData.active+2,x
		lda #kSpriteEmptyVal<<8|kSpriteEmptyVal
		sta mplexBuffer.ypos+kEntsSpriteOffset,x					; put them offscreen
		sta mplexBuffer.ypos+kEntsSpriteOffset+2,x
		#A8
_exit
	jmp nextEnt

AnimateLowerHalfBoss
_ASSERT_jsr
_ASSERT_axy8
	dec EntityData.animTimer,x											; first ent sprite is the anim timer
	bne _exit
		lda #4
		sta EntityData.animTimer,x
		lda EntityData.animFrame+2,x									; toggle the anim frame number for the lower
		eor #1																; two ents
		sta EntityData.animFrame+2,x
		sta EntityData.animFrame+3,x
_exit
	rts

;<<<<<24--0--24>>>>>
AnimateUpperHalfBoss
_ASSERT_jsr
_ASSERT_axy8
	stx ZPTemp
	.mConvertXToEntSpriteX
	lda mplexBuffer.xpos,x
	sta ZPTemp2							; Ent's X pos
	lda mplexBuffer.xpos				; player
	sta ZPTemp3							; Player's X pos
	cmp ZPTemp2							; Ent's X pos
	bcc _playerLeft
		sbc ZPTemp2						; carry is already set
		cmp #24							; if PlayerX - EntX  < 24
		bcc _under
			lda #2						; look right
			.byte $2c					; bit XXXX
	_under
		lda #1							; look straight ahead
		.byte $2c						; bit XXXX
_playerLeft
	lda #0								; look left
	ldx ZPTemp							; the ent number we called it with
	sta EntityData.animFrame,x		; set both upper sprites to the frame
	sta EntityData.animFrame+1,x
	rts

.as
.xs
isTypeBoss
; return C = 0 for not and C = 1 for is
_ASSERT_jsr
_ASSERT_axy8
	cmp #kEntity.bear					; is there a bear in there?
	bcc _notBoss
	cmp #kEntity.octopussBody+1	; well is the number <bear or >OctopussBody
	bcc _boss
	cmp #kEntity.bossDummy			; and not the dummy?
	beq _boss
_notBoss
		clc
		rts
_boss
	sec
	rts

.as
.xs
isTypeBossBounceDetect
; bounce detection is handled by the collision rect of only 1 of the 4
; so we need to get just bear or just ocotpuss and not the other 3
; C = 0 yes, C = 1 no
_ASSERT_jsr
_ASSERT_axy8
	cmp #kEntity.bear
	beq _yes
		cmp #kEntity.octopuss
		beq _yes
			clc
			rts
_yes
	sec
	rts

.as
.xs
hurtBoss
_ASSERT_jsr
_ASSERT_axy8
	lda EntityData.entState,x				; can't hurt if it already dead
	cmp #kBoss.dead
	beq _exit
		lda EntityData.movTimer+1,x		; the flash acts a count down, other wise if you have the shield you can 
		bne _exit								; jump into body, get pushed up and Quick Kill them in one jump
			dec EntityData.active,x			; this is abused to hold "life points"
			lda EntityData.active,x
			cmp #1								; 1 is "dead" as the must remain active for the death animation
			beq _killedBoss
				; we need to flash them so the player knows they did something
				#A16
				lda #kSPal_1<<8|kSPal_1		; next pal
				sta EntityData.palleteOffset,x
				sta EntityData.palleteOffset+2,x
				#A8
				lda #16							; store the flash timer in the 2nd sprite
				sta EntityData.movTimer+1,x 
_exit
	rts
_killedBoss										; well just killed the boss
	lda #kBoss.dead
	sta EntityData.entState,x				; got to death state
	lda #kBoss.deathAnimTime
	sta EntityData.movTimer,x				; set death animation timer
	stx ZPTemp
	lda #kScoreIndex.boss					; award points
	jsr giveScore
	ldx ZPTemp									; restore X, which holds the current ent number
	rts

kESprFlags = kSPri_2|kSPal_0

; ----- @Entity Data@ -----

; fSprDef takes a sprite 16x16 grid x,y and the attributes data and makes a "word" for OAM bytes 3 and 4
; note newer versions of 64tass don't support multiline so keep each def on one line
HeliRawFrames = (fSprDef(0,4,kESprFlags),fSprDef(1,4,kESprFlags),fSprDef(2,4,kESprFlags),fSprDef(3,4,kESprFlags),fSprDef(0,5,kESprFlags),fSprDef(1,5,kESprFlags),fSprDef(2,5,kESprFlags),fSprDef(3,5,kESprFlags))
allEntFrames := HeliRawFrames
							; ent frames index left
								; ent frames index right
									; number of frames
										; anim frame rate
											; anim frame size
												; collision bounding box index
; heli only has 1 8 frame animation for all directions
HeliRawAnimData =  (0,0,len(HeliRawFrames),8,kSpriteType.s16x16,0)

SpringRawFrames = (fSprDef(6,2,kESprFlags),fSprDef(7,2,kESprFlags),fSprDef(4,4,kESprFlags),fSprDef(5,4,kESprFlags),fSprDef(6,4,kESprFlags),fSprDef(7,4,kESprFlags),fSprDef(4,6,kESprFlags),fSprDef(5,6,kESprFlags))
; again the spring is a rather complex entity that transends left and right concepts
SpringRawAnimData = (len(allEntFrames),len(allEntFrames),len(SpringRawFrames),2,kSpriteType.s16x32,0)
allEntFrames ..= SpringRawFrames

;the worm has a Left and a Right set
WormRawFramesLeft = (fSprDef(0,6,kESprFlags),fSprDef(1,6,kESprFlags),fSprDef(2,6,kESprFlags),fSprDef(3,6,kESprFlags))
WormRawFramesRight = (fSprDef(0,7,kESprFlags),fSprDef(1,7,kESprFlags),fSprDef(2,7,kESprFlags),fSprDef(3,7,kESprFlags))

WormRawAnimData = (len(allEntFrames), len(allEntFrames)+len(WormRawFramesLeft),len(WormRawFramesLeft),8,kSpriteType.s16x16,0)
allEntFrames ..= WormRawFramesLeft
allEntFrames ..= WormRawFramesRight

BatRawAnimDataLeft = (fSprDef(0,8,kESprFlags),fSprDef(1,8,kESprFlags),fSprDef(2,8,kESprFlags),fSprDef(3,8,kESprFlags))
BatRawAnimDataRight = (fSprDef(0,8,kESprFlags|kSFlipX),fSprDef(1,8,kESprFlags|kSFlipX),fSprDef(2,8,kESprFlags|kSFlipX),fSprDef(3,8,kESprFlags|kSFlipX))
BatRawAnimData = (len(allEntFrames), len(allEntFrames)+len(BatRawAnimDataLeft),len(BatRawAnimDataLeft),8,kSpriteType.s16x16,0)
allEntFrames ..= BatRawAnimDataLeft
allEntFrames ..= BatRawAnimDataRight

GhostRawFramesLeft = (fSprDef(0,9,kESprFlags),fSprDef(1,9,kESprFlags),fSprDef(2,9,kESprFlags),fSprDef(3,9,kESprFlags))
GhostRawFramesRight = (fSprDef(0,9,kESprFlags|kSFlipX),fSprDef(1,9,kESprFlags|kSFlipX),fSprDef(2,9,kESprFlags|kSFlipX),fSprDef(3,9,kESprFlags|kSFlipX))
GhostRawAnimData = (len(allEntFrames), len(allEntFrames)+len(GhostRawFramesLeft),len(GhostRawFramesLeft),8,kSpriteType.s16x16,0)
allEntFrames ..= GhostRawFramesLeft
allEntFrames ..= GhostRawFramesRight

; spider needs 4 animations, for waiting and for falling.
; I could be tempted to make the falling the next entity type to keep the structure
; however can't be bothered to change the code too much, just going to make a define
; to handle the offset
SpiderRawFramesWaitLeft = (fSprDef(0,10,kESprFlags),fSprDef(1,10,kESprFlags))
SpiderRawFramesWaitRight = (fSprDef(2,10,kESprFlags),fSprDef(3,10,kESprFlags))
SpiderRawFramesFallLeft = (fSprDef(0,11,kESprFlags),fSprDef(1,11,kESprFlags))
SpiderRawFramesFallRight = (fSprDef(2,11,kESprFlags),fSprDef(3,11,kESprFlags))
SpiderRawAnimData = (len(allEntFrames), len(allEntFrames)+len(SpiderRawFramesWaitLeft),len(SpiderRawFramesWaitLeft),8,kSpriteType.s16x16,0)
allEntFrames ..= SpiderRawFramesWaitLeft
allEntFrames ..= SpiderRawFramesWaitRight
allEntFrames ..= SpiderRawFramesFallLeft
allEntFrames ..= SpiderRawFramesFallRight
kSpiderFallAnimOffset = len(SpiderRawFramesWaitLeft) + len(SpiderRawFramesWaitRight)

FishRawFramesUp = (fSprDef(0,12,kESprFlags),fSprDef(1,12,kESprFlags),fSprDef(2,12,kESprFlags),fSprDef(3,12,kESprFlags))
FishRawFramesDown = (fSprDef(0,13,kESprFlags),fSprDef(1,13,kESprFlags),fSprDef(2,13,kESprFlags),fSprDef(3,13,kESprFlags))
FishRawAnimData = (len(allEntFrames), len(allEntFrames)+len(FishRawFramesUp), len(FishRawFramesUp),1,kSpriteType.s16x16,0)
allEntFrames ..= FishRawFramesUp
allEntFrames ..= FishRawFramesDown

CirclerRawFramesLeft = (fSprDef(0,14,kESprFlags),fSprDef(1,14,kESprFlags),fSprDef(2,14,kESprFlags),fSprDef(3,14,kESprFlags))
CirclerRawFramesRight = (fSprDef(0,15,kESprFlags),fSprDef(1,15,kESprFlags),fSprDef(2,15,kESprFlags),fSprDef(3,15,kESprFlags))
CirclerRawAnimData = (len(allEntFrames), len(allEntFrames)+len(CirclerRawFramesLeft),len(CirclerRawFramesLeft),2,kSpriteType.s16x16,0)
allEntFrames ..= CirclerRawFramesLeft
allEntFrames ..= CirclerRawFramesRight

BearRawFramesLeft = (fSprDef(0,16,kESprFlags),fSprDef(2,16,kESprFlags),fSprDef(4,16,kESprFlags))
BearRawFramesRight = (fSprDef(6,16,kESprFlags),fSprDef(0,18,kESprFlags),fSprDef(2,18,kESprFlags))
BearEntAnimData = (len(allEntFrames), len(allEntFrames)+len(BearRawFramesLeft),len(BearRawFramesLeft),4,kSpriteType.s32x32,4)
allEntFrames ..= BearRawFramesLeft
allEntFrames ..= BearRawFramesRight

OctopussRawFramesLeft = (fSprDef(0,24,kESprFlags),fSprDef(2,24,kESprFlags),fSprDef(4,24,kESprFlags))
OctopussRawFramesRight = (fSprDef(6,24,kESprFlags),fSprDef(0,26,kESprFlags),fSprDef(2,26,kESprFlags))
OctopussEntAnimData = (len(allEntFrames), len(allEntFrames)+len(OctopussRawFramesLeft),len(OctopussRawFramesLeft),4,kSpriteType.s32x32,4)
allEntFrames ..= OctopussRawFramesLeft
allEntFrames ..= OctopussRawFramesRight

BearBodyRawFramesLeft = (fSprDef(4,18,kESprFlags), fSprDef(6,18,kESprFlags))
BearBodyRawFramesRight = (fSprDef(0,20,kESprFlags), fSprDef(2,20,kESprFlags))
BearBodyAnimData = (len(allEntFrames), len(allEntFrames)+len(BearBodyRawFramesLeft),len(BearBodyRawFramesLeft),4,kSpriteType.s32x32,5)
allEntFrames ..= BearBodyRawFramesLeft
allEntFrames ..= BearBodyRawFramesRight

OctopussBodyRawFramesLeft = (fSprDef(4,26,kESprFlags), fSprDef(6,26,kESprFlags))
OctopussBodyRawFramesRight = (fSprDef(0,28,kESprFlags), fSprDef(2,28,kESprFlags))
OctopussBodyAnimData = (len(allEntFrames), len(allEntFrames)+len(OctopussBodyRawFramesLeft),len(OctopussBodyRawFramesLeft),4,kSpriteType.s32x32,5)
allEntFrames ..= OctopussBodyRawFramesLeft
allEntFrames ..= OctopussBodyRawFramesRight

BubbleRawFrames = (fSprDef(4,8,kESprFlags), fSprDef(6,8,kESprFlags), fSprDef(4,10,kESprFlags))
BubbleAnimData = (len(allEntFrames),len(allEntFrames),len(BubbleRawFrames),12,kSpriteType.s32x32,7)
allEntFrames ..= BubbleRawFrames
; this one doesn't matter so much, its more for the collision frame number which is basically blowing a lot of bytes for one, but oh well
BossDummyAnimData = (len(allEntFrames),len(allEntFrames),len(BearBodyRawFramesLeft),12,kSpriteType.s32x32,6)

;this has to be in kEntity order
; older 64tass versions let you spread a single define across multiple lines
; newer versions removed this feature so I'm using := and ..= to split over multiple lines
AllAnimData  := (HeliRawAnimData,SpringRawAnimData,WormRawAnimData,BatRawAnimData)
AllAnimData ..= (GhostRawAnimData,SpiderRawAnimData,FishRawAnimData,CirclerRawAnimData)
AllAnimData ..= (BearEntAnimData,OctopussEntAnimData,BearBodyAnimData,OctopussBodyAnimData)
AllAnimData ..= (BubbleAnimData,BossDummyAnimData)

EntityFrameData .block
	lo .byte <(allEntFrames)						; this is 3rd byte of OAM for each frame
	hi .byte >(allEntFrames)						; this is 4th byte of OAM for each frame
.bend

EntityAnimData .block
	frameCount		.byte (AllAnimData[:,2])	; number of frames each animation has
	frameRate		.byte (AllAnimData[:,3])	; the rate for the animation
	frameSize		.byte (AllAnimData[:,4])	; the sprite size for the animation
	collisionBox	.byte (AllAnimData[:,5])	; the index in collisionboxes this animation wants
.bend

kSprites .block
	fish				= AllAnimData[kEntity.fish,0]			; the anim frame data index for the start of the fish frames
	spiderLeft		= AllAnimData[kEntity.spider,0]		; like wise for spider left
	spiderRight		= AllAnimData[kEntity.spider,1]
	springNormal	= AllAnimData[kEntity.spring,0]
	springCompress = AllAnimData[kEntity.spring,0]+1
	springExpand	= AllAnimData[kEntity.spring,0]+2
	springFull		= AllAnimData[kEntity.spring,0]+3
	springFall		= AllAnimData[kEntity.spring,0]+4
	bubbles			= AllAnimData[kEntity.bubble,0]
	bulletSprite	= 0											; these are frame deltas for parts of the bullet
	bulletSplat		= 3*2
	bulletRed		= 4*2											; convert to word index
.bend

SpringDirectionToDeltaLUT
.char -2,-1,-1,-1, 1, 1, 1, 2									; this is the springs X deltas, used to give it a sense of intertia

SinJumpTable														; this is the sin table the springs use to jump
.char -5, -5, -4, -4, -5, -3
.char -4, -3, -2, -3, -1, -2, -1, 0, -1, -1, 0
kSinJumpFall = * - SinJumpTable								; this is the index the table flips from up to down
.char  1,  2,  1,  3,  2,  3,  4
.char  3,  5,  4,  5,  6,  5, 6,  6, 7, 8, 8
kSinJumpMax = * - SinJumpTable - 1

SpringFrameFrameTable											; this is the frame it should use for said index into the sin table
.byte kSprites.(springCompress,springCompress,springCompress,springCompress,springCompress)
.byte kSprites.(springExpand,springExpand,springExpand,springExpand,springNormal,springNormal,springFull,springFull,springFull,springFull,springFull)
.byte kSprites.(springFall,springFall,springFall,springFall,springFall,springFall,springFall)+(0,1,2,3,2,1,0)
.byte kSprites.(springFull,springFull,springFull,springFull,springFull,springFull,springFull,springFull,springFull,springFull,springFull)
.cerror (*-SpringFrameFrameTable) != kSinJumpMax, "under by " , kSinJumpMax-(*-SpringFrameFrameTable)

; this is the table used by the circler to go in a circle
CircleJumpTableStart
.char  5, 5, 5, 5, 4, 4, 4, 3, 2, 2, 1, 1, 0,-1,-1,-2,-2,-3,-4,-4,-4,-5,-5,-5,-5
.char -5,-5,-5,-4,-4,-4,-3,-3,-2,-1,-1, 0, 1, 1, 2, 3, 3, 4, 4, 4, 5, 5, 5
CircleJumpTableCount = * - CircleJumpTableStart	; table ends here
.char  5, 5, 5, 5, 4, 4, 4, 3, 2, 2, 1, 1, 0		; duplicate to save wrapping the index on the phase shift
																; the code would be smaller but since this is idential it compresses better than 

; given my current direction, and I hit something which way do I go next
; i.e heli going up with index of 1 is to go 3 which is down while heli 3 returns 1
NextDirectionLUT
.byte 3,3,1,1 ; heli
.byte 0,0,0,0 ; spring
.byte 2,2,0,0 ; worm
.byte 2,2,0,0 ; bat
.byte 3,0,1,2 ; ghost
.byte 3,3,1,1 ; spider
.byte 0,0,0,0 ; fish - not used
.byte 0,0,0,0 ; flying thing - not used
BaseAnimeFrameForDir
; 0 = right, 1 = up, 2 = left, 3 = down
.byte HeliRawAnimData[0],		HeliRawAnimData[0],		HeliRawAnimData[0],		HeliRawAnimData[0]		; heli
.byte SpringRawAnimData[0],	SpringRawAnimData[0],	SpringRawAnimData[0],	SpringRawAnimData[0]		; spring
.byte WormRawAnimData[1],		WormRawAnimData[1],		WormRawAnimData[0],		WormRawAnimData[0]		; worm
.byte BatRawAnimData[1],		BatRawAnimData[1],		BatRawAnimData[0],		BatRawAnimData[0]			; bat
.byte GhostRawAnimData[0],		GhostRawAnimData[1],		GhostRawAnimData[0],		GhostRawAnimData[1]		; ghost
.byte SpiderRawAnimData[0],	SpiderRawAnimData[0],	SpiderRawAnimData[0],	SpiderRawAnimData[0]		; spider
.byte FishRawAnimData[0],		FishRawAnimData[0],		FishRawAnimData[1],		FishRawAnimData[1]		; fish
.byte CirclerRawAnimData[1],	CirclerRawAnimData[1],	CirclerRawAnimData[0],	CirclerRawAnimData[0]	; flying thing
.byte 0,0,0,0 ; bear
.byte 0,0,0,0 ; other bear
.byte 0,0,0,0 ; octopus
.byte 0,0,0,0 ; other octopus
.byte BubbleAnimData[0],		BubbleAnimData[0],		BubbleAnimData[0],		BubbleAnimData[0]			; bubble


; ----- @Collision system@ -----


.as
.xs
checkSpriteToCharCollision_88
_ASSERT_JSR
_ASSERT_axy8
	#A16
	lda checkSpriteToCharData.yDeltaCheck
	sta checkSpriteToCharData.yDeltaBackup
	lda checkSpriteToCharData.xDeltaCheck
	sta checkSpriteToCharData.xDeltaBackup			; cache the deltas
	stz checkSpriteToCharData.xDeltaCheck			; check just Y first
	#A8
	stz CollideSpriteToCheck
	stz CollideSpriteBoxIndex							; clear results
	jsr CSTCCY												; Check Sprite To Char Collision Y
	lda CollideCharBLI									; get bottom left index
	sta ActiveTileIndex
	lda CollideCharBLC									; and the actual tile
	sta ActiveTile
	jsr checkOnDissTile									; do I stand on a diss tile?
	lda CollideCharBLI
	cmp CollideCharBRI									; are both sides of me on the same tile
	beq _otherIsSame										; so we don't diss twice as fast sometimes
		lda CollideCharBRI								; no check the right index as well
		sta ActiveTileIndex
		lda CollideCharBRC
		sta ActiveTile
		jsr checkOnDissTile
_otherIsSame
	#A16
	lda checkSpriteToCharData.xDeltaBackup			; Y done, lets check the X
	sta checkSpriteToCharData.xDeltaCheck			; restore X
	stz checkSpriteToCharData.yDeltaCheck			; clear Y
	#A8
	jsr CSTCCX												; Check Sprite To Char Collision X
	#A16
	lda checkSpriteToCharData.yDeltaBackup			; restore Y
	sta checkSpriteToCharData.yDeltaCheck
	#A8
	ldx CollideCharTLI
	lda CollideCharTLC
	jsr checkActionTile									; is the Top Left an action tile?
	lda CollideCharTRI
	cmp CollideCharTLI									; is top right and top left the same tile?
	beq _skipTR
		tax
		lda CollideCharTRC
		jsr checkActionTile								; no check the right one as well
_skipTR
	lda CollideCharBLI									; check bottom left if different
	cmp CollideCharTLI
	beq _skipBL
		tax
		lda CollideCharBLC
		jsr checkActionTile
_skipBL
	lda CollideCharBRI
	cmp CollideCharTRI									; check bottom right if different
	beq _skipBR
		cmp CollideCharBLI
		beq _skipBR
			tax
			lda CollideCharBRC
			jsr checkActionTile
_skipBR
	rts

.as
.xs
CSTCCY															; Check Sprite To Char Collision Y
_ASSERT_jsr
_ASSERT_axy8
	ldx #0
	stx ZPTemp													; clear the 4 tile solid flags
	stx ZPTemp2
	stx ZPTemp3
	stx ZPTemp4
	ldy #0
	jsr newCollision											; perform collsion
	lda CollideCharTLC
	jsr checkSolidTile
	rol ZPTemp													; roll the C into variable
	lda CollideCharTRC
	jsr checkSolidTile										; C = 0 clear, C = 1 solid
	rol ZPTemp2
	lda CollideCharBLC
	jsr checkSolidTile
	rol ZPTemp3
	lda CollideCharBRC
	jsr checkSolidTile
	rol ZPTemp4													; for all 4
	lda checkSpriteToCharData.yDeltaCheck
	bpl _checkDown
		; check up
		lda ZPTemp
		ora ZPTemp2												; if top left or top right
		beq _exit												; if nothing solid 0 
			; abort jump
			lda PlayerData.hitBubbleNum					; unless I hit a bubble
			beq _startFall										; at which point just start falling
				stz checkSpriteToCharData.yDeltaBackup	; clear the Y delta in this case
				rts
				;
	_startFall
		lda #1
		sta PlayerData.isFallingNZ							; set falling
		inc a ;  #2
		sta PlayerData.yDeltaAccum.lo						; set delta to 2.0078125 aka 2
		sta PlayerData.yDeltaAccum.hi
		rts
		;
	_onGround
		stz checkSpriteToCharData.yDeltaBackup			; can't fall anymore
		stz checkSpriteToCharData.yDeltaCheck
		jmp enterOnGround
		;
_checkDown
	lda PlayerData.hitBubbleNum							; is it a bubble
	bne _exit
		lda ZPTemp3												; no
		ora ZPTemp4												; check bottom two
		bne _onGround											; if solid stand on ground
			ldx PlayerData.OnGroundNZ
			stz PlayerData.OnGroundNZ						; if we were on the ground, i.e just walked off the ledge
			cpx #0
			bne _startFall										; we need to start falling
_exit
	rts

.as
.xs
CSTCCX													; Check Sprite To Char Collision X
_ASSERT_jsr
_ASSERT_axy8
	ldx #0
	stx ZPTemp
	stx ZPTemp2
	stx ZPTemp3
	stx ZPTemp4											; clear the solid char flags
	ldy #0
	jsr newCollision									; do collision
	lda CollideCharTLC								; check if each point is solid and store in ZP Temps
	jsr checkSolidTile								; C = 0 not solid, C = 1 solid
	rol ZPTemp
	lda CollideCharTRC
	jsr checkSolidTile
	rol ZPTemp2
	lda CollideCharBLC
	jsr checkSolidTile
	rol ZPTemp3
	lda CollideCharBRC
	jsr checkSolidTile
	rol ZPTemp4
	lda checkSpriteToCharData.xDeltaCheck		; do I actually want to move sidways?
	beq _exit
	bpl _checkRight
		; left
		lda ZPtemp
		ora ZPtemp3										; the top left or bottom left solid?
		beq _exit										; no exit
_noX
	stz checkSpriteToCharData.xDeltaCheck		; clear X movement
	stz checkSpriteToCharData.xDeltaCheck.hi
	rts
	;
_checkRight
	lda ZPtemp2
	ora ZPtemp4											; the top right and bottom right solid?
	bne _noX
_exit
	rts

; these are the collision boxes for the sprites, each animation indexes into this table
CollisionBoxesX .char 02,02,02,04,00,-24,12,04
CollisionBoxesW .char 13,13,13,16,48, 48,01,16
CollisionBoxesY .char 02,02,00,04,00, 12,12,01
CollisionBoxesH .char 12,16,20,16,12, 30,01,08

.as
.xs
collideBulletAgainstRest
_ASSERT_jsr
_ASSERT_axy8
	ldy #3								; bullet uses 4th collision box
	ldx #1								; and is sprite 1
	bra collideAgainstRestEntry
	;
collidePlayerAgainstRest
_ASSERT_jsr
_ASSERT_axy8
	ldx #0								; player uses 1st collision box
	ldy #0								; and is sprite 0
collideAgainstRestEntry
	lda mplexBuffer.ypos,x
	clc
	adc CollisionBoxesY,y
	sta Pointer3.lo					; Pointer3.lo = testingSprite.y+CollisionBoxY
	sta TestingSprY1
	clc
	adc CollisionBoxesH,y			; += CollisionBoxHeight
	sta Pointer3.hi
	sta TestingSprY2
	lda mplexBuffer.xpos,x
	clc
	adc CollisionBoxesX,y
	sta TestingSprX1					; = testingSprite.x+CollisionBoxX
	clc
	adc CollisionBoxesW,y			; += CollisionBoxWidth
	sta TestingSprX2
	lda #$FF
	sta CurrentEntity					; so we don't skip any
	bra collideAgainstEntPlayerEntry
	;
collideEntAgainstRest
_ASSERT_jsr
_ASSERT_axy8
	; start at the mplex y + 1 and check to see if the Y is in Range
	; to do this we need to know which collsiion box the ent we are is using
	; and the one that the other is using
	; a hit is if my x1 <= y2 && y1 <= x2
	; where x1 = my Ent Y, x2 = my Ent Y+Height
	; y1 = Other Ent Y, y2 = other Ent Y+Height
	ldx CurrentEntity
	ldy #0
	lda EntityData.collisionX1,x
	clc
	adc checkSpriteToCharData.xDeltaCheck	; move the ent sprite off by the movement deltas
	sta TestingSprX1 
	lda EntityData.collisionX2,x				; as their collision X1/2 Y1/2 are pre caculated
	clc
	adc checkSpriteToCharData.xDeltaCheck
	sta TestingSprX2
	lda EntityData.collisionY1,x
	clc
	adc checkSpriteToCharData.yDeltaCheck
	sta TestingSprY1
	lda EntityData.collisionY2,x
	clc
	adc checkSpriteToCharData.yDeltaCheck
	sta TestingSprY2
collideAgainstEntPlayerEntry
_ASSERT_axy8
	ldy #2 ; other slot
	ldx #0
-	cpx CurrentEntity
	beq Ent_Ent_Coll_skipSelf				; don't collide against one self
		lda EntityData.active,x
		beq Ent_Ent_Coll_skipSelf			; don't collide against in-active or "dead" entities
		bmi Ent_Ent_Coll_skipSelf			; if there active is 0 or - don't collide
			stz ZPTemp
			lda TestingSprY1
			cmp EntityData.collisionY2,x	; test my Y1 against their Y2
			jsr doMinMaxBitTest
			lda EntityData.collisionY1,x	; and thier Y1 against my Y2
			cmp TestingSprY2
			jsr doMinMaxBitTest
			lda ZPTemp							; if my.Y1 < their.Y2 && their.Y1 < my.Y2 we collide
			and #3								; both tests pass
			beq hitY								; then are Y are in range
Ent_Ent_Coll_skipSelf
	inx
	cpx EntityData.number
	bne -
	clc
	rts

.as
.xs
hitY												; now we need to do the same thing but for the X
_ASSERT_axy8
	stz ZPTemp									; clear the flags
	lda TestingSprX1
	cmp EntityData.collisionX2,x			; my X1 vs their X2
	jsr doMinMaxBitTest
	lda EntityData.collisionX1,x			; their X1 vs my X2
	cmp TestingSprX2
	jsr doMinMaxBitTest
	lda ZPTemp									; if my.X1 < their.X2 && their.X1 < my.X2 we collide
	and #3
	bne Ent_Ent_Coll_skipSelf
hitX
	sec
	rts

.as
.xs
newCollision									; there was an original but its all gone now
_ASSERT_jsr
_ASSERT_axy8
	ldx CollideSpriteToCheck
	ldy CollideSpriteBoxIndex				; get the ent and the collision box
	; calc the final Xs
	lda mplexBuffer.xpos,x
	clc
	adc CollisionBoxesX,y
	adc checkSpriteToCharData.xDeltaCheck
	sta CollideInternalSprTLX				; TLX = X + collisionBoxX + XDelta
	clc
	adc CollisionBoxesW,y					; BRX = X + collisionBoxX + XDelta + collisionBoxWidth
	sta CollideInternalSprBRX
	; calc the final Ys
	lda mplexBuffer.ypos,x
	clc
	adc CollisionBoxesY,y
	adc checkSpriteToCharData.yDeltaCheck
	jsr ClipY									; we need to clip it because odd things happen in the exlucsion zone
	sta CollideInternalSprTLY				; TLY = clip(Y + CollisionBoxY + YDelta)
	clc
	adc CollisionBoxesH,y
	jsr ClipY
	sta CollideInternalSprBRY				; TLY = clip(Y + CollisionBoxY + YDelta + collisionBoxHeight)
	; calc the tile index
	ldx #1
-	lda CollideInternalSprTLX,x			; sprite Test Left X and Right X
	lsr a
	lsr a
	lsr a
	lsr a											; /16
	sta CollideInternalTTLX,x				; Tile Test Left X and Right X
	dex
	bpl -
	lda CollideInternalTTLX
	cmp CollideInternalTBRX					; make sure right has not wrapped and is not < left
	bcc +
		sta CollideInternalTBRX				; clamp the Right to be the same as the left if it has wrapped.
+													; this stop being able to pick up things on the left of the map from the right
	lda CollideInternalSprTLY
	and #$f0
	sta CollideInternalTTLY					; convert SpriteY to Tile Y which is /16*16 or mask upper 4 bits
	lda CollideInternalSprBRY
	and #$f0
	sta CollideInternalTBRY					; same with the bottom
	; convert the tile X,Y into a the index and pull Char
	lda CollideInternalTTLY
	ora CollideInternalTTLX
	sta CollideCharTLI						; calc index
	tax
	lda tileMapTemp,x							; read tile from map
	sta CollideCharTLC

	lda CollideInternalTTLY					; do for all 4 points
	ora CollideInternalTBRX
	sta CollideCharTRI
	tax
	lda tileMapTemp,x
	sta CollideCharTRC

	lda CollideInternalTBRY
	ora CollideInternalTTLX
	sta CollideCharBLI
	tax
	lda tileMapTemp,x
	sta CollideCharBLC

	lda CollideInternalTBRY
	ora CollideInternalTBRX
	sta CollideCharBRI
	tax
	lda tileMapTemp,x
	sta CollideCharBRC
	rts

makeMinMaxXYForX
_ASSERT_jsr
_ASSERT_axy8
	ldy EntityData.type,x								; get the type
	lda EntityAnimData.collisionBox,y				; get the collision box we want to use
	tay
	lda mplexBuffer.xpos+kEntsSpriteOffset,x		; get the ents X position
	clc
	adc CollisionBoxesX,y								; offset by Box X
	sta EntityData.collisionX1,x						; store it
	clc
	adc CollisionBoxesW,y								; add the width
	sta EntityData.collisionX2,x						; store it
	lda mplexBuffer.ypos+kEntsSpriteOffset,x		; get the Y
	clc
	adc CollisionBoxesY,y								; offset by the Box Y
	sta EntityData.collisionY1,x						; store it
	clc
	adc CollisionBoxesH,y								; add the height
	sta EntityData.collisionY2,x						; store it
	rts

doMinMaxBitTest
_ASSERT_jsr
_ASSERT_axy8
	beq _secPass
	bcc _secPass					; <= Pass
		bcs _secFail				; C = 1 and return fall
_secPass
	clc								; needed as BEQ will have C = 1
_secFail
	rol ZPTemp						; record bit
	rts

.as
.xs
; carry set = not safe, clear = safe
checkSolidTile
_ASSERT_jsr
_ASSERT_axy8
	ldx GameData.exitOpenNZ				; closed doors are solid, open ones are not
	bne _skipDoorCheck
		cmp #kTiles.exit
		beq _notSafe
_skipDoorCheck
	cmp #kTiles.pipe						; is it a pipe?
	beq _notSafe
		cmp #kTiles.dissNoColide		; an empty dissolve char?
		beq _exitSafe
		cmp #kTiles.diss
			bcs _checkNotShadow			; > diss solid?
				cmp #kTiles.wall
				bcc _exitSafe				; < wall ?
					cmp #kTiles.spike		; >= spike?
					bcs _exitSafe
_notsafe
	sec
	rts
	;
_checkNotShadow
	cmp #kTiles.dissNoColide
	bcc _notsafe
_exitSafe
		clc
		rts
		;


.as
.xs
checkOnDissTile
_ASSERT_jsr
_ASSERT_axy8
	lda PlayerData.OnGroundNZ						; can't be on it if I'm not on the ground
	bne _c
_exit
		rts
		;
_c	; get the tile below the player
	lda TickDowns.dissBlocks						; is it time to dissolve some more?
	bne _exit
		lda ActiveTile
		cmp #kTiles.diss								; is the active tile < diss?
		bcc _exit
			cmp #kTiles.dissNoColide				; >- diss noColide
			bcs _exit
				lda #kTimers.dissBlocksValue		; no, then we are on a diss tile
				sta TickDowns.dissBlocks			; reset the count down
				ldx ActiveTileIndex					; get the index
				inc tileMapTemp,x						; disolve it 1 bit more
				lda tileMapTemp,x
				cmp #kTiles.dissNoColide-1			; until done
				php										; save compare
					jsr pltSingleTile					; update the tile in question on the screen mirror
				plp										; restore compare
				bne _exit								; not final tile, exit
CheckForShadowPlots
_ASSERT_axy8
	ldx #1
	jsr _checkRemoveTile								; when one removes a tile, one must check to the right
	ldx #16
	jsr _checkRemoveTile								; below it
	ldx #17
_checkRemoveTile										; and bellow to the right for new shadow pieces
	stx ZPTemp											; store the offset we want
	lda ActiveTileIndex								; get the main tile
	pha													; save it
		clc
		adc ZPTemp										; offset it
		cmp #kLevelSizeMax							; still on the map?
		bcs _exit2
			sta ActiveTileIndex						; make it the active for now
			tay
			jsr tileIsSafeToChange_88				; is it something we need to add shadow to?
			bcc _exit2
				jsr clearTile							; "clear" it
_exit2
	pla													; restore the actual active tile
	sta ActiveTileIndex
	rts

.as
.xs
checkActionTile
_ASSERT_jsr
_ASSERT_axy8
	sta ActiveTile										; for later
	stx ActiveTileIndex								; for later
	ldy #0
-	cmp TileFuncLookup,y								; does this tile have a function to handle it?
	beq _found
		iny
		cpy # size(TileFuncLookup)
		bne -
		rts												; no, no action then
		;
_found
_ASSERT_Y_LT_12
	tya
	asl a													; dispatch the function then
	tax
	jmp (TileFuncLUT,x)


TileFuncLookup .byte kTiles.fruit,kTiles.flower,kTiles.key1,kTiles.key2,kTiles.key3,kTiles.key4,kTiles.spike,kTiles.spring,kTiles.potion,kTiles.shield,kTiles.exit,kTiles.egg
TileFuncLUT .word <>(fruitFunc, flowerFunc, keyFunc, keyFunc, keyFunc, keyFunc, spikeFunc, springFunc, potionFunc, shildFunction, exitFunc, eggFunc)

.as
.xs
fruitFunc
_ASSERT_jsr
_ASSERT_axy8
	jsr clearTile					; fruit, remove it
	lda #kScoreIndex.Fruit		; give some points
	jsr giveScore
	lda #kSFX.coins
	jmp playSFX
	rts

.as
.xs
flowerFunc
_ASSERT_jsr
_ASSERT_axy8
	jsr clearTile				; flower, remove it
	lda #kScoreIndex.fruit	; give same amount of points as fruit
	jsr giveScore
	lda #kSFX.flower
	jsr playSFX
	inc GameData.flowers		; add 1 flower to collection
	lda GameData.flowers
	cmp #8						; enough for a life?
	bne _exit
		stz GameData.flowers	; trade them all in
		jsr awardLife_88		; get life
_exit
	jmp pltFlowers				; update the HUD

.as
.xs
keyFunc
_ASSERT_axy8
	jsr clearTile					; key, remove it
	lda #kScoreIndex.key			; give points
	jsr giveScore
	dec LevelData.numKeysLeft	; count down total number of keys left
	lda ActiveTile
	jsr countTempMapTile_88		; do we have any more of these keys still ( there are actually 4 keys )
	bne _done						; yes
		lda ActiveTile				; no remove all the walls that match the key number
		sec
		sbc #kKeyToWallDelta
		jsr removeAllTilesOf_88
_done
	lda LevelData.numKeysLeft	; do we have any keys left
	beq _changeDoor				; no, open the door
		lda #kSFX.coins
		jmp playSFX
		rts ; above is now jmp
_changeDoor
	lda #1
	sta GameData.exitOpenNZ		; set door to open
	lda #kSFX.DOOROPEN
	jmp playSFX
	rts ; above is now jmp

.as
.xs
spikeFunc
_ASSERT_axy8
	lda #1
	sta PlayerData.deadNZ	; hit spike, you die
	rts

.as
.xs
springFunc
_ASSERT_axy8
	jsr clearTile					; remove the tile
	lda #kSFX.powerup
	jsr playSFX
	lda #1
	sta PlayerData.canFloatNZ	; give float power
	rts

.as
.xs
potionFunc
_ASSERT_axy8
	jsr clearTile					; remove tile
	ldx #0
	stx ActiveTileIndex			; start at top left
_loop
	lda tileMapTemp,x
	cmp #kTiles.spike				; is this a spike ?
	bne _next
		lda #kTiles.fruit			; its is now fruit
		sta tileMapTemp,x
		jsr pltSingleTile			; update screen mirror
_next
	inc ActiveTileIndex
	ldx ActiveTileIndex
	cpx #kLevelSizeMax			; until all are scanned
	bne _loop
	lda #kSFX.powerup
	jmp playSFX
	rts ; above is now jmp

.as
.xs
shildFunction
_ASSERT_axy8
	jsr clearTile									; remove the tile
	lda #1
	sta PlayerData.hasShieldNZ					; give the shield power
	lda #kSFX.powerup
	jsr playSFX
	lda #<kShieldTimer
	sta PlayerData.shieldTimer.lo				; reset the timer
	lda #>kShieldTimer
	sta PlayerData.shieldTimer.hi
	lda #50
	sta TickDowns.shieldFlashTimerSpeedUp	; and the speed up timer value
	lda #16
	sta PlayerData.baseFlashTimeDelta		; and the base delta
	rts

.as
.xs
clearShieldState
_ASSERT_jsr
_ASSERT_axy8
	stz PlayerData.hasShieldNZ					; no power
	stz PlayerData.flashColour					; no flash
	stz PlayerData.shieldTimer.lo				; timer is 0
	stz PlayerData.shieldTimer.hi
	rts

.as
.xs
exitFunc
_ASSERT_jsr
_ASSERT_axy8
	lda GameData.exitOpenNZ						; it is open right?
	beq _notOpen
		stz GameData.exitOpenNZ					; its closed now then
		lda ActiveTileIndex
		sta PlayerData.exitAtIndex				; set the exit position ( there are up to 2 per level )
		lda #kPlayerState.exit					; set player to exit state
		sta PlayerData.state
		sta PlayerData.minorState				; set minor to "entering death state"
_notOpen
	rts

.as
.xs
eggFunc
_ASSERT_jsr
_ASSERT_axy8
	jsr clearTile								; remove tile
	inc PlayerData.numBulletEgg			; give 1 more bullet egg
	lda #kSFX.powerup
	jmp playSFX
	;rts ; above is now jmp

.as
.xs
animateDoor_88
_ASSERT_jsr
_ASSERT_axy8
	lda GameData.exitOpenNZ					; its open right?
	beq aDexit
		lda TickDowns.doorAnim				; time for next frame?
		bne aDexit
			lda #kTimers.DoorAnimeRate
			sta TickDowns.doorAnim			; reset timer
			lda LevelData.exitIndex			; set the tile index
			sta ActiveTileIndex
			jsr animateInternal_88			; animate it
			lda LevelData.exitIndex+1		; do we have two doors?
			cmp #$ff
			beq aDexit
				sta ActiveTileIndex			; yes, animate it too
				gne animateInternal_88
aDexit
	rts

.as
.xs
animateInternal_88
_ASSERT_jsr
_ASSERT_axy8
	lda LevelData.exitFrame
	cmp LevelData.exitTargetFrame			; have we reached the target frame
	beq aDexit									; which is either fully open or fully closed
	clc
	adc LevelData.exitFrameDelta			; move to next frames (1 or -1)
	sta LevelData.exitFrame
	gra pltSingleTileNoLookup				; draw it

.as
.xs
setAnimateDoorToOpen_88
_ASSERT_jsr
_ASSERT_axy8
	lda #kDoorClosed
	sta LevelData.exitFrame					; we start at the closed frame
	lda #kDoorOpen
	sta LevelData.exitTargetFrame			; end on open
	lda #1
	sta LevelData.exitFrameDelta			; +1 to get to next frame
	rts

.as
.xs
setAnimateDoorToClose_88
_ASSERT_jsr
_ASSERT_axy8
	lda #kDoorOpen
	sta LevelData.exitFrame					; we state at open frame
	lda #kDoorClosed
	sta LevelData.exitTargetFrame			; end of closed
	lda #-1
	sta LevelData.exitFrameDelta			; -1 to get to next frame
	rts


; ----- @Level Data@ -----

LevelTable .word <>(fileTileMap,Level02,Level03,Level04,Level05,Level06,Level07,Level08,Level09,Level10,Level11,Level12,Level13,Level14,Level15,Level16,Level17,Level18,Level19,Level20,Level21,Level22,Level23,Level24,Level25,Level26,Level27,Level28,Level29,Level30,Level31)

fileTileMap	.binary "../levels/01.bin"
Level02		.binary "../levels/02.bin"
Level03		.binary "../levels/03.bin"
Level04		.binary "../levels/04.bin"
Level05		.binary "../levels/04boss01.bin"
Level06		.binary "../levels/05.bin"
Level07		.binary "../levels/06.bin"
Level08		.binary "../levels/07.bin"
Level09		.binary "../levels/08.bin"
Level10		.binary "../levels/08boss02.bin"
Level11		.binary "../levels/09.bin"
Level12		.binary "../levels/10.bin"
Level13		.binary "../levels/11.bin"
Level14		.binary "../levels/12.bin"
Level15		.binary "../levels/12boss03.bin"
Level16		.binary "../levels/13.bin"
Level17		.binary "../levels/14.bin"
Level18		.binary "../levels/15.bin"
Level19		.binary "../levels/16.bin"
Level20		.binary "../levels/16boss04.bin"
Level21		.binary "../levels/17.bin"
Level22		.binary "../levels/18.bin"
Level23		.binary "../levels/19.bin"
Level24		.binary "../levels/20.bin"
Level25		.binary "../levels/20boss05.bin"
Level26		.binary "../levels/21.bin"
Level27		.binary "../levels/22.bin"
Level28		.binary "../levels/23.bin"
Level29		.binary "../levels/24.bin"
Level30		.binary "../levels/24boss06.bin"
Level31		.binary "../levels/end.bin"

; ----- @Titlescreen Data@ -----

TitleScreenData .block

SpriteStruct .block
	_QDef = fSprDef(6,10, kSPri_3|kSPal_0)
	_WDef = fSprDef(4,12, kSPri_3|kSPal_0)
	_ADef = fSprDef(6,12, kSPri_3|kSPal_0)
	_KDef = fSprDef(4,14, kSPri_3|kSPal_0)
	; this is set up so I can just loop copy to OAM
	sprites	.byte 63 ,10, <_QDef, >_QDef
				.byte	98,10, <_WDef, >_WDef
				.byte 133,10, <_ADef, >_ADef
				.byte	168,10, <_KDef, >_KDef
	kUpper = %10101010 ; all Large and no MSB
.bend

; each string has the ID, X char, Y char
Version = (kStrings.version,8,4)
Original = (kStrings.original,0,6)
Ported = (kStrings.cx16port,3,8)
Code = (kStrings.program,7,10)
Art = (kStrings.art,7,11)
Music = (kStrings.music,7,12)
Special = (kStrings.specialThanks,6,14)
Soci = (kStrings.soci,7,16)
Didi = (kStrings.didi,10,17)
Saul1 = (kStrings.saul,13,11)
Saul2 = (kStrings.saul,13,12)
Optiroc = (kStrings.optiroc,12,18)
Both = (kStrings.both,7,22)
Music2 = (kStrings.music,15,22)
SFX = (kStrings.sfx,24,22)
None = (kStrings.none,30,22)
Password = (kStrings.password,5,19)
PasswordBlank = (kStrings.passwordBlank,14,20)
MusicSNES = (kStrings.snesMusic,2,13)

; merge all the strings into one, this time I don't use := but make multiple and merge down
G1 = (Version,Original,Ported,Code)
G2 = (Art,Music,Special,Soci)
G3 = (Didi,Saul1,Saul2,MusicSNES,Optiroc)
; G4 = (Both, Music2,SFX,None,Password)	; SNES version doesn't need these string yet
; G5 = (PasswordBlank,)
AllStrings = G1 .. G2 .. G3 ; .. G4 .. G5

; this has the index into the String Ptr LUT to draw this string
string .word AllStrings[:,0]..(kStrings.gameOver,)	; tack the Game over on the end so len(AllStrings) gives the index
; convert the X,Y char to address to copy string to on Screen Mirror
allPos = (fGetMemoryForScreenChar(<>ScreenMirror,AllStrings[:,1],AllStrings[:,2]))..(fGetMemoryForScreenChar(<>ScreenMirror,11,12),)
; get the dest pointers lo/hi
stringPos .block
	.word <>(allPos)
.bend

;spriteCol	.byte 7,13,14,10 ; reference by commneted out code

; used for the menu which currently is not in the SNES version
;menuOffsetsStart	.byte (30,23,15,7)*2
;menuOffsetsEnd		.byte (37,30,22,14)*2

.bend ; titlescreendata

; This converts ASICII to the font layout I use in QWAK which is actually mostly just PETSCII order offset
; {{{
.enc "qwak" ;define an ascii->petscii encoding
.cdef "@@", 128
.cdef "AZ", 129
.edef "[",  155
.edef "�",  156 ; this is the britsh pound smybol if it is corrupt you need to reopen the file as Windows1252 encoding
.edef "]",  157 ; or retype the pound in your current encoding, everything else is UTF-8 safe.
.edef "^",  158
.edef "|",  159;->
.edef " ",  160
.edef "!",  161
.edef "`",  162;"
.edef "#",  163
.edef "~",  164 ;heart
.edef "%",  165
.edef "&",  166
.edef "'",  167
.edef "(",  168
.edef ")",  169
.edef "*",  170
.edef "+",  171
.edef ",",  172
.edef "-",  173
.edef ".",  174
.edef "/",  175
.cdef "09", 176
.edef ":",  186
.edef ";",  187
.edef "<",  188
.edef "=",  189
.edef ">",  190
.edef "?",  191
; }}}

; the index here must match bellow and is use to set the string data in the string,pos
kStrings .block
	gameOver = 0*2
	original = 1*2
	cx16port = 2*2
	program = 3*2
	art = 4*2
	music = 5*2
	specialThanks = 6*2
	soci = 7*2
	didi = 8*2
	saul = 9*2
	sfx = 10*2
	none = 11*2
	both = 12*2
	version = 13*2
	password = 14*2
	passwordBlank = 15*2
	optiroc = 16*2
	snesMusic = 17*2
.bend

;StringTableLUTLo .byte <GAMEOVER,<ORIGINAL,<CX16PORT,<PROGRAM,<ART,<MUSIC,<SPECIALTHANKS,<SOCI,<MARTINPIPER,<SAUL,<SFX,<NONE,<BOTH,<VERSION,<PASSWORD,<PASSWORDBLANK,<OPTIROC
;StringTableLUTHi .byte >GAMEOVER,>ORIGINAL,>CX16PORT,>PROGRAM,>ART,>MUSIC,>SPECIALTHANKS,>SOCI,>MARTINPIPER,>SAUL,>SFX,>NONE,>BOTH,>VERSION,>PASSWORD,>PASSWORDBLANK,>OPTIROC

StringTableLUT .word <>(GAMEOVER,ORIGINAL,CX16PORT,PROGRAM,ART,MUSIC,SPECIALTHANKS,SOCI,MARTINPIPER,SAUL,SFX,NONE,BOTH,VERSION,PASSWORD,PASSWORDBLANK,OPTIROC,SNESMUSIC)

.enc "qwak"
GAMEOVER			.text "GAME OVER",$ff
ORIGINAL			.text "ORIGINAL CONCEPT JAMIE WOODHOUSE",$ff
CX16PORT			.text "PORTED TO THE SUPER NES BY",$ff
PROGRAM			.text "CODE  : OZIPHANTOM",$ff
ART				.text "ART",$ff
SAUL				.text ": SAUL CROSS",$ff
MUSIC				.text "MUSIC",$ff
SFX				.text "SFX",$ff
NONE				.text "NONE",$ff
BOTH				.text "BOTH",$ff
SPECIALTHANKS	.text "SPECIAL THANKS GO TO",$ff
SOCI				.text "SOCI, MARTIN PIPER",$ff
MARTINPIPER		.text "DIDI, THERYK",$ff
OPTIROC			.text "OPTIROC",$ff
VERSION			.text "SNES EDITION 1.3",$ff
PASSWORD			.text "TYPE PASSWORD : SPACE TO CLEAR",$ff
PASSWORDBLANK	.text "------------",$ff
SNESMUSIC		.text "SNES MUSIC : CRISPS",$FF

; the Cheat password bytes not used in SNES yet, left for cribbing, execise to the user etc
PASSWORD_LIVES		.byte $88,$8f,$94,$8f,$90,$81,$81,$83,$92,$8f,$93,$93 ; hotopaacross
PASSWORD_RED		.byte $89,$93,$88,$8f,$8f,$94,$92,$85,$84,$81,$8c,$8c ; ishootredall
PASSWORD_SPRING	.byte $8d,$81,$99,$84,$81,$99,$8d,$81,$99,$84,$81,$99 ; maydaymayday
PASSWORD_LEVEL		.byte $93,$94,$85,$90,$90,$85,$84,$8f,$96,$85,$92,$81 ; steppedovera

BossLevels 		.byte 4,4+5,4+10,4+15,4+20,4+25

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
	THEME_3	= 4
.bend

playSFX
	ldx #127 ; max vol
	ldy #7	; always channel 7
	jsl SFX_Play_Center
	rts

playMusic	
	php	
		#A8	
		stz $4200,b 		; turn off NMI and joypad	
		asl a	
		#AXY16	
		and #$00ff	
		tax	
		lda MusTable,x	
		ldx #`music_1		; all music in one bank	
		jsl SPC_Play_Song
		#A8
		lda #$81 			; enable NMI and joypad
		sta $4200,b
	plp
	rts

MusTable .word <>(music_1,music_2,music_3,music_4,music_5)
.include "../music/music.asm"
