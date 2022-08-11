// Slug vs Lettuce								
// Game pointers 			

rp:			.byte 0 //Raster pointer to sync with IRQ
newpos:     .byte 0	
newpos2:	.byte 0	
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

slugRightSprite: .byte $80
slugLeftSprite: .byte $82
lettuceSprite: .byte $84

dropRandTemp: .byte $5a
dropRand: .byte %10011101,%01011011
dropletSpeed: .byte $00,$02,$00,$03,$00,$04,$00,$02,$00,$04,$00,$03

lettuceRandTemp: .byte $5a
lettuceRand: .byte %10011101,%0101011

// Lettuce X and Y location tables

lettuceXTable: .byte $56,$36,$7a,$12,$9c,$32,$7c,$56,$26,$7e,$0c,$a2
lettuceYTable: .byte $40,$58,$58,$6a,$6a,$7e,$7e,$98,$b0,$b0,$c8,$c8

playJumpTable:
			 
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

jumpTable:		.byte $fd,$fc,$fb,$fb,$fb,$fb,$fb,$fb,$fb
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

getReadyPos:

				.byte $46,$78,$56,$78
				.byte $66,$78,$36,$98
				.byte $46,$98,$56,$98
				.byte $66,$98,$76,$98

gameOverPos:	.byte $3e,$78,$4e,$78
				.byte $5e,$78,$6e,$78 
				.byte $3e,$98,$4e,$98
				.byte $5e,$98,$6e,$98 


