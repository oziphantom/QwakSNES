sGameData .struct 
lives 		.byte ?					; player lives
flowers 		.byte ?					; current flowers
score 		.byte ?,?,?,?,?,?		; current score, byte per digit
high 			.byte ?,?,?,?,?,?		; best high score, byte per digit
currLevel 	.byte ?					; current level 0 bassed		
exitOpenNZ 	.byte ?					; have all keys been collected
musicMode 	.byte ?					; not actually used, yet
.ends

sLevelData .struct
numKeysLeft			.byte ?			; number of keys left to collect
totalKeys 			.byte ?			; the number of keys in the start of the level
playerIndex 		.byte ?			; the tile index the player should spawn on
exitIndex 			.byte ?,?		; tile index the player can exit from, up to 2 per level
exitFrame 			.byte ?			; the start frame for the 'exit door'
exitTargetFrame	.byte ?			; the target frame for the 'exit door'
exitFrameDelta		.byte ?			; are we opening or closing so +1 / -1
levelGraphicsSet 	.byte ?			; which of the current wall/fruit set we are using this level
.ends

sTimerTickDowns .struct
dissBlocks 					.byte ?	; timer till next update to a block that dissapears, there is only 1 so it can be exploited
playerAnim 					.byte ?	; players animation timer
doorAnim						.byte ?	; frames till next exit door animation
bulletLifeTimer 			.byte ?	; how long until the bullet will expire
shieldFlashTimer 			.byte ?	; time until we speed up the fast rate
shieldFlashTimerSpeedUp .byte ?	; this the intial flash hold value, this is overly complex
bubbleTimer 				.fill kEntity.maxBubbleMakers ; timer until each bubble can spawn
.ends

sPlayerData .struct
; state info
state 					.byte ?				; major FSM value
minorState 				.byte ?				; sub FSM in that FSM value

deadNZ					.byte ?
hasShieldNZ				.byte ?
shieldTimer				.dunion HLWord
canFloatNZ 				.byte ?				; AKA has collected spring
floatTimer 				.byte ?

onGroundNZ 				.byte ?
hasJumpedNZ				.byte ?
isFallingNZ				.byte ?
facingRight 			.byte ?				; this is 0 or 1 only
startedJumpLR 			.byte ?				; this a clone of facingRight at time of jump
movingLRNZ 				.byte ?				; this is are we moving on the X axis
slowMoveNZ				.byte ?				; are we moving opposite direction in air
hitBubbleNum 			.byte ?				; which bubble are we currently standing on
forceJumpNZ				.byte ?				; used to trigger a jump, when you bounce on a boss head

yDeltaAccum 			.dunion HLWord		; the current Y delta value to add the upper 8bits of to Y for jump
currAnim 				.byte ?				; the players current animation number 
frameOffset 			.byte ?				; the current frame in the animation

bulletActive 			.byte ?				; this is 0 or 1 only
bulletUD 				.byte ?				; this is 0 or 1 only
bulletLR 				.byte ?				; this is 0 or 1 only
bulletBurstNZ 			.byte ?				; has the bullet hit something?
numBulletEgg			.byte ?				; number of egg bullets the player has, 0 for bubble bullet

exitAtIndex 			.byte ?				; this is the tile map index that the player is exiting from

flashColour				.byte ?				; index into the flash colour LUT
baseFlashTimeDelta	.byte ?				; this is the next timer value to load when toggled
.ends

sEntityData .struct
number			 .byte ?									; how many entities are actually in this level
type				 .fill kEntity.maxEntities			; the kEntity type that this entity is 
direction		 .fill kEntity.maxEntities 		; which direction the entity is moving
active			 .fill kEntity.maxEntities 		; if it is still active
movTimer			 .fill kEntity.maxEntities			; timer till next movement 
animTimer		 .fill kEntity.maxEntities 		; timer till next anim frame update
animBase 		 .fill kEntity.maxEntities			; the base index into the entity animation data for this animation
animFrame		 .fill kEntity.maxEntities			; the current frame in this animation
originalY		 .fill kEntity.maxEntities 		; the Y the unit was spawned at, for the spiders and fish
entState			 .fill kEntity.maxEntities 		; current sub FSM state for this entity (abused for other purposes as well)
collisionX1 	 .fill kEntity.maxEntities			; holds minX for this ent for collision table building
collisionX2 	 .fill kEntity.maxEntities			; holds maxX for this ent for collision table building
collisionY1 	 .fill kEntity.maxEntities			; holds minY for this ent for collision table building
collisionY2 	 .fill kEntity.maxEntities			; holds maxY for this ent for collision table building
speed				 .fill kEntity.maxEntities			; current movement speed for this entity in pixels
ignoreColl		 .fill kEntity.maxEntities			; should this entity ignore collision until no longer colliding (helps stop enemies not stick on each other)
palleteOffset	 .fill kEntity.maxEntities			; sets ent to use defined pallete + this number, should be in kSPal_X, used for boss flash
numPipes			 .byte ?									; how many bubble spawns do we have in this map
pipeIndex 		 .fill kEntity.maxBubbleMakers	; a list of all the bubble spawn locations
lastPipeUsed 	 .byte ?									; the last pipe to spawn a bubble
pipeBubbleStart .byte ?									; the first entity that is used for bubbles									
.ends

sCSTCCParams .struct	
xDeltaCheck 	.byte ? 		; pixels
yDeltaCheck 	.byte ? 		; pixels
xDeltaBackup 	.byte ? 		; pixels
yDeltaBackup 	.byte ? 		; pixels
.ends

sMplexBuffer .struct
xpos  .fill mplex.kMaxSpr+1		;sprite x position frame buffer
xmsb  .fill mplex.kMaxSpr+1		;sprite x msb frame buffer	
ypos  .fill mplex.kMaxSpr+1		;sprite y position frame buffer
.ends
