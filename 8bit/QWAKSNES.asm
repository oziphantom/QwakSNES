; LoROM FAST SNES Master
.cpu "65816"

; setup the ROM MAP
* = $000000			; FILE OFFSET
.logical $808000	; SNES ADDRESS
.dsection sBank80
.cerror * > $80FFB0, "Bank 80 overflow by ", *-$80FFB0
* = $80FFB0
.dsection sHeader
*= $80FFE4
.dsection s65816Vectors
*= $80FFF4
.dsection s6502Vectors
.here			  ; back to file


* = $008000			; FILE OFFSET
.logical $818000  ; SNES ADDRESS
.dsection sBank81
.here
.cerror * > $10000, "Bank 81 overflow by ", *-$10000

* = $010000			; FILE OFFSET
.logical $828000  ; SNES ADDRESS
.dsection sBank82
.here
.cerror * > $18000, "Bank 82 overflow by ", *-$18000

* = $018000			; FILE OFFSET
.logical $838000	; SNES ADDRESS
.dsection sBank83
.here
.cerror * > $020000, "Bank 83 overflow by ", *-$20000

; .. add more banks here ..

.if * < $040000
	* = $040000-1	; make the file 128K 
	.byte 0
.endif


; *** virtual address ***
; these exist to the code but are not part of the output file
*=$0000
.dsection sDP
.cerror * > $100, "Direct Page overflow by ", *-$100
gSharedRamStart
.dsection sSharedWRAM
.cerror * > $1FC0, "Shared WRAM overflow by ", *-$1FC0
*=$7e2000
.dsection sLoWRAM
.cerror * > $7F0000, "Lo WRAM overflow by ", *-$7F0000
*=$7f0000
.dsection sHiWRAM
.cerror * > $800000, "High WRAM overflow by ", *-$800000

.include "SNESDef.asm"
kEntity .block
	heli = $00
	spring = $01
	worm = $02
	bat = $03
	ghost = $04
	spider = $05
	fish = $06
	circler = $07
	bear = $08
	octopuss = $09
	bearBody = $0A	
	octopussBody = $0B
	bubble = $0C
	bossDummy = $0D
	maxEntities = 25
	maxBubbleMakers = 8
	maxNumBubblesPerMaker = 2
	removedFromBullet = 255
	deadFromRedBullet = 254
.bend

mplex .block 
	kMaxSpr = $1f
.bend

.include "qwak_structs.asm"

.section sDP
EntityDataPointer	.dunion HLWord
CurrentEntity		.byte ?
CollidedEntity		.byte ?
EntNum				.byte ?
CollisionResult	.byte ?
Pointer1				.dunion HLWord
Pointer2				.dunion HLWord
Pointer3				.dunion HLWord
Pointer4				.dunion HLWord
playerTempCol		.byte ?
ZPTemp				.byte ?
ZPTemp2				.byte ?
ZPTemp3				.byte ?
ZPTemp4				.byte ?
ZPTemp5				.byte ?
TempX					.byte ?
ActiveTileIndex	.byte ?
ActiveTile			.byte ?
TestingSprX1		.byte ?
TestingSprX2		.byte ?
TestingSprY1		.byte ?
TestingSprY2		.byte ?
GameStatePointer	.dunion HLWord

CollideSpriteToCheck		.byte ?
CollideSpriteBoxIndex	.byte ?
CollideCharTLI				.byte ?
CollideCharTLC				.byte ?
CollideCharTRI				.byte ?
CollideCharTRC				.byte ?
CollideCharBLI				.byte ?
CollideCharBLC				.byte ?
CollideCharBRI				.byte ?
CollideCharBRC				.byte ?
CollideInternalSprTLX	.byte ?  ; these 4 MUST be in the same order as below
CollideInternalSprBRX	.byte ?
CollideInternalSprTLY	.byte ?
CollideInternalSprBRY	.byte ?
CollideInternalTTLX		.byte ?
CollideInternalTBRX		.byte ?
CollideInternalTTLY		.byte ?
CollideInternalTBRY		.byte ?
DidClipX						.byte ?  ; this is if the add X with MSB function did clip the Y
HideScreen					.byte ?
ZPLong						.dunion HLBLong
.send

; *** instance headers and vectors 
.enc "none"
.section sHeader
	.word 0
	.text "QWAK"
	.fill 7,0
	.byte 0 ; RAM
	.byte 0 ; special version
	.byte 0 ; cart type
	;					 111111111112
	;	  	 123456789012345678901
	.text "qwak snes            "
.cerror * != $80ffd5, "name is too short", *
	.byte $30	; Mapping
	.byte $00	; Rom
	.byte $07	; 128K
	.byte $00	; 0 SRAM
	.byte $02	; PAL
	.byte $33	; Version 3
	.byte $00	; rom version 0
	.word $0000 ; complement
	.word $0000 ; CRC
.send ; sHeader

.section s65816Vectors
.block								; scope this so we don't get name clashes
vCOP	.word <>Bank80.justRTI	; COP is a assembly mnemonic so add v
vBRK	.word <>Bank80.justRTI	; BRK is a assembly mnemonic so add v
ABORT	.word <>Bank80.justRTI
NMI	.word <>Bank80.NMI
RESET	.word <>Bank80.justRTI
IRQ	.word <>Bank80.justRTI
.bend
.send ; s65816Vectors

.section s6502Vectors
.block								; scope this so we don't get name clashes
vCOP	.word <>Bank80.justRTI	; COP is a assembly mnemonic so add v
vBRK	.word <>Bank80.justRTI	; BRK is a assembly mnemonic so add v
ABORT	.word <>Bank80.justRTI
NMI	.word <>Bank80.justRTI
RESET	.word <>Bank80.RESET
IRQ	.word <>Bank80.justRTI
.bend
.send ; s65816Vectors

; *** instance banks ***
.section sBank80
Bank80 .binclude "Bank80.asm"
.send

.section sBank81
.byte 0 ; place holder
.send

.section sBank82
	BackShadowChars	.binary "../back_shadow.bin"
	FixedSectionChars	.binary "../fixed_section_chars.bin"
	Font4BPP				.binary "../font4bpp.bin" 
	TopFixedChars		.binary "../top_fixed_chars.bin"
	CharPallete			.binary "../chars.pal"
	SpritePallete		.binary "../sprites_SNES.pal",0,96 ; we only want first 3 PAL entries
.send

.section sBank83
	SpritesChars .binary "../sprites_SNES.bin"
.send


.section sSharedWRAM
.include "sharedWRAM.asm"
.send ;sSharedWRAM 

HLWord .union
	.word ?
	.struct
		lo .byte ?
		hi .byte ?
	.ends
.endu

HLBLong .union
	.long ?
	.struct
		lo	.byte ?
		hi	.byte ?
		bank .byte ?
	.ends
	.struct
		loWord .word ?
		dummy1 .byte ?
	.ends
	.struct
		dummy2 .byte ?
		hiWord .word ?
	.ends
.endu

A8 .macro
	SEP #$20
.endm

A16 .macro
	REP #$20
.endm

XY8 .macro
	SEP #$10
.endm

XY16 .macro
	REP #$10
.endm

AXY8 .macro
	SEP #$30
.endm

AXY16 .macro
	REP #$30
.endm
