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
			jmp gameLoop //Must loop!
			
// Synchronize timer with raster IRQ 

syncRaster:	lda #0
			sta rp
			cmp rp
			beq *-3
			jsr expandMSB
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
			
// Main player control 

playerControl:
			
			// Platform jump testing 
			jsr testJumper 
			
			// Check joystick LEFT 
			
			lda #4
			bit $dc00 
			bne checkRight
			
			// Move slug left until 
			// reached edge of screen
			
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
			
			lda slugPosX
			clc
			adc #1
			cmp #$a0			
			bcc updateRight
			lda #$a0 
updateRight:
			sta slugPosX
			
checkFire:	lda #16
			bit $dc00
			bne noJoyControl
			jmp jumpCheck
noJoyControl:
			rts 
			
// Check whether or not the player is 
// on ground or jumping. If the 
// pointer playerIsJumping = 0, then
// the player is allowed to jump. Else 
// the routine gets ignored.

jumpCheck	lda playerIsJumping 
			cmp #1
			beq skipJumping
			ldx #0
			stx playerJumpPointer
			lda #1
			sta playerIsJumping
skipJumping:
			rts
			
// Test platform jumper routine, if 
// the pointer playerIsJumping = 1 then 
// run alreadyJumping routine, else 
// skip.

testJumper	lda playerIsJumping
			cmp #1
			bne playerIsNotJumping
			
			ldx 
			
			
// Game pointers 			
rp:			.byte 0 //Raster pointer to sync with IRQ
		
pointers:

// Sprite animation pointers
spriteAnimDelay: .byte 0
spriteAnimPointer: .byte 0

// Player properties:

playerIsJumping: .byte 0
playerJumpPointer: .byte 0

pointersend:		

playJumpTable:
			.
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
				.byte $00,$00
				.byte $00,$00
				.byte $00,$00
				
				.byte $00,$00
				.byte $00,$00
				.byte $00,$00
				.byte $00,$00

// Game sprite animation and colour 
// pointers 

defaultFrames:	.byte $80,$84,$85,$87
				.byte $89,$88,$86,$89

defaultColour:	.byte $05,$0d,$0d,$0e
				.byte $0e,$0e,$0e,$0e

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

