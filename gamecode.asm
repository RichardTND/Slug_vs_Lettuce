//Slug vs Lettuce game code

//	Switch off previous IRQ raster 
//  interrupts, and prepare the game 
//  screen 
 
gamecode:	
	
			sei
			 
		 
			//Silent SID chip
			ldx #$00
stopsnd:	lda #$00
			sta $d400,x
			inx 
			cpx #$18 //(SID: $D400-$D418)
			bne stopsnd 
			
			// Draw game screen and 
			// colour attributes
			
			ldx #$00
drawScreen: lda gameScreen,x
			sta screenRam,x
			lda gameScreen+$100,x
			sta screenRam+$100,x
			lda gameScreen+$200,x
			sta screenRam+$200,x
			lda gameScreen+$2e8,x
			sta screenRam+$2e8,x
			 			
			ldy gameScreen,x
			lda gameAttribs,y
			sta colourRam,x
			ldy gameScreen+$100,x
			lda gameAttribs,y
			sta colourRam+$100,x
			ldy gameScreen+$200,x
			lda gameAttribs,y
			sta colourRam+$200,x
			ldy gameScreen+$2e8,x
			lda gameAttribs,y
			sta colourRam+$2e8,x 
			inx 
			bne drawScreen 
			
			// Setup VIC2 graphics 
			// charset and background 
			// colours.
			
			lda #$18 //Screen multicol
			sta $d016 // on
			lda #$1c //Charset at $3000
			sta $d018
			
			//Background colours 
			
			lda #$00
			sta $d020 //Border +
			sta $d021 //background col
			lda #$09	
			sta $d022 //BG Mcol 1
			lda #$08
			sta $d023 //BG Mcol 2
			
			// Initialise all game 
			// pointers.
			
			ldx #$00
initpointers: lda #$00
			sta pointers,x
			inx 
			cpx #pointersend-pointers 
			bne initpointers 
			
			lda #1
			sta playerIsFalling
			
			// Reset all sprites
			
			ldx #$00
zerosprts:	lda #$00
			sta $d000,x	  
			sta objPos,x
			inx 
			cpx #16
			bne zerosprts
			
			// Set starting position 
			
			ldx #$00
setstart:	lda startPos,x
			sta objPos,x
			inx
			cpx #16 
			bne setstart
			
			ldx #$00
setdfltsprs:
			lda defaultFrames,x
			sta $07f8,x
			lda defaultColour,x
			sta $d027,x
			inx
			cpx #8
			bne setdfltsprs
			
			lda #$0b
			sta $d025
			lda #$01
			sta $d026
			lda #$ff
			sta $d015
			sta $d01c
			lda #0
			sta $d017
			sta $d01b
			sta $d01d
					
			ldx #$fb
			txs
// Setup game IRQ raster interrupts 
			ldx #<gameIRQ 
			ldy #>gameIRQ
			lda #$7f
			stx $0314
			sty $0315
			sta $dc0d 
			sta $dd0d 
			lda #$32
			sta $d012 
			lda #$1b
			sta $d011
			lda #$01
			sta $d01a 
			lda #$00
			jsr musicInit
			cli
			jmp gameLoop
						
// The main IRQ raster interrupt. We 
// only need to use one interrupt for 
// this game.

gameIRQ:	asl $d019 
			lda $dc0d 
			sta $dd0d
			lda #$fa // Pos. of bottom
			sta $d012 //raster
			jsr musicPlay
			lda #1
			sta rp //Raster pointer
			jmp $ea7e
	
// The main game loop subroutine

gameLoop:	jsr syncRaster			
			jsr playerControl
			jsr playerBehaviour
			jsr spriteCharCollision
			jsr waterDroplets
			jmp gameLoop //Must loop!
			
// Synchronize timer with raster IRQ 

syncRaster:	lda #0
			sta rp
			cmp rp
			beq *-3
			jsr expandMSB
			jsr animateWater
			jsr animateSpriteData
			rts
			
// Expand sprite X and Y position 
			
expandMSB:	ldx #$00
update2spr: lda objPos+1,x
			sta $d001,x
			lda objPos,x
			asl
			ror $d010
			sta $d000,x
			inx
			inx 
			cpx #16
			bne update2spr
			rts

// Animate the waterfall by scrolling 
// the waterfall characters downwards 
// slownly.

animateWater:
			lda gfxAnimDelay
			cmp #4
			beq gfxAnimMain
			inc gfxAnimDelay
			rts 
			
// Animate the sprite data - copy sprite frames 
// from table and store to sprite pointers 

animateSpriteData:
				lda spriteAnimDelay
				cmp #6
				beq spriteAnimOk
				inc spriteAnimDelay 
				rts 
				
				// Sprite delay expired call main
				// sprite animation routines

spriteAnimOk:	lda #$00
				sta spriteAnimDelay
				jsr animatePlayer
				jsr animateDroplets
				rts 

				// The main sprite animation for the player
				// and the lettuce it needs to fetch
animatePlayer:
				ldx spriteAnimPointer
				lda slugRightFrame,x
				sta slugRightSprite
				lda slugLeftFrame,x
				sta slugLeftSprite
				lda lettuceFrame,x
				sta lettuceSprite 
				inx 
				cpx #2
				beq loopSpriteAnim1
				inc spriteAnimPointer 
				rts 
loopSpriteAnim1:
				ldx #0
				stx spriteAnimPointer
				rts 

				// The main sprite animation for the 
				// water droplets

animateDroplets:
				ldx spriteAnimPointer2
				lda dropletFrame1,x
				sta $07fa
				lda dropletFrame2,x
				sta $07fb
				lda dropletFrame3,x
				sta $07fc
				lda dropletFrame4,x
				sta $07fd
				lda dropletFrame5,x
				sta $07fe
				lda dropletFrame6,x 
				sta $07ff
				inx 
				cpx #5 
				beq loopSpriteAnim2
				inc spriteAnimPointer2
				rts 
loopSpriteAnim2:
				ldx #$00
				stx spriteAnimPointer2
				rts


			
			// The main charset graphics animation 
gfxAnimMain:
			lda #0
			sta gfxAnimDelay
			
			lda charMem+(waterFallChar1*8)+7	
			pha 
			lda charMem+(waterFallChar2*8)+7
			pha 
			ldx #7
movechrsup:	lda charMem+(waterFallChar1*8),x
			sta charMem+(waterFallChar1*8)+1,x
			lda charMem+(waterFallChar2*8),x
			sta charMem+(waterFallChar2*8)+1,x
			dex 
			bpl movechrsup 
			pla 
			sta charMem+(waterFallChar1*8)
			pla 
			sta charMem+(waterFallChar2*8)
			ldx #$00
movechrslft:
			lda charMem+(waterFallChar3*8),x 
			asl 
			rol charMem+(waterFallChar3*8),x
			asl 
			rol charMem+(waterFallChar3*8),x 
			inx 
			cpx #8
			bne movechrslft
			rts
			
			
// Main player control 

playerControl:
 
			
			
			// Check joystick LEFT 
			
			lda #4
			bit $dc00 
			bne checkRight
			
			// Move slug left until 
			// reached edge of screen
			lda slugLeftSprite 
			sta $07f8          // Hardware sprite ID used for player sprite

			lda slugPosX
			sec
			sbc #1
			cmp #$0c
			bcs updateLeft
			lda #$0c
updateLeft:	sta slugPosX
			 		
			// Check joystick RIGHT
checkRight:			
			lda #8
			bit $dc00 
			bne checkFire
			
			// Move slug right until reached edge of screen

			lda slugRightSprite // Animate the sprite again
			sta $07f8

			lda slugPosX
			clc
			adc #1
			cmp #$a0			
			bcc updateRight
			lda #$a0 
updateRight:
			sta slugPosX
			
checkFire:	lda $dc00 
			lsr
			lsr 
			lsr 
			lsr
			lsr 
			bit fireButton
			ror fireButton
			bmi noJoyControl
			bvc noJoyControl
			lda #0
			sta fireButton
			lda playerIsAllowedToPressFire
			beq noJoyControl 
			 
			ldx #0
			stx playerJumpPointer
			lda #0 
			sta playerIsFalling
			lda #1
			sta playerIsJumping
noJoyControl:
			rts 
			
playerBehaviour:
			
			jsr jumpCheck 
			jsr fallCheck 
			jsr debug_jump_physics
			rts
			
// Check whether or not the player is 
// on ground or jumping. If the 
// pointer playerIsJumping = 0, then
// the player is allowed to jump. Else 
// the routine gets ignored.

jumpCheck:	
			lda playerIsFalling 
			cmp #1
			beq skipJumpFallCheck 
			lda playerIsJumping
			bne makeSlugJump
skipJumpFallCheck:			
			rts 
			
makeSlugJump:
			lda #0
			sta playerIsAllowedToPressFire
			ldx playerJumpPointer
			lda slugPosY 
			clc 
			adc jumpTable,x
			sta slugPosY 
			inx 
			cpx #jumpTableEnd-jumpTable 
			beq endJump
			inc playerJumpPointer 
			
			rts 
			
endJump:	ldx #0
			stx playerJumpPointer
			lda #0
			sta playerIsJumping
			
			lda #1
			sta playerIsFalling
			rts
			
fallCheck:	lda playerIsJumping 
			cmp #1
			beq skipfall
			lda playerIsFalling
			cmp #1 
			beq makeSlugFall
skipfall:			
			rts 
	
makeSlugFall:
			lda slugPosY
			clc 
			adc #4
			sta slugPosY 
			
			rts 
						
// Player sprite to char collision			
spriteCharCollision:
			lda playerIsJumping
			cmp #1
			beq skipCollisionLogic
			lda slugPosXHW			// Read sprite0 X pos for slug
			sec 
			sbc #collisionWidth		// Read collision X position
			sta collZP				// Store to the screen column zeropage
			
			lda slugPosXMSBHW		// Read sprite0 X MSB for slug
			sbc #$00
			lsr 
			lda collZP				// perform 16 bit division
			ror
			lsr
			lsr
			sta collZP+3			// Store to selfmod zeropage for X pos 
			
			lda slugPosY			// Read Y position of slug 
			sec 
			sbc #collisionHeight 	// Read collision Y position
			lsr 
			lsr 					//Y-Co-ords 16 bit division	
			lsr 
			sta collZP+4 			// Store to selfmod ROW

			lda #<screenRam			// Read low byte of screen RAM 
			sta collZP+1			// store as screen read low 
			lda #>screenRam 		// Read hi byte of screen RAM 
			sta collZP+2			// store as screen read hi
			
			ldx collZP+4			// Read current row 
			beq checkPlatform		// Then check platform char 
			
nextRow:	lda collZP+1			// Read low byte of screen
			clc 
			adc #40					// 1 full row = 40 chars
			sta collZP+1			// Moved to next row#
			
			lda collZP+2			// Read hi byte of screen 
			adc #$00
			sta collZP+2			// Store to the next column
			dex 
			bne nextRow 
			
			// Row calculation is complete, now check for the platform 
			// character found. If found, stop the slug from falling.
			
checkPlatform:
			
			ldy collZP+3
			lda (collZP+1),y
			cmp #platformCharValue
			beq platformFound 
			
			// Check if the player is already sitting on the platform 
			// or if the player is falling. If either of those have 
			// been active. Prevent the player from falling, 
			// otherwise allow the slug to fall at some speed.
			
			lda #0
			
			sta playerIsJumping
			lda #1
			sta playerIsAllowedToPressFire
			sta playerIsFalling
dontFall:			
			rts

			
			// Platform is found, so collision has now been detected so stop player 
			// from jumping of falling.
			
platformFound:
		 
			lda playerIsJumping
			cmp #1
			beq skipCollisionLogic
			lda #0
			sta playerIsFalling
			sta playerIsJumping 
			
			lda #1
			sta playerIsAllowedToPressFire
skipCollisionLogic:			
			rts
	
debug_jump_physics:

			lda playerIsFalling
			clc 
			adc #$30
			sta $07c0 
			lda playerIsJumping
			clc 
			adc #$30 
			sta $07c1 
			lda playerIsAllowedToPressFire
			clc 
			adc #$30
			sta $07c2 
			rts		

// Drop all of the water droplets down the screen.

waterDroplets:
			jsr testOffset
			ldx #$00
dropLoop:	lda dropletPosX,x
			clc 
			adc dropletSpeed,x
			sta dropletPosX,x
			inx 
			cpx #12
			bne dropLoop
			 
			rts

// Test if any droplets have gone out of bounds:
testOffset:
			jsr testDroplet1Out
			jsr testDroplet2Out
			jsr testDroplet3Out
			jsr testDroplet4Out 
			jsr testDroplet5Out
			jmp testDroplet6Out 


testDroplet1Out:
			lda dropletPosY
			cmp #$fa 
			bcc droplet1OK
			jsr randomize
			sta dropletPosX
			lda #0
			sta dropletPosY
droplet1OK:			
			rts 

testDroplet2Out:
			lda dropletPosY+2
			cmp #$fa
			bcc droplet2OK
			jsr randomize
			sta dropletPosX+2
			lda #0
			sta dropletPosY+2
droplet2OK:
			rts 

testDroplet3Out:
			lda dropletPosY+4
			cmp #$fa
			bcc droplet3OK
			jsr randomize 
			sta dropletPosX+4
			lda #0
			sta dropletPosY+4
droplet3OK:	rts 

testDroplet4Out:
			lda dropletPosY+6
			cmp #$fa 
			bcc droplet4OK
			jsr randomize 
			sta dropletPosX+6
			lda #0
			sta dropletPosY+6
droplet4OK:	rts

testDroplet5Out:
			lda dropletPosY+8
			cmp #$fa
			bcc droplet5OK
			jsr randomize
			sta dropletPosX+8
			lda #0
			sta dropletPosY+8
droplet5OK:	rts

testDroplet6Out:
			lda dropletPosY+10
			cmp #$fa
			bcc droplet6OK
			jsr randomize
			sta dropletPosX+10
			lda #0
			sta dropletPosY+10
droplet6OK:	rts 



// Randomize timer
randomize:	lda dropRand
			sta dropRandTemp 
			lda dropRand
			asl
			rol dropRandTemp
			asl
			rol dropRandTemp
			clc
			adc dropRand
			pha
			lda dropRandTemp
			adc dropRand+1
			sta dropRand+1
			pla
			adc #$11
			sta dropRand
			lda dropRand+1
			adc #$36
			sta dropRand+1
			and #$0f
			sta newpos
			ldx newpos
			lda randPosTable,x
			rts


// Game pointers 			
rp:			.byte 0 //Raster pointer to sync with IRQ
newpos:     .byte 0		
pointers:

// GFX animation pointer 

gfxAnimDelay: .byte 0

// Sprite animation pointers
spriteAnimDelay: .byte 0
spriteAnimPointer: .byte 0
spriteAnimPointer2: .byte 0
spriteAnimPointer3: .byte 0

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

dropletSpeed: .byte $00,$03,$00,$02,$00,$03,$00,$04,$00,$03,$00,$02


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
explodeFrame:	.byte $8a,$8b,$8c,$8d,$8e,$8f,$90,$91
collectFrame:   .byte $92,$93,$94,$95,$96,$97

// Player jump table 

jumpTable:		.byte $fd,$fc,$fb,$fb,$fb,$fb,$fb,$fb,$fb
jumpTableEnd:				