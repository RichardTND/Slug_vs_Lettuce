// Slug vs Lettuce								
// Game pointers 			

rp:			.byte 0 //Raster pointer to sync with IRQ
newpos:     .byte 0	
newpos2:	.byte 0	
system:		.byte 0 
ntscTimer:  .byte 0
fireTimer:  .byte 0
timeExpiry: .byte $30
pointers:

// GFX animation pointer 

gfxAnimDelay: .byte 0

// Sprite animation pointers
spriteAnimDelay: .byte 0
spriteAnimPointer: .byte 0
spriteAnimPointer2: .byte 0
spriteAnimPointer3: .byte 0
explodeAnimDelay: .byte 0
explodePointer: .byte 0

// Sprite collision pointers 
spriteColliderLeft: .byte 0
spriteColliderRight: .byte 0
spriteColliderTop: .byte 0
spriteColliderBottom: .byte 0

// Player properties:

playerIsJumping: .byte 0
playerIsFalling: .byte 0
playerIsAllowedToPressFire: .byte 0
playerJumpPointer: .byte 0

fireButton:		.byte 0

pointersend:		

// Slug direction and lettuce animations (stored to sprites)

slugRightSprite: .byte $80
slugLeftSprite: .byte $82
lettuceSprite: .byte $84

// Water droplets pointers

dropRandTemp: .byte $5a
dropRand: .byte %10011101,%01011011
dropletSpeed: .byte $00,$02,$00,$01,$00,$03,$00,$01,$00,$02,$00,$01

lettuceRandTemp: .byte $5a
lettuceRand: .byte %10011101,%0101011
lettuceColour: .byte $05,$0d,$01,$0d,$05

// Lettuce X and Y location tables

lettuceXTable: .byte $56,$38,$7C,$12,$9a,$32,$7c,$56,$2c,$80,$0b,$a1
lettuceYTable: .byte $40,$58,$58,$6a,$6a,$7e,$7e,$98,$b0,$b0,$c8,$c8

		        //SP0 SP1 SP2 SP3
			    //X,Y,X,Y,X,Y,X,Y
objPos:		.byte 0,0,0,0,0,0,0,0 //objPos = sprite position 
                //SP4 SP5 SP6 SP7
				//X,Y,X,Y,X,Y,X,Y
			.byte 0,0,0,0,0,0,0,0 


// Sprite starting position table (All 
// sprites are offset except for the 
// slug.

startPos:		.byte $56,$c4
				.byte $0c,$00
				.byte 0,0
				.byte 0,20
				
				.byte 0,40
				.byte 0,60
				.byte 0,80
				.byte 0,100

// Game sprite animation and colour 
// pointers 

defaultFrames:	.byte $80,$84,$85,$87
				.byte $89,$88,$86,$89

defaultColour:	.byte $05,$0d,$0e,$0e
				.byte $0e,$0e,$0e,$0e


// Selection position table, (for random usage 16 bytes)

randPosTable:	.byte 012,024,036,048,056,060
				.byte 072,084,096,120,132,144
				.byte 156,160,012,024

// Game sprite animation tables

slugRightFrame: .byte $80,$81
slugLeftFrame:  .byte $82,$83
lettuceFrame:   .byte $84,$84
dropletFrame1:  .byte $85,$86,$87,$88,$89
dropletFrame2:  .byte $87,$88,$89,$85,$86
dropletFrame3:	.byte $89,$85,$86,$87,$88
dropletFrame4:  .byte $88,$89,$85,$86,$87
dropletFrame5:  .byte $86,$87,$88,$89,$85
dropletFrame6:	.byte $89,$85,$86,$87,$88

// Player explosion properties
explodeAnimPointer: .byte 0

explodeFrame:	.byte $8a,$8b,$8c,$8d,$8e,$8f,$90,$91
explodeEnd:
collectFrame:   .byte $92,$93,$94,$95,$96,$97

// Player jump table 

jumpTable:		.byte $fb,$fb,$fc,$fc,$fd,$fd,$fe,$fe,$ff
jumpTableEnd:				

// Score pointers

score:			.byte $30,$30,$30,$30,$30,$30
hiscore:		.byte $30,$32,$35,$30,$30,$30 
clockDelay:		.byte 0
time:			.byte $30,$30,$30
lives:			.byte $30

// Shield pointers 

slugShieldTime:		.byte $00
shieldPointer: 		.byte $00
shieldColourTable:  .byte $05,$03,$0d,$01,$0d,$03,$05

// Sprite text frames

letter_g: .byte $92
letter_e: .byte $93
letter_t: .byte $94
letter_r: .byte $95 
letter_a: .byte $96
letter_d: .byte $97
letter_y: .byte $98
letter_m: .byte $99 
letter_o: .byte $9a 
letter_v: .byte $9b 
letter_w: .byte $9c
letter_l: .byte $9d
letter_n: .byte $9e

// Sprite position table for GET READY

getReadyPos:

				.byte $46,$72,$56,$72
				.byte $66,$72,$36,$92
				.byte $46,$92,$56,$92
				.byte $66,$92,$76,$92

// Sprite position table for GAME OVER and WELL DONE				

gameOverPos:	.byte $3e,$72,$4e,$72
				.byte $5e,$72,$6e,$72
				.byte $3e,$92,$4e,$92
				.byte $5e,$92,$6e,$92

// -------------------------------------------------------

// In game sound effects (Goat Tracker instrument based,then converted using INS2SND)

// Slug jumps 
slugJumpSFX:  .byte $0F,$AA,$88,$C1,$11,$C2,$C3,$C4,$C5,$C6,$C7,$C8,$C9,$CA,$CB,$CC
        	  .byte $CD,$00

// Slug eats lettuce
slugEatSFX:	   .byte $0F,$AA,$88,$C0,$81,$BC,$41,$B4,$81,$BA,$41,$B4,$81,$B8,$41,$B4
        	   .byte $81,$B4,$41,$B4,$81,$B2,$41,$B4,$81,$B0,$41,$B4,$81,$B0,$41,$B9
               .byte $81,$00

// Slug is hit by water
slugHitSFX:		.byte $0F,$AA,$88,$B0,$41,$B1,$B2,$B3,$B4,$00

// Slug is dead
slugDeadSFX:	.byte $0F,$FA,$08,$C4,$81,$A8,$41,$C0,$81,$BE,$BC,$80,$BA,$B8,$B6,$B4
        		.byte $B2,$B0,$AE,$AC,$AA,$A8,$A6,$A4,$A2,$A0,$9E,$9C,$9A,$98,$96,$94
        		.byte $92,$90,$00

// Slug gets extra live
extraLifeSFX: 	.byte $0E,$EE,$08,$B0,$41,$B0,$B4,$B4,$B7,$B7,$BC,$BC,$C0,$C0,$BC,$BC
         		.byte $B7,$B7,$B4,$B4,$B0,$B0,$A0,$10,$00
